output "topic_arn" {
description = "ARN of SNS tpoic"
value = aws_sns_topic.ec2sns.arn
}
output "event_name" {
description = "ARN of CloudWatch Rule"
value = aws_cloudwatch_event_rule.event.arn
}