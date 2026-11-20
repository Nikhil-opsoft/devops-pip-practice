variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-2"
}

variable "instance_type" {
  description = "EC2 size"
  type        = string
  default     = "t3.micro"
}

variable "my_ip_cidr" {
  description = "Only this IP may reach the instance, e.g. 1.2.3.4/32"
  type        = string
}
