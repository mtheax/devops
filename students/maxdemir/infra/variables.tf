variable "region" {
  type    = string
  default = "eu-north-1"
}

variable "name" {
  type    = string
  default = "nodeapp"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "key_name" {
  type        = string
  default     = "nodeapp"
  description = "Назва наявної AWS key pair (має існувати в цьому регіоні)"
}
