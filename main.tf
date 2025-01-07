provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "web_sg" {
  name        = "web-server-sg"
  description = "Allow SSH and HTTP access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH from anywhere
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTP from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-server-sg"
  }
}

resource "aws_instance" "web" {
  ami           = "ami-0e2c8caa4b6378d8c" # Replace with correct Ubuntu AMI for your region
  instance_type = "t2.micro"
  key_name      = "bhoot" # Replace with your key pair name
  security_groups = [aws_security_group.web_sg.name]

  
  provisioner "remote-exec" {
    inline = [
      "set -x", # Enable debugging
      "sleep 10", # Wait for network readiness
      "sudo apt update -y", # Use apt for Ubuntu
      "sudo apt install -y apache2", # Installing Apache on Ubuntu
      "sudo systemctl start apache2", # Start Apache service
      "sudo systemctl enable apache2", # Enable Apache to start on boot
      "echo 'Babu tum tension na lo aise hi python application deploy hogi' | sudo tee /var/www/html/index.html > /dev/null"
    ]
  }

  tags = {
    Name = "WebServer"
  }
}

# Create S3 Bucket
resource "aws_s3_bucket" "web_bucket" {
  bucket = "bhootni" # Replace with your unique bucket name

  tags = {
    Name        = "WebServerBucket"
    Environment = "Production"
  }
}

# Use aws_s3_bucket_acl to manage bucket ACL instead
resource "aws_s3_bucket_acl" "web_bucket_acl" {
  bucket = aws_s3_bucket.web_bucket.bucket
  acl    = "private"
}

output "public_ip" {
  value       = aws_instance.web.public_ip
  description = "The public IP of the web server"
}

output "s3_bucket_name" {
  value       = aws_s3_bucket.web_bucket.bucket
  description = "The name of the S3 bucket"
}
