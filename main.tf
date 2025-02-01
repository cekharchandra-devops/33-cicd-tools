module "jenkins" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "jenkins"

  instance_type          = "t3.small"
  vpc_security_group_ids = ["sg-0158e0bf4b6d8891e"] #replace your SG
  subnet_id = "subnet-040445d6feffd6516" #replace your Subnet
  ami = data.aws_ami.ami_info.id
  user_data = file("jenkins.sh")
  tags = {
    Name = "jenkins"
  }

  # Define the root volume size and type
  root_block_device = [
    {
      volume_size = 50       # Size of the root volume in GB
      volume_type = "gp3"    # General Purpose SSD (you can change it if needed)
      delete_on_termination = true  # Automatically delete the volume when the instance is terminated
    }
  ]
}

module "jenkins_agent" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "jenkins-agent"

  instance_type          = "t3.small"
  vpc_security_group_ids = ["sg-0158e0bf4b6d8891e"]
  subnet_id = "subnet-040445d6feffd6516"
  ami = data.aws_ami.ami_info.id
  user_data = templatefile("jenkins-agent.tpl", {
    aws_access_key_id     = local.aws_credentials.aws_access_key_id,
    aws_secret_access_key = local.aws_credentials.aws_secret_access_key,
    aws_region            = var.aws_region,
  })
  tags = {
    Name = "jenkins-agent"
  }

  root_block_device = [
    {
      volume_size = 50       # Size of the root volume in GB
      volume_type = "gp3"    # General Purpose SSD (you can change it if needed)
      delete_on_termination = true  # Automatically delete the volume when the instance is terminated
    }
  ]
}

resource "local_file" "aws_credentials" {
  filename = var.aws_credentials_file
  content  = jsonencode({
    aws_access_key_id     = local.aws_credentials.aws_access_key_id,
    aws_secret_access_key = local.aws_credentials.aws_secret_access_key,
  })
}

resource "null_resource" "copy_aws_credentials" {
  provisioner "file" {
    source      = local_file.aws_credentials.filename
    destination = "/tmp/aws_credentials.json"
    connection {
      type        = "ssh"
      user        = "ec2-user"
      password = "DevOps321"
      host        = module.jenkins_agent.private_ip
    }
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p ~/.ssh",
      "mv /tmp/aws_credentials.json ~/.ssh/aws_credentials.json",
      "chmod 600 ~/.ssh/aws_credentials.json"
    ]
    connection {
      type        = "ssh"
      user        = "ec2-user"
      # private_key = file(var.ssh_private_key)
      password    = "DevOps321"
      host        = module.jenkins_agent.private_ip
    }
  }
}

module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 2.0"

  zone_name = var.zone_name

  records = [
    {
      name    = "jenkins"
      type    = "A"
      ttl     = 1
      records = [
        module.jenkins.public_ip
      ]
      allow_overwrite = true
    },
    {
      name    = "jenkins-agent"
      type    = "A"
      ttl     = 1
      records = [
        module.jenkins_agent.private_ip
      ]
      allow_overwrite = true
    }
  ]

}