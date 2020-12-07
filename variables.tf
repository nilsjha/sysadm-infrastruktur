
variable "sg_mgmt_allow_ips" {
  description = "List of allowed IPs that can mgmt SSH into AWS"
  default = [
    "***REMOVED***/32",
    "***REMOVED***/32"
  ]
}

variable "ec2_count" {
  description = "The count of how many EC2 instances"
  type        = number
  default     = 3
}

variable "ec2_type" {
  type    = string
  default = "t2.micro"
}

variable "id_prefix" {
  type    = string
  default = "sysadm1"
}

variable "runtime_prefix" {
  type    = string
  default = "dev"
}

# Denne held på SSH-generert nøkkel og 
# MÅ IKKJE ENDRAST!! LA STÅ TOM!
variable "key_ec2_access" {
  default = ""
}