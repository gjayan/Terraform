data "aws_vpc" "default" {
  filter {
     name = "tag:Name"
     values = ["Gayathri-VPC"]
  }
}

resource "aws_security_group" "security-group" {
  name        = var.sg-name
  description = var.sg-description
  vpc_id      = data.aws_vpc.default.id

  dynamic "ingress" {
    for_each = var.ingress-rules
    content {
    description      = lookup(ingress.value, "description", "Ingress rule for (${ingress.value.protocol}) protocol")
    from_port        = lookup(ingress.value, "from-port")
    to_port          = lookup(ingress.value, "to-port")
    protocol         = lookup(ingress.value, "protocol")
    cidr_blocks      = [data.aws_vpc.default.cidr_block]
            }
                    }


  dynamic "egress" {
    for_each = var.egress-rules
    content {
    from_port        = lookup(egress.value, "from-port")
    to_port          = lookup(egress.value, "to-port")
    protocol         = lookup(egress.value, "protocol")
    cidr_blocks      = [lookup(egress.value, "cidr-block")]
           }
}

tags = var.tags
 
lifecycle {
  precondition {
    condition = contains(["Name", "Used_by"], var.key)
    error_message = "tags[\"Used_by and Name\"] must be \"present\"."
  }
}
}


#tags, validation, main main.tf, try separately, add vpc-id in data
