resource "aws_iam_role" "roxprox-ecs-task-execution-role" {
  name = "roxprox-ecs-task-execution-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

resource "aws_iam_role_policy" "roxprox-ecs-task-execution-role" {
  name = "roxprox-ecs-task-execution-role"
  role = aws_iam_role.roxprox-ecs-task-execution-role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "ssm:GetParameters",
        "ssm:GetParameter"
      ],
      "Resource": "*"
    }
  ]
}
EOF

}

resource "aws_iam_role" "roxprox-task-role" {
name = "roxprox-task-role"

assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

resource "aws_iam_role_policy" "roxprox-task-role" {
name = "roxprox-task-role"
role = aws_iam_role.roxprox-task-role.id

policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:Get*",
        "s3:Put*"
      ],
      "Resource": "${aws_s3_bucket.roxprox.arn}/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket"
      ],
      "Resource": "${aws_s3_bucket.roxprox.arn}"
    },
    {
      "Effect": "Allow",
      "Action": [
        "sqs:Get*",
        "sqs:ReceiveMessage"
      ],
      "Resource": "${aws_sqs_queue.roxprox-notifications.arn}"
    }
  ]
}
EOF

}

