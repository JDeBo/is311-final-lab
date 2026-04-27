# IS311 Final Lab – Review Notes
Date: 2026-04-26

## Summary
This is a 2-phase AWS capstone lab (Phase 1: design/cost estimate; Phase 2: deploy Node.js/MySQL student records app on EC2).

---

## URL Status

| URL | Purpose | Status |
|-----|---------|--------|
| `https://aws-tc-largeobjects.s3.us-west-2.amazonaws.com/CUR-TF-200-ACCAP1-1-79581/1-lab-capstone-project-1/s3/UserdataScript-phase-2.sh` | Primary userdata script | ✅ 200 OK |
| `https://aws-tc-largeobjects.s3.us-west-2.amazonaws.com/CUR-TF-200-ACCAP1-1-DEV/1-lab-capstone-project-1/s3/UserdataScript-phase-2.sh` | Fallback userdata script (lab links to this for "formatting fix") | ✅ 200 OK |
| `https://aws-tc-largeobjects.s3.us-west-2.amazonaws.com/CUR-TF-200-ACCAP1-1-91571/1-lab-capstone-project-1/code.zip` | App code (referenced inside 79581 script) | ✅ 200 OK |
| `https://aws-tc-largeobjects.s3.us-west-2.amazonaws.com/CUR-TF-200-ACCAP1-1-DEV/code.zip` | App code (referenced inside DEV script) | ✅ 200 OK |
| `https://aws-tc-largeobjects.s3.us-west-2.amazonaws.com/CUR-TF-200-ACCAP1-1-79581/1-lab-capstone-project-1/s3/Academy_Lab_Projects_Showcase_template.pptx` | PowerPoint presentation template | ✅ 200 OK |
| `https://aws.amazon.com/architecture/icons` | AWS Architecture Icons reference | ✅ 200 OK |
| `https://aws.amazon.com/architecture/reference-architecture-diagrams` | Reference diagrams | ✅ 200 OK |
| `https://calculator.aws/` | AWS Pricing Calculator | ✅ 200 OK |
| `https://docs.aws.amazon.com/pricing-calculator/latest/userguide/what-is-pricing-calculator.html` | Pricing Calculator docs | ✅ 200 OK |

**All external URLs are live.** No broken links found.

---

## Userdata Script Analysis

### Two versions exist (both downloaded to this dir)

**`UserdataScript-phase-2-79581.sh`** (primary / linked as "SolutionCodePOC"):
- Downloads `code.zip` from `CUR-TF-200-ACCAP1-1-91571` (not the 79581 bucket — cross-bucket reference)
- The original DEV URL is commented out with `#`

**`UserdataScript-phase-2-DEV.sh`** (fallback — linked in the "formatting fix" note):
- Downloads `code.zip` from `CUR-TF-200-ACCAP1-1-DEV`

Both scripts are otherwise identical in logic.

### What the script does
1. `apt install nodejs unzip wget npm mysql-server`
2. Downloads and unzips `code.zip` (Node.js student records app)
3. `npm install aws aws-sdk`
4. Creates MySQL user `nodeapp` / password `student12`
5. Creates `STUDENTS` DB and `students` table
6. Sets `bind-address = 0.0.0.0` in `mysqld.cnf` (opens MySQL to all interfaces — required for Phase 3 RDS migration)
7. Sets `APP_DB_HOST` to the EC2 private IP via instance metadata (`169.254.169.254`)
8. Runs `npm start` on port 80

### Bug: rc.local missing DB env vars
The `rc.local` startup script only sets `APP_PORT=80` — it does NOT re-export `APP_DB_HOST`, `APP_DB_USER`, `APP_DB_PASSWORD`, or `APP_DB_NAME`. After a reboot the app will fall through to the AWS Secrets Manager path in `config.js`, which will fail and then fall back to `localhost` hardcoded defaults. This means the app will still work on reboot (because it falls back to localhost), but it's relying on the `config.js` fallback, not the env vars.

---

## Application Code Analysis (code.zip)

### Stack
- **Runtime:** Node.js / Express
- **DB:** MySQL 2 (via `mysql2` package)
- **Templating:** Mustache-Express
- **Validation:** express-validator

### Metadata mismatch
`package.json` has `"name": "coffee_api"` and `"description": "simple coffee partners API"` — clearly a recycled template. The actual app is a student records CRUD app.

### Bug in `supplier.controller.js` line 57
```js
supplier.i   // <-- incomplete statement, syntax error or copy-paste artifact
```
This is inside the `exports.update` handler. The line appears to be a truncated `supplier.id = req.body.id;`. The app may still work depending on how the update query is built (it uses `req.body.id` directly), but this is a code defect.

### No email validation in create
The `students` table has an `email` column, and the model constructor sets `this.email`, but `exports.create` in the controller has no `body('email', ...)` validation rule. Email is silently passed through unvalidated.

### DB connection pattern
The model reconnects to MySQL on every request (`dbConnect()` called per query). This is intentional per the code comment: "simple mechanism enabling the app to recover from a momentary missing db connection." Fine for a POC but would be a pool in production.

### config.js – Secrets Manager with fallback
`config.js` attempts to pull credentials from AWS Secrets Manager (`Mydbsecret` in `us-east-1`). If that fails (which it will on a fresh EC2 without the secret), it falls back to hardcoded `localhost / nodeapp / student12 / STUDENTS`. This is the expected POC behavior.

---

## Lab Instructions Issues / Notes

1. **Confusing dual script links**: The lab links "SolutionCodePOC" to the 79581 URL twice, then a third time to the DEV URL as a "formatting fix" fallback. The DEV script uses a different code.zip URL internally. Students may be confused about which to use.

2. **No AMI version specified**: The lab says "choose Ubuntu" under Quick Start but doesn't pin an AMI version. Ubuntu 22.04 LTS vs 24.04 vs 20.04 could affect the `mysql-server` package behavior (especially `mysql_native_password` auth plugin, which was deprecated in MySQL 8.0 and removed in 8.4).

3. **`mysql_native_password` deprecation risk**: The userdata uses `IDENTIFIED WITH mysql_native_password` — on Ubuntu 24.04 with MySQL 8.4 this will fail, breaking the entire userdata script and leaving the EC2 instance with no working app.

4. **No `npm install` timeout handling**: `npm install aws aws-sdk` is called without `--legacy-peer-deps` or timeout. On cold start this can take a while and occasionally fail silently in userdata.

5. **Port 80 requires root**: `APP_PORT=80` — on Ubuntu, binding to port 80 typically requires `sudo` or `authbind`. The script runs as root via userdata, so it works initially. The `rc.local` also runs as root, so reboots are fine too.
