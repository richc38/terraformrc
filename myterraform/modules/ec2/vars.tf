variable "ami" {
    type = string
    description = "ami of instance"
    default = "ami-0cbe318e714fc9a82"
}

variable "itype" {
    type = string
    description = "instance type"
    default = "t2.micro"
}

variable "az" {
    type = string
    description = "az for my instance"
    default = "us-west-1a"
}

variable "instancename" {
    type = string
    description = "instance name"
}