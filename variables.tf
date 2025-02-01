variable "zone_name" {
  type        = string
  default     = "devsecmlops.online"
  description = "description"
}

variable "aws_region" {
  default = "us-east-1"
}


variable "aws_credentials_file" {
  default     = "~/.ssh/aws_credentials.json"
}