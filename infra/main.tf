# Create a new security group
resource "aws_security_group" "terraform_sec_group" {
  name        = "terraform-sec-group"
  description = "Allow SSH and HTTP"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Get the default VPC
data "aws_vpc" "default" {
  default = true
}

# Launch EC2 instance
resource "aws_instance" "my_ec2" {
  ami           = "ami-0aba19e56f3eaec05"
  instance_type = "t3.micro"
  key_name      = "Red-Login" # Use the key-pair name without .pem

  vpc_security_group_ids = [aws_security_group.terraform_sec_group.id]

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install -y nginx git

              # Remove default nginx page
              sudo rm -f /var/www/html/index.nginx-debian.html

              # Clone your GitHub repo (replace with your repo URL)
              git clone https://github.com/maduekedickson/terraform-demo.git /tmp/website

              # Copy website files to nginx root
              sudo cp -r /tmp/website/website/* /var/www/html/

              # Set permissions
              sudo chown -R www-data:www-data /var/www/html
              sudo chmod -R 755 /var/www/html

              # Enable and start nginx
              sudo systemctl enable nginx
              sudo systemctl start nginx
              EOF

  tags = {
    Name = "My Web Server"
  }
}