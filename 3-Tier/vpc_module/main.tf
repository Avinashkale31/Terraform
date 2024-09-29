

resource "aws_vpc" "three_tier" {
 cidr_block = var.cidr_block_vpc
 }

resource "aws_subnet" "public_az1" {
  vpc_id     = aws_vpc.three_tier.id
  cidr_block = var.cidr_block_webaz1
  map_public_ip_on_launch = true
  availability_zone = var.availability_zone_az1

  tags = {
    Name = "public_web_az1"
  }
}

resource "aws_subnet" "privateappaz1" {
  vpc_id            = aws_vpc.three_tier.id
  cidr_block        = var.cidr_block_appaz1
  availability_zone = var.availability_zone_az1

  tags = {
    Name = "private_app_az1"
  }
}


resource "aws_subnet" "private_db_az1" {
  vpc_id     = aws_vpc.three_tier.id
  cidr_block = var.cidr_block_dbaz1
  availability_zone = var.availability_zone_az1
    tags = {
    Name = "private_db_az1"
  }
}

resource "aws_subnet" "public_az2" {
  vpc_id     = aws_vpc.three_tier.id
  cidr_block = var.cidr_block_webaz2
  map_public_ip_on_launch = true
  availability_zone = var.availability_zone_az2
  tags = {
    Name = "public_web_az2"
  }
}
resource "aws_subnet" "private_app_az2" {
  vpc_id     = aws_vpc.three_tier.id
  cidr_block = var.cidr_block_appaz2
  availability_zone = var.availability_zone_az2
  

  tags = {
    Name = "private_app_az2"
  }
}

resource "aws_subnet" "private_db_az2" {
  vpc_id     = aws_vpc.three_tier.id
  cidr_block = var.cidr_block_dbaz2
  availability_zone =  var.availability_zone_az2
  
  tags = {
    Name = "private_db_az2"
  }
}

resource "aws_internet_gateway" "igw" {
 vpc_id = aws_vpc.three_tier.id
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
    allocation_id = aws_eip.nat_eip.id
    subnet_id     = aws_subnet.public_az1.id

  tags = {
    Name = "gw NAT"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.three_tier.id
}

resource "aws_route" "public1" {
    route_table_id = aws_route_table.public.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public_az1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public3" {
  subnet_id      = aws_subnet.public_az2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private_app" {
    vpc_id = aws_vpc.three_tier.id

   tags = {
    Name = "private_app"
  }
}


resource "aws_route" "private_app1" {
    route_table_id = aws_route_table.private_app.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_nat_gateway.nat.id

}

resource "aws_route_table_association" "private_app1" {
    route_table_id = aws_route_table.private_app.id
  subnet_id = aws_subnet.privateappaz1.id
}

resource "aws_route_table_association" "private_app2" {
    route_table_id = aws_route_table.private_app.id
  subnet_id = aws_subnet.private_app_az2.id
}

resource "aws_eip" "nat_db" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_db" {
    allocation_id = aws_eip.nat_db.id
    subnet_id     = aws_subnet.public_az2.id

  tags = {
    Name = "private db"
  }
}


resource "aws_route_table" "private_db" {
    vpc_id = aws_vpc.three_tier.id

   tags = {
    Name = "private_db"
  }
}


resource "aws_route" "private_db1" {
    route_table_id = aws_route_table.private_db.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_nat_gateway.nat_db.id

}

resource "aws_route_table_association" "private_db1" {
    route_table_id = aws_route_table.private_db.id
  subnet_id = aws_subnet.private_db_az1.id
}

resource "aws_route_table_association" "private_db2" {
    route_table_id = aws_route_table.private_db.id
  subnet_id = aws_subnet.private_db_az2.id
}

resource "aws_security_group" "internet" {
  vpc_id = aws_vpc.three_tier.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["103.51.154.162/32"]  # Allow traffic from a specific IP address
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Allow all outbound traffic
  }

  tags = {
    Name = "internetaccess"
  }
}

resource "aws_security_group" "web_tier" {
  vpc_id = aws_vpc.three_tier.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks     = ["103.51.154.162/32"]  # Allow traffic from a specific IP address
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.internet.id]  # Allow traffic from the internet security group
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Allow all outbound traffic
  }

  tags = {
    Name = "web_tier"
  }
}

resource "aws_security_group" "internal_lb" {
  vpc_id = aws_vpc.three_tier.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.web_tier.id]  # Allow traffic from the web tier security group
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Allow all outbound traffic
  }

  tags = {
    Name = "internal_lb"
  }
}

resource "aws_security_group" "private_instance" {
  vpc_id = aws_vpc.three_tier.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks     = ["103.51.154.162/32"]  # Allow traffic from a specific IP address
  }

  ingress {
    from_port       = 4000
    to_port         = 4000
    protocol        = "tcp"
    security_groups = [aws_security_group.internal_lb.id]  # Allow traffic from the internal load balancer security group
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Allow all outbound traffic
  }

  tags = {
    Name = "private_instance"
  }
}

resource "aws_security_group" "database" {
  vpc_id = aws_vpc.three_tier.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.private_instance.id]  # Allow traffic from the private instance security group
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Allow all outbound traffic
  }

  tags = {
    Name = "database"
  }
}

resource "aws_db_subnet_group" "name" {
    subnet_ids = [aws_subnet.public_az1.id, aws_subnet.private_db_az1.id, aws_subnet.private_db_az2.id]

  tags = {
    Name = "Aurora subnet group"
  }
}