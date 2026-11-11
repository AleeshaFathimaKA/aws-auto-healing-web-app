
variable "project_name" {
  description = "Name of the AWS auto-healing project"
  type        = string
  default     = "aws-auto-healing"
}

variable "aws_region" {
  description = "AWS deployment region"
  type        = string
  default     = "ap-southeast-2"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}
variable "notification_email" {
  description = "Email address for CloudWatch alerts"
  type        = string
  default     = ""
}