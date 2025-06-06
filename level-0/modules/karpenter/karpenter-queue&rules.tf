resource "aws_sqs_queue" "karpenter_interruption_queue" {
  name                      = "${var.eks_cluster_name}-cluster-interruption-queue"
  message_retention_seconds = 300
  sqs_managed_sse_enabled   = true
  tags = merge(
    var.tags,
    {
      Terraform = "true"
    }
  )
}

resource "aws_sqs_queue_policy" "karpenter_interruption_policy" {
  queue_url = aws_sqs_queue.karpenter_interruption_queue.id

  policy = jsonencode({
    Id = "EC2InterruptionPolicy",
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = {
          Service = [
            "events.amazonaws.com",
            "sqs.amazonaws.com"
          ]
        },
        Action   = "sqs:SendMessage",
        Resource = aws_sqs_queue.karpenter_interruption_queue.arn
      },
      {
        Sid       = "DenyHTTP",
        Effect    = "Deny",
        Principal = "*",
        Action    = "sqs:*",
        Resource  = aws_sqs_queue.karpenter_interruption_queue.arn,
        Condition = {
          Bool = {
            "aws:SecureTransport" = false
          }
        }
      }
    ]
  })
}

# Common Target block for all EventBridge rules
locals {
  karpenter_queue_target = [{
    arn = aws_sqs_queue.karpenter_interruption_queue.arn
    id  = "KarpenterInterruptionQueueTarget"
  }]
}

resource "aws_cloudwatch_event_rule" "scheduled_change" {
  name          = "${var.eks_cluster_name}-cluster-scheduled-change"
  event_pattern = jsonencode({
    source      = ["aws.health"],
    "detail-type" = ["AWS Health Event"]
  })
  tags = merge(
    var.tags,
    {
      Terraform = "true"
    }
  )
}

resource "aws_cloudwatch_event_target" "scheduled_change_target" {
  rule      = aws_cloudwatch_event_rule.scheduled_change.name
  arn       = local.karpenter_queue_target[0].arn
  target_id = local.karpenter_queue_target[0].id
}

resource "aws_cloudwatch_event_rule" "spot_interruption" {
  name          = "${var.eks_cluster_name}-cluster-spot-interruption"
  event_pattern = jsonencode({
    source      = ["aws.ec2"],
    "detail-type" = ["EC2 Spot Instance Interruption Warning"]
  })
  tags = merge(
    var.tags,
    {
      Terraform = "true"
    }
  )
}

resource "aws_cloudwatch_event_target" "spot_interruption_target" {
  rule      = aws_cloudwatch_event_rule.spot_interruption.name
  arn       = local.karpenter_queue_target[0].arn
  target_id = local.karpenter_queue_target[0].id
}

resource "aws_cloudwatch_event_rule" "rebalance_recommendation" {
  name          = "${var.eks_cluster_name}-cluster-rebalance"
  event_pattern = jsonencode({
    source      = ["aws.ec2"],
    "detail-type" = ["EC2 Instance Rebalance Recommendation"]
  })
  tags = merge(
    var.tags,
    {
      Terraform = "true"
    }
  )
}

resource "aws_cloudwatch_event_target" "rebalance_target" {
  rule      = aws_cloudwatch_event_rule.rebalance_recommendation.name
  arn       = local.karpenter_queue_target[0].arn
  target_id = local.karpenter_queue_target[0].id
}

resource "aws_cloudwatch_event_rule" "instance_state_change" {
  name          = "${var.eks_cluster_name}-cluster-state-change"
  event_pattern = jsonencode({
    source      = ["aws.ec2"],
    "detail-type" = ["EC2 Instance State-change Notification"]
  })
  tags = merge(
    var.tags,
    {
      Terraform = "true"
    }
  )
}

resource "aws_cloudwatch_event_target" "instance_state_change_target" {
  rule      = aws_cloudwatch_event_rule.instance_state_change.name
  arn       = local.karpenter_queue_target[0].arn
  target_id = local.karpenter_queue_target[0].id
}
