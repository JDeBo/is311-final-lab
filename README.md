# Building a Highly Available, Scalable Web Application

## Overview and objectives

Throughout our AWS Academy course, you have completed hands-on labs. You have used different AWS services and features to create compute instances, install operating systems (OSs) and software.

In this project, you're challenged to use familiar AWS services to build a solution *without* step-by-step guidance. Specific sections of the assignment are meant to challenge you on skills that you have acquired throughout the learning process.

By the end of this project, you should be able to do the following:

* Create an architectural diagram to depict various AWS services and their interactions with each other.
* Estimate the cost of using services by using the AWS Pricing Calculator.
* Deploy a functional web application that runs on a single virtual machine and is backed by a relational database.
* Create a virtual network that is configured appropriately to host a web application that is publicly accessible and secure.

## The lab environment and monitoring your budget

This environment is long lived. When the session timer runs to 0:00, the session will end, but any data and resources that you created in the AWS account will be retained. If you later launch a new session (for example, the next day), you will find that your work is still in the lab environment. Also, at any point before the session timer reaches 0:00, you can choose **Start Lab** again to extend the lab session time.

**Important:** Monitor your lab budget in the lab interface. When you have an active lab session, the latest known remaining budget information displays at the top of this screen. This data comes from AWS Budgets, which typically updates every 8–12 hours. Therefore, *the remaining budget that you see might not reflect your most recent account activity*. If you exceed your lab budget, your lab account will be disabled, and all progress and resources will be lost. Therefore, it's important for you to manage your spending.

## AWS service restrictions

In this lab environment, access to AWS services and service actions might be restricted to the ones that are needed to complete the lab instructions. You might encounter errors if you attempt to access other services or perform actions beyond the ones that are described in this lab.

## Scenario

Example University is preparing for the new school year. The admissions department has received complaints that their web application for student records is slow or not available during the peak admissions period because of the high number of inquiries.

You are a cloud infrastructure engineer. Your manager has asked you to create a proof of concept (POC) to host the web application in the AWS Cloud. Your manager would like you to design and implement a new hosting architecture that will improve the experience for users of the web application. You're responsible for building the infrastructure to host the student records web application in the cloud.

Your challenge is to plan, design, build, and deploy the web application to the AWS Cloud. During the peak admissions period, the application must support thousands of users, and be highly available, scalable, load balanced, secure, and high performing.

The student records web application lists records of students who have applied for admission to the university. Users can view, add, delete, and modify student records.

## Solution requirements

The solution must meet the following requirements:

* **Functional:** The solution meets the functional requirements, such as the ability to view, add, delete, or modify the student records, without any perceivable delay.
* **Cost optimized:** The solution is designed to keep costs low.
* **High performing:** The routine operations (viewing, adding, deleting, or modifying records) are performed without a perceivable delay under normal, variable, and peak loads.

### Assumptions

This project will be built in a controlled lab environment that has restrictions on services, features, and budget. Consider the following assumptions for the project:

* The application is deployed in one AWS Region (the solution does not need to be multi-Regional).
* The website does not need to be available over HTTPS or a custom domain.
* The solution is deployed on *Ubuntu* machines by using the JavaScript code that is provided.
* Use the JavaScript code as written unless the instructions specifically direct you to change the code.
* The solution uses services and features within the restrictions of the lab environment.
* The website is publicly accessible without authentication.
* Estimation of cost is approximate.

**Disclaimer:** A security best practice is to allow access to the website through the university network and authentication. However, because you are building this application as a POC, those features are beyond the scope of this project.

## Approach

**Recommendation:** Develop your project solution in phases. This will help you ensure that basic functionality is working before the architecture becomes more complex. After the application is working, you are encouraged to enhance the solution with additional requirements.

---

## Phase 1: Planning the design and estimating cost

In this phase, you will plan the design of your architecture. First, you will create an architecture diagram. Next, you will estimate the cost of the proposed solution, and present the estimate to your educator.

Note: You don't need to use the lab environment for this phase of the project, but you might want to use it to refer to AWS services and features as you plan your design.

### Task 1: Creating an architectural diagram

Create an architectural diagram to illustrate what you plan to build. Consider how you will accomplish each requirement in the solution.

**References**

