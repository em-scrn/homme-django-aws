# Request a certificate for the domain and its www subdomain
resource "aws_acm_certificate" "cert" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  subject_alternative_names = ["www.${var.domain_name}"]

  tags = {
    Name = "${var.domain_name}_certificate"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Declare the Route 53 zone for the domain
data "aws_route53_zone" "selected" {
  name = var.domain_name
}

# Define the Route 53 records for certificate validation
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = data.aws_route53_zone.selected.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60
}

# Define the Route 53 records for the domain and its www subdomain
resource "aws_route53_record" "root_record" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_lb.default.dns_name
    zone_id                = aws_lb.default.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "www_record" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "www.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_lb.default.dns_name
    zone_id                = aws_lb.default.zone_id
    evaluate_target_health = true
  }
}

# Define the certificate validation resource
resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

# Security group for ALB, allows HTTPS traffic
resource "aws_security_group" "alb_sg" {
  vpc_id      = aws_vpc.default.id
  name        = "alb-https-security-group"
  description = "Allow all inbound HTTPS traffic"

  ingress {
    from_port   = 443
    to_port     = 443
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

# Application Load Balancer for HTTPS traffic
resource "aws_lb" "default" {
  name               = "${var.app_name}-ec2-alb-https"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]

  enable_deletion_protection = false
}

# Target group for the ALB to route traffic from ALB to VPC
resource "aws_lb_target_group" "default_http" {
  name     = "${var.app_name}-ec2-tg-https"
  # target_type = "alb"
  port     = 443
  protocol = "HTTP"
  vpc_id   = aws_vpc.default.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}


# Attach the EC2 instance to the target group
resource "aws_lb_target_group_attachment" "default" {
  target_group_arn = aws_lb_target_group.default_http.arn
  target_id        = aws_instance.web.id # EC2 instance id
  port             = 80                  # Port the EC2 instance listens on; adjust if different
}


# HTTPS listener for the ALB to route traffic to the target group
resource "aws_lb_listener" "default" {
  load_balancer_arn = aws_lb.default.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08" # Default policy, adjust as needed
  certificate_arn   = aws_acm_certificate.cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.default_http.arn
  }

}