variable "my_ip" {
  description = "My public IP address"
  type        = string
}

variable "region" {
  description = "AWS Region"
  type        = string
}

variable "key_name" {
  description = "My key pair ID"
  type        = string
}

variable "smtp_email" {
  type      = string
  sensitive = true
}

variable "smtp_password" {
  type      = string
  sensitive = true
}
