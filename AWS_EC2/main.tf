data "aws_vpc" "existing" {
  id = "vpc-09a5f812ef5324807"
}
data "aws_subnet" "Default" {
  id = "subnet-0e4d930653df6e8fb"
  vpc_id = data.aws_vpc.existing.id
}

resource "aws_instance" "myec2" {
  ami = var.image_id
  instance_type = "t2.micro"
  key_name = "mykeypair"

  tags = {
    name = "instance"
  }
}