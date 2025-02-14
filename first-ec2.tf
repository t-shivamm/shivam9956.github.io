
terraform {
  required_providers {
    digitalocean = {
        source = "digitalocean/digitalocean"
    }
  }
}

resource "aws_instance" "shivam-first-vm" {
    ami = "ami-00beae93a2d981137"
    instance_type = "t2.micro"

    tags = {
      Name = "shivam-first-vm"
    }
}