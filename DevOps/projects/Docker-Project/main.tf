terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
          github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

provider "github" {
    token = var.git-token
}

variable "git-token" {
    default = "ghp_!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
}

variable "git-user-name" {
    default = "AhmtFth35"
}

variable "key-name" {
    default = "gzm"
}

resource "github_repository" "myrepo" {
    name = "bookstore-api-app"
    visibility = "private"
    auto_init = true  
}

resource "github_branch_default" "main" {
    branch =  "main" 
    repository = github_repository.myrepo.name
}

variable "files" {
    default = ["bookstore-api.py", "Dockerfile", "docker-compose.yml", "requirements.txt"]
  
}

resource "github_repository_file" "app-files" {
  
  for_each = toset(var.files)
  content = file(each.value)
  file = each.value

  repository = github_repository.myrepo.name
  branch = "main"
  commit_message = "managed by Terraform"
  overwrite_on_create = true
}


resource "aws_security_group" "tf-docker-sg" {
    name = "docker-sec-gr"
    tags = {
            Name = "docker-sec-gr"
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
        ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
        egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_instance" "tf-docker-ec2" {

    ami = "ami-0e731c8a588258d0d"
    instance_type = "t2.micro"
    key_name = var.key-name
    vpc_security_group_ids = [aws_security_group.tf-docker-sg.id ]
    tags = {
        Name = "ahmtfth-Bookstore Server"
    }
    user_data = templatefile("user-data.sh", {user-data-git-token = var.git-token, user-data-git-user-name = var.git-user-name})
    depends_on = [github_repository.myrepo, github_repository_file.app-files ]
}

output "webpage" {
    value = "http://${aws_instance.tf-docker-ec2.public_ip}"
  
}