resource "aws_instance" "myinstance" {
  availability_zone = "us-west-1a"
  ami               = "ami-0cbe318e714fc9a82"
  instance_type     = "t2.micro"
  tags = {
    "Name" = "testec2"
  }
}