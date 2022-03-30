variable name {
  type        = string
  default     = "demo"
  description = "Prefix of resources"
}

variable cidr {
  type        = string
  description = "VPC CIDR block"
}

variable public_subnets {
  type        = list
  description = "VPC public subnet IP lists"
}

variable private_subnets {
  type        = list
  description = "VPC private subnet IP lists"
}

variable azs {
  type        = list
  default     = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
  description = "Availability zone lists"
}

variable tags {
  type        = map
  description = "Tag map for all resources"
}
