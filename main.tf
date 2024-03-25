provider "aws" {
  region     = "ap-south-1"
}

  backend "s3" {
    bucket         	   = "gayathri-s3"
    key              	   = "state/terraform.tfstate"
    region         	   = "ap-south-1"
  }
}


locals {
 ami = csvdecode(file("./Constants/dev/ami.csv"))
 ec2 = csvdecode(file("./Constants/dev/ec2.csv"))
 sg = csvdecode(file("./Constants/dev/sg.csv"))
 ingress = csvdecode(file("./Constants/dev/ingress.csv"))
 egress = csvdecode(file("./Constants/dev/egress.csv"))
 tags = csvdecode(file("./Constants/tags.csv"))
}

(* // module "ami" {
//   source = "./Modules/ami"
//   for_each = {for ami in local.ami : ami.name => ami}
//   ami-name = each.value.name
//   virtualization-type = each.value.virtualization-type
//   root-device-name = each.value.root-device-name
//   device-name =  each.value.device-name
//   volume-size = each.value.volume-size
//   tags = {
//     for tag in local.tags:
//     tag.key => tag.value if tag.id == "ami" || "all"  
//   }
//   // tags = {
//   // key = split(" ", each.value.key)
//   // value = split(" ", each.value.value)
//   //}
// } *)

module "instance" {
  source = "./Modules/ec2"
  depends_on = [module.security-group]
  for_each = {for instance in local.ec2 : instance.id => instance}
  ami-id = each.value.ami-id
  instance-type = each.value.instance-type
  #security-group = module.security-group.name == each.value.sg-name ? each.value.sg-name : ""
  security-group = each.value.sg-name
  tags = {
    for tag in local.tags:
    tag.key => tag.value if tag.id == "ec2" || tag.id == "all"  
  }

}

module "security-group" {
  source = "./Modules/security-group"
  for_each = { for sg in local.sg : sg.name => sg}
  sg-name = each.key
  sg-description = each.value.description

ingress-rules = [
  for index,ingress in split(" ",each.value.ingress-rule) : {
  description = element([for i in local.ingress : i.description if ingress == i.name],1 ) 
  from-port = element([for i in local.ingress : i.from-port if ingress == i.name],2)
  to-port = element([for i in local.ingress : i.to-port if ingress == i.name],3)
  protocol = element([for i in local.ingress : i.protocol if ingress == i.name],4)
} ]

egress-rules = [
  for index,egress in split(" ",each.value.egress-rule) : {
  from-port = element([for e in local.egress : e.from-port if egress == e.name],1)
  to-port = element([for e in local.egress : e.to-port if egress == e.name],2)
  protocol = element([for e in local.egress : e.protocol if egress == e.name],3)
  cidr-block = element([for e in local.egress : e.cidr-block if egress == e.name],4)
} ]

tags = {
  for tag in local.tags:
  tag.key => tag.value if tag.id == "sg" || tag.id == "all"  
}

key = element([for tag in local.tags : tag.key if tag.id == "sg" || tag.id == "all" ],0) 

}
