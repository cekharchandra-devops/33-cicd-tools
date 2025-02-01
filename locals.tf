locals {
  aws_credentials = jsondecode(file(var.aws_credentials_file))
}