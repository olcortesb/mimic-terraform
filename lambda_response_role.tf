data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_role_response" {
  name               = "${var.function_name_two}-lambda-role-central"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}


resource "aws_iam_policy" "lambda-policy" {
  name        = "${var.function_name_two}-policy-central"
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
                "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.function_name_two}:*"
            ]
        }
    ]
}
EOT
}

resource "aws_iam_role_policy_attachment" "policy_to_role_sts" {
  role       = aws_iam_role.lambda_role_response.name
  policy_arn = aws_iam_policy.lambda-policy.arn
}

resource "aws_iam_policy" "s3_full_access_policy_lambda" {
  name   = "${var.environment}-s3-policy-${var.function_name_two}-lambda-central"
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

resource "aws_iam_role_policy_attachment" "policy_to_role_s3_response" {
  role       = aws_iam_role.lambda_role_response.name
  policy_arn = aws_iam_policy.s3_full_access_policy_lambda.arn
}


resource "aws_iam_policy" "secrets_ro_access_policy_lambda" {
  name   = "${var.environment}-secrets-policy-${var.function_name_two}-lambda-central"
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

resource "aws_iam_role_policy_attachment" "policy_to_role_secrets" {
  role       = aws_iam_role.lambda_role_response.name
  policy_arn = aws_iam_policy.secrets_ro_access_policy_lambda.arn
}


resource "aws_iam_policy" "invoke_lambda_policy_lambda" {
  name   = "${var.environment}-invoke-lambda-policy-${var.function_name_two}-lambda-central"
  policy = <<EOT
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": "lambda:InvokeFunction",
            "Resource": "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:${var.function_name_two}"
        }
    ]
}
EOT
}

resource "aws_iam_role_policy_attachment" "policy_to_role_invoke_lambda" {
  role       = aws_iam_role.lambda_role_response.name
  policy_arn = aws_iam_policy.invoke_lambda_policy_lambda.arn
}

resource "aws_iam_policy" "iam_permissions_policy" {
  name   = "${var.environment}-iam-permissions-policy-${var.function_name_two}-lambda-central"
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

resource "aws_iam_role_policy_attachment" "iam_permissions_attachment" {
  role       = aws_iam_role.lambda_role_response.name
  policy_arn = aws_iam_policy.iam_permissions_policy.arn
}

resource "aws_iam_policy" "iam_dynamodb_policy_response" {
  name   = "${var.environment}-iam-dynamodb-policy-${var.function_name_two}-lambda-central"
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

resource "aws_iam_role_policy_attachment" "iam_dynamodb_attachment_response" {
  role       = aws_iam_role.lambda_role_response.name
  policy_arn = aws_iam_policy.iam_dynamodb_policy_response.arn
}