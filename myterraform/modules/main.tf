module "iam" {
  source = "./iam"

  group = "group1"
}

module "ec2" {
  source = "./ec2"
  az = "us-west-1b"
  instancename = module.iam.username
}