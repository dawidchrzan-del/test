output "iam_role_arn" {
  description = "The ARN of the IAM role for the ALB controller"
  value       = aws_iam_role.alb_controller.arn
}
