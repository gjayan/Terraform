variable "vpc-id" {
	type = string
	default = "vpc-05099366d11596337"
}

variable "sg-name" {
	type = string
}

variable "sg-description" {
	type = string
}

variable "ingress-rules" {
	type = any
}

variable "egress-rules" {
	type = any
}

variable "tags" {
	type = any
}

variable "key" {
	type = string
}