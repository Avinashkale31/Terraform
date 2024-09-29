resource "aws_instance" "app" {
  ami                  = "ami-01fccab91b456acc2"
  instance_type        = "t2.micro"
  subnet_id            = var.subnet_id
  vpc_security_group_ids = [var.security_private_instance]
  
  iam_instance_profile = var.profile_name
}

resource "aws_ami_from_instance" "app_image" {
  name               = "app_ami_image"
  source_instance_id = aws_instance.app.id
}
resource "aws_lb_target_group" "target_app" {
  name     = "tf-app-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  }
 

resource "aws_lb" "app" {
  name               = "app-lb-tf"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [var.internal_lb_sg]
  subnets = [var.subnet_id, var.subnet_app_az2.id]
  enable_deletion_protection = false
}

  
resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app.arn
  port              = "80"
  protocol          = "HTTP"
  

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_app.id
  }
}

resource "aws_launch_template" "app_launch" {
  name = "app_template"
  image_id = aws_ami_from_instance.app_image.id
  instance_type = "t2.micro"
  vpc_security_group_ids = [var.security_private_instance]
iam_instance_profile {
  name = var.profile_name
}
    
  }


resource "aws_autoscaling_group" "app_scale" {
  name                      = "app_autoscalling"
  max_size                  = 2
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 2
  force_delete              = true
  launch_template {
    id = aws_launch_template.app_launch.id
  }
  vpc_zone_identifier       = [var.subnet_id,var.subnet_app_az2.id]

}

resource "aws_autoscaling_attachment" "app_auto" {
  autoscaling_group_name = aws_autoscaling_group.app_scale.name
  lb_target_group_arn = aws_lb_target_group.target_app.arn
}