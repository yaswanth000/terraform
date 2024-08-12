variable "image_id" {
  type = string
  description = "The id of the machine image (AMI) to use for the server."
  default = "ami-0ae8f15ae66fe8cda"
}

variable "availability_zone_names" {
  type    = list(string)
  default = ["us-east-1"]
}