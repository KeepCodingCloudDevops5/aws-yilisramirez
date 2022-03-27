variable "aws_profile" {
  default = "default"
}

variable "aws_region" {
  default = "eu-west-1"
}

variable "resource_name_pattern" {
  default = "terraform"
}

variable "vpc_cidr" {
  default = "172.24.0.0/16"
}

variable "keypair_name" {
  default = "terraform-keypair"
}

variable "keypair_path" {
  default = "./terraform-keypair.pub"
}

variable "ddbb" {
  type = object({
    dbname   = string
    username = string
    password = string
  })
  default = {
    dbname   = "MyDB"
    username = "admin_user"
    password = "passw1206#"
  }
}

variable "instance_ami" {
  default = "ami-05cd35b907b4ffe77"
}

variable "instance_type" {
  default = "t2.micro"
}
