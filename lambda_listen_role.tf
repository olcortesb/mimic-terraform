data "aws_iam_policy_document" "assume_role_listen" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "${var.function_name_one}-lambda-role-central"
  assume_role_policy = data.aws_iam_policy_document.assume_role_listen.json
}


resource "aws_iam_policy" "lambda-policy-listen" {
  name        = "${var.function_name_one}-policy-central"
  description = "policy to attach to maintenance-options lambda role"

  policy = <<EOT
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.function_name_one}:*"
            ]
        }
    ]
}
EOT
}

resource "aws_iam_role_policy_attachment" "policy_to_role_sts_listen" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda-policy-listen.arn
}

resource "aws_iam_policy" "s3_full_access_policy_lambda_listen" {
  name   = "${var.environment}-s3-policy-${var.function_name_one}-lambda-central"
  policy = <<EOT
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:*",
                "s3-object-lambda:*"
            ],
            "Resource": [
                "arn:aws:s3:::geocustom-bucket-${var.environment}",
                "arn:aws:s3:::geocustom-bucket-${var.environment}/*",
                "arn:aws:s3:::geocustom-deploy-bucket-${var.environment}",
                "arn:aws:s3:::geocustom-deploy-bucket-${var.environment}/*"
            ]
        }
    ]
}
EOT
}

resource "aws_iam_role_policy_attachment" "policy_to_role_s3" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.s3_full_access_policy_lambda_listen.arn
}


resource "aws_iam_policy" "secrets_ro_access_policy_lambda_listen" {
  name   = "${var.environment}-secrets-policy-${var.function_name_one}-lambda-central"
  policy = <<EOT
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "secretsmanager:GetResourcePolicy",
                "secretsmanager:GetSecretValue",
                "secretsmanager:DescribeSecret",
                "secretsmanager:ListSecretVersionIds"
            ],
            "Resource": "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:*"
        },
        {
            "Effect": "Allow",
            "Action": "secretsmanager:ListSecrets",
            "Resource": "*"
        }
    ]
} 
EOT
}

resource "aws_iam_role_policy_attachment" "policy_to_role_secrets_listen" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.secrets_ro_access_policy_lambda_listen.arn
}


resource "aws_iam_policy" "invoke_lambda_policy_lambda_listen" {
  name   = "${var.environment}-invoke-lambda-policy-listen-${var.function_name_one}-lambda-central"
  policy = <<EOT
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": "lambda:InvokeFunction",
            "Resource": "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:${var.function_name_one}"
        }
    ]
}
EOT
}

resource "aws_iam_role_policy_attachment" "policy_to_role_invoke_lambda_listen" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.invoke_lambda_policy_lambda_listen.arn
}

resource "aws_iam_policy" "iam_permissions_policy_listen" {
  name   = "${var.environment}-iam-permissions-policy-${var.function_name_one}-lambda-central"
  policy = <<EOT
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "iam:ListUsers",
                "iam:ListAccessKeys",
                "iam:ListAttachedUserPolicies",
                "iam:ListPolicies",
                "iam:ListEntitiesForPolicy",
                "iam:DeleteUser",
                "iam:DeleteAccessKey",
                "iam:DetachUserPolicy",
                "iam:DeletePolicy"
            ],
            "Resource": "*"
        }
    ]
}
EOT
}

resource "aws_iam_role_policy_attachment" "iam_permissions_attachment_listen" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.iam_permissions_policy_listen.arn
}


resource "aws_iam_policy" "iam_dynamodb_policy_listen" {
  name   = "${var.environment}-iam-dynamodb-policy-${var.function_name_one}-lambda-central"
  policy = <<EOT
  {
	"Version": "2012-10-17",
	"Statement": [{
			"Effect": "Allow",
			"Action": [
				"dynamodb:BatchGetItem",
				"dynamodb:GetItem",
				"dynamodb:Query",
				"dynamodb:Scan",
				"dynamodb:BatchWriteItem",
				"dynamodb:PutItem",
				"dynamodb:UpdateItem"
			],
			"Resource": "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/${var.platform_name}"
		},
		{
			"Effect": "Allow",
			"Action": [
				"logs:CreateLogStream",
				"logs:PutLogEvents"
			],
			"Resource": "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
		},
		{
			"Effect": "Allow",
			"Action": "logs:CreateLogGroup",
			"Resource": "*"
		}
	]
}
EOT
}

resource "aws_iam_role_policy_attachment" "iam_dynamodb_attachment_listen" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.iam_dynamodb_policy_listen.arn
}