resource "aws_sns_topic" "ec2sns" {
  name            = "my-topic"
  delivery_policy = <<EOF
{
  "http": {
    "defaultHealthyRetryPolicy": {
      "minDelayTarget": 20,
      "maxDelayTarget": 20,
      "numRetries": 3,
      "numMaxDelayRetries": 0,
      "numNoDelayRetries": 0,
      "numMinDelayRetries": 0,
      "backoffFunction": "linear"
    },
    "disableSubscriptionOverrides": false,
    "defaultThrottlePolicy": {
      "maxReceivesPerSecond": 1
    }
  }
}
EOF
}
resource "aws_sns_topic_policy" "default" {
  arn    = aws_sns_topic.ec2sns.arn
  policy = data.aws_iam_policy_document.sns_topic_policy.json
}
data "aws_iam_policy_document" "sns_topic_policy" {
  statement {
    effect  = "Allow"
    actions = ["SNS:Publish"]
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
    resources = [aws_sns_topic.ec2sns.arn]
  }
}
resource "aws_sns_topic_subscription" "targetmail" {
  topic_arn = aws_sns_topic.ec2sns.arn
  protocol  = "email"
  endpoint  = "yaswanth889@gmail.com"
}
############ Creating CloudWatch Event ############
resource "aws_cloudwatch_event_rule" "event" {
name = "MyEC2StateChangeEvent"
description = "MyEC2StateChangeEvent"
event_pattern = <<EOF
{
"source": [
"aws.ec2"
],
"detail-type": [
"EC2 Instance State-change Notification"
]
}
EOF
}
resource "aws_cloudwatch_event_target" "sns" {
rule = aws_cloudwatch_event_rule.event.name
target_id = "SendToSNS"
arn = aws_sns_topic.ec2sns.arn
}
# resource "aws_sns_topic_policy" "default" {
# arn = aws_sns_topic.ec2sns.arn
# policy = data.aws_iam_policy_document.sns_topic_policy.json
# }
# data "aws_iam_policy_document" "sns_topic_policy" {
# statement {
# effect = "Allow"
# actions = ["SNS:Publish"]
# principals {
# type = "Service"
# identifiers = ["events.amazonaws.com"]
# }
# resources = [aws_sns_topic.topic.arn]
# }
# }