* [AWS Architecture Icons](https://aws.amazon.com/architecture/icons) — tools to draw AWS architecture diagrams.
* [AWS Reference Architecture Diagrams](https://aws.amazon.com/architecture/reference-architecture-diagrams) — reference diagrams for a variety of use cases.

### Task 2: Developing a cost estimate

Develop a cost estimate that shows the cost to run the solution in the `us-east-1` Region for 12 months. Use the [AWS Pricing Calculator](https://calculator.aws/) for this estimate.

If required by your instructor, add your architectural diagram and cost estimate to presentation slides. A presentation template is provided.

**References**

* [What Is AWS Pricing Calculator?](https://docs.aws.amazon.com/pricing-calculator/latest/userguide/what-is-pricing-calculator.html)
* [PowerPoint presentation template](https://aws-tc-largeobjects.s3.us-west-2.amazonaws.com/CUR-TF-200-ACCAP1-1-79581/1-lab-capstone-project-1/s3/Academy_Lab_Projects_Showcase_template.pptx)

---

## Phase 2: Creating a basic functional web application

In this phase, you will start to build the solution. The objective of this phase is to have a functional web application that works on a single virtual machine in a virtual network that you create. By the end of this phase, you will have a POC to demonstrate hosting the application on the AWS Cloud.

### Task 1: Creating a virtual network

Create a virtual network to host the web application.

* At the top of the AWS Management Console, in the search bar, search for and choose `VPC`
* Choose **Create VPC**, and configure the following:
  * **Resources to create:** Choose **VPC only**.
  * **Name tag:** Enter `FinalVPC`
  * **IPv4 CIDR:** Enter `10.0.0.0/16`
  * Choose **Create VPC**.
* Update the settings for the VPC:
  * Choose **Actions** > **Edit VPC settings**.
  * In the **DNS settings** section, select **Enable DNS hostnames**.
  * Choose **Save**.
* In the navigation pane, choose **Internet gateways**, and configure the following:
  * Choose **Create internet gateway**.
  * **Name tag:** Enter `FinalIGW`
  * Choose **Create internet gateway**.
* Attach the internet gateway to the VPC:
  * Choose **Actions** > **Attach to VPC**.
  * **Available VPCs:** Choose **FinalVPC**.
  * Choose **Attach internet gateway**.
* In the navigation pane, choose **Subnets**, and configure the following:
  * Choose **Create subnet**.
  * **VPC ID:** Choose **FinalVPC**.
  * **Subnet name:** Enter `Public Subnet 1`
  * **Availability Zone:** Choose the first Availability Zone from the dropdown list.
  * **IPv4 CIDR block:** Enter `10.0.1.0/24`
  * Choose **Create subnet**.
* In the navigation pane, choose **Route tables**, and configure the following:
  * For **FinalVPC**, choose the **Route table ID** link.
    **Tip:** Look for *FinalVPC* in the **VPC** column. If the VPC name is not visible, adjust the width of the column.
  * On the **Routes** tab (in the lower pane), choose **Edit routes**.
  * Choose **Add route**, and add the following route:
    * **Destination:** Enter `0.0.0.0/0`
    * **Target:** Enter `Internet Gateway` and then choose **FinalIGW**.
  * Choose **Save changes**.
* In the navigation pane, choose **Subnets**, and configure the following:
  * Select **Public Subnet 1**.
  * Choose **Actions** > **Edit subnet settings**.
  * In the **Auto-assign IP settings** section, select **Enable auto-assign public IPv4 address**.
  * Choose **Save**.

The virtual network resources are now ready. The next step is to put a virtual machine into the network.

### Task 2: Creating a virtual machine

Create a virtual machine in the cloud to host the web application.

To install the required web application and database on the virtual machine, use the userdata script from the following link: [SolutionCodePOC](https://raw.githubusercontent.com/JDeBo/is311-final-lab/main/resources/userdata.sh)

1. At the top of the AWS Management Console, in the search bar, search for and choose `EC2`
2. Choose **Launch instance** > **Launch instance**, and then configure the following:
3. In the **Name and tags** section, for **Name**, enter `FinalPOC`
4. In the **Application and OS Images** section, under **Quick Start**, choose **Ubuntu**. Select **Ubuntu Server 22.04 LTS** from the dropdown.
5. In the **Key pair** section, for **Key pair name**, choose **vockey**.
6. In the **Network settings** section, configure the following:
   * Choose **Edit**.
   * **VPC:** Choose **FinalVPC**.
   * **Auto-assign public IP:** Choose **Enable**.
   * **Firewall (security groups):** Choose **Create security group**.
   * **Security group name:** Enter `FinalAPPSG`
   * Choose **Add security group rule**.
   * Keep the existing SSH rule, and add a new rule with the following settings:
     * **New rule 1:** For **Type**, choose **HTTP**. For **Source type**, choose **Anywhere**.
       **Note:** This rule allows traffic from a web browser.
7. Expand the **Advanced details** section.
8. For **User data**, copy and paste the contents of the [SolutionCodePOC](https://raw.githubusercontent.com/JDeBo/is311-final-lab/main/resources/userdata.sh) script.
9. Keep the default values for all other settings, and choose **Launch instance**.

**Important:** Before moving to the next task, confirm that the instance is in the *Running* state and that the **Status check** column says "2/2 checks passed." This will take a few minutes.

### Task 3: Testing the deployment

Test the deployment of the web application to ensure it is accessible from the internet and functional. Perform a few tasks, such as viewing, adding, deleting, or modifying records.

**Tip:** To access the web application, use the public IPv4 address of the virtual machine.

---

## Ending your session

**Reminder:** This is a long-lived lab environment. Data is retained until you either use the allocated budget or the course end date is reached (whichever occurs first).

To preserve your budget when you are finished for the day, or when you are finished actively working on the assignment for the time being, do the following:

1. At the top of this page, choose **End Lab**, and then choose **Yes** to confirm that you want to end the lab.
   A message panel indicates that the lab is terminating.
   **Note:** Choosing **End lab** in this lab environment will *not* delete the resources you have created. They will still be there the next time you choose **Start lab**.
2. To close the panel, choose **Close** in the upper-right corner.

---

## Rubric

|  | 1 | 2 | 3 |
| :---- | :---- | :---- | :---- |
| VPC Configured Correctly | VPC is deployed but contains large misconfigurations | VPC is deployed but contains minor misconfigurations | VPC is deployed and contains no misconfigurations |
| EC2 Instance Configured Correctly | Website is inaccessible when EC2 instance starts, and userdata doesn't exist, but instance is deployed | Website is inaccessible when EC2 instance starts, but instance is deployed | Website is accessible when EC2 instance starts |
| Diagram | Diagram is unrealistic, and poorly formatted | Diagram is realistic, but poorly formatted | Diagram is realistic and well formatted |
| Cost Estimate | Cost estimate is unrealistic, and contains no formatting | Cost estimate is realistic, but contains no formatting | Cost estimate is realistic and well formatted |
| Presentation | Presentation is poorly put together, contains little relevant information | Presentation is poorly formatted, but contains relevant information | Presentation is well formatted, and contains relevant information |
