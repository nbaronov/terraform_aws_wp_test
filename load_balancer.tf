resource "aws_lb" "application_loadbalancer" {
  name               = "app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.wordpress_sg.id]
  subnets            = [aws_subnet.first_public_subnet.id, aws_subnet.second_public_subnet.id]
}

resource "aws_lb_target_group" "target_group_lb" {
  name     = "target-group-alb"
  port     = var.application_port
  protocol = "HTTP"
  vpc_id   = aws_vpc.infrastructure_vpc.id
}

resource "aws_lb_target_group_attachment" "attachment1" {
  target_group_arn = aws_lb_target_group.target_group_lb.arn
  target_id        = aws_instance.wp_node1_instance.id
  port             = var.application_port
  depends_on = [
    aws_instance.wp_node1_instance,
  ]
}

resource "aws_lb_target_group_attachment" "attachment2" {
  target_group_arn = aws_lb_target_group.target_group_lb.arn
  target_id        = aws_instance.wp_node2_instance.id
  port             = var.application_port
  depends_on = [
    aws_instance.wp_node2_instance,
  ]
}

resource "aws_lb_listener" "external_elb" {
  load_balancer_arn = aws_lb.application_loadbalancer.arn
  port              = var.application_port
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group_lb.arn
  }
}
