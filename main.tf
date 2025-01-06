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
  ami           = "ami-01816d07b1128cd2d" # Amazon Linux 2 AMI
  instance_type = "t2.micro"
  key_name      = "bhoot" # Replace with your key pair name
  security_groups = [aws_security_group.web_sg.name]

  connection {
    type        = "ssh"
    user        = "ec2-user" # Default username for Amazon Linux 2
    private_key = file("C:\\Users\\ABC\\Downloads\\bhoot.pem") # Path to your private key
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "set -x", # Enable debugging
      "sleep 10", # Wait for network readiness
      "sudo yum update -y",
      "sudo yum install -y httpd",
      "sudo systemctl start httpd",
      "sudo systemctl enable httpd",
      # Write to index.html with sudo privileges
      "echo 'Babu tum tension na lo aise hi python application deploy hogi' | sudo tee /var/www/html/index.html > /dev/null"
    ]
  }

  tags = {
    Name = "WebServer"
  }
}
output "public_ip" {
  value = aws_instance.web.public_ip
  description = "The public IP of the web server"
}