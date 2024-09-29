variable "vpc_id" { }
variable "subnet_id" {
     type = string
 }
variable "security_private_instance" { }
variable "internal_lb_sg" { }
variable "security_database" { 
}
variable "subnet_app_az2" {
  type = object({
    id = string
    # other attributes if necessary
  })
}

variable "profile_name" { }