resource "aws_lb" "wikijs_alb" {
  name               = "wikijs-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = ["${aws_subnet.wikijs_public_subnet.*.id}"]
  security_groups    = ["${aws_security_group.wikijs_alb_sg.id}"]
}

resource "aws_lb_target_group" "wikijs_alb_tg" {
  name     = "wikijs-alb-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = aws_vpc.wikijs_vpc.id
  
  stickiness {
      enabled         = true
      cookie_duration = 1800
      type            = "lb_cookie"
  }

  health_check {
      path    = "/healthz"
      port    = 3000
      matcher = 200
  }
}

resource "aws_lb_listener" "wikijs_alb_listener" {
  load_balancer_arn = aws_lb.wikijs_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  default_action {
      type             = "forward"
      target_group_arn = aws_lb_target_group.wikijs_alb_tg.arn
  }
  
}