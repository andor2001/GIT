# Налаштування провайдера
provider "aws" {
  region = "eu-central-1" # Можна змінити на потрібний регіон
  profile = "new_worker1" # Вказуємо ім'я профілю з файлу ~/.aws/credentials
}

# 1. Створення мережі (VPC)
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = { Name = "main-vpc" }
}

# 2. Створення підмережі
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = { Name = "public-subnet" }
}

# 3. Інтернет-шлюз для доступу Frontend до мережі
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = { Name = "main-gw" }
}

# 4. Таблиця маршрутизації
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = { Name = "public-route-table" }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.rt.id
}

# 5. Група безпеки (дозволяємо SSH та внутрішній трафік)
resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"] # Взаємодія між машинами
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 6. Опис дисків та запуск інстанцій
locals {
  ami_id        = "ami-0eddbd81024d36ff2" # Ubuntu 24.04 LTS (перевірте актуальний ID для вашого регіону)
  instance_type = "t3.micro"            # 2 vCPU, 1 GB RAM
}

# Frontend машина
resource "aws_instance" "frontend" {
  ami           = local.ami_id
  instance_type = local.instance_type
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.allow_web.id]

  root_block_device {
    volume_size = 32
    volume_type = "gp3"
  }

  tags = { Name = "Frontend-Server" }
}

# Backend машина
resource "aws_instance" "backend" {
  ami           = local.ami_id
  instance_type = local.instance_type
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.allow_web.id]

  root_block_device {
    volume_size = 32
    volume_type = "gp3"
  }

  tags = { Name = "Backend-Server" }
}

# Вивід IP адрес
output "frontend_public_ip" {
  value = aws_instance.frontend.public_ip
}

output "backend_private_ip" {
  value = aws_instance.backend.private_ip
}
