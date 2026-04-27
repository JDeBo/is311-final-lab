variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key to register as an EC2 key pair"
  type        = string
  default     = "~/.ssh/is311-lab-key.pub"
}
