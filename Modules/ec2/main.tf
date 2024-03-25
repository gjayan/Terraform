data "aws_key_pair" "key-pair" {
  filter {
    name   = "tag:Name"
    values = ["GayathriKeyPair"]
  }
}

resource "aws_instance" "instance" {
  ami           = var.ami-id
  instance_type = var.instance-type

  key_name = data.aws_key_pair.key-pair.key_name

 security_groups = [var.security-group]

tags= var.tags
}
