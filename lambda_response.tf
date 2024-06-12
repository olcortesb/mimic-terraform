// Local vars
locals {
  zip_file_path_response = "repository/src/zips/${lower(var.function_name_two)}.zip"
}

// Lambda file
data "archive_file" "lambda_response_zip" {
  type        = "zip"
  source_dir  = "repository/src/"
  output_path = local.zip_file_path_response
  excludes    = ["zips", "terraform", ".gitignore", "README.md", ".git", ".gitlab-ci.yml"]
}

resource "aws_s3_bucket" "lambda_response_code_bucket" {
  bucket = "${lower(var.function_name_two)}-lambda-code-${var.environment}"
}

resource "aws_s3_bucket_versioning" "versioning_response" {
  bucket = aws_s3_bucket.lambda_response_code_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_object" "lambda_response_code" {
  bucket      = aws_s3_bucket.lambda_response_code_bucket.id
  key         = "repository/${lower(var.function_name_two)}.zip"
  source      = local.zip_file_path_response
  source_hash = data.archive_file.lambda_response_zip.output_base64sha256
  depends_on  = [data.archive_file.lambda_response_zip, aws_s3_bucket_versioning.versioning_response]
}


## Lambda Signer 

resource "aws_signer_signing_profile" "tfsigner_response" {
  name_prefix = "tfsigner_response"
  platform_id = "AWSLambda-SHA384-ECDSA"
}


resource "aws_signer_signing_job" "response_signer_jobs" {
  profile_name = aws_signer_signing_profile.tfsigner_response.name

  source {
    s3 {
      bucket  = aws_s3_bucket.lambda_response_code_bucket.id
      key     = aws_s3_object.lambda_response_code.id
      version = aws_s3_object.lambda_response_code.version_id
    }
  }

  destination {
    s3 {
      bucket = aws_s3_bucket.lambda_response_code_bucket.id
      prefix = "signed/"
    }
  }

  ignore_signing_job_failure = true
}

resource "aws_lambda_code_signing_config" "tfsigner_response_code" {
  allowed_publishers {
    signing_profile_version_arns = [aws_signer_signing_profile.tfsigner_response.version_arn]
  }
  policies {
    untrusted_artifact_on_deployment = "Enforce"
  }
}

// Lambda
resource "aws_lambda_function" "lambda_response" {
  function_name = "tf-${var.function_name_two}"
  #s3_bucket     = aws_s3_bucket.lambda_response_code_bucket.id
  #s3_key        = "${var.function_name}.zip"
  role    = aws_iam_role.lambda_role_response.arn
  publish = true
  # Signer
  code_signing_config_arn = aws_lambda_code_signing_config.tfsigner_response_code.arn

  # S3 for signer configurations

  s3_bucket = aws_signer_signing_job.response_signer_jobs.signed_object[0].s3[0].bucket
  s3_key    = aws_signer_signing_job.response_signer_jobs.signed_object[0].s3[0].key

  # TODO
  # description      = "Upsert leads and individuals towards salesforce."
  # filename         = local.zip_file_path_response
  source_code_hash = data.archive_file.lambda_response_zip.output_base64sha256
  handler          = "mimicResponse.lambdaHandler"
  runtime          = "nodejs18.x"
  timeout          = 300
  memory_size      = 128
  //layers           = [aws_lambda_layer_version.dependencies_layer.arn]
  environment {
    variables = {
      # TODO: get from aws secrets
      # Hardcoded parameters despite password and secret keys input on aws lambda "by hand" - just for testing purposes
      MIMIC_TABLE = var.platform_name
    }
  }

  depends_on = [resource.aws_s3_object.lambda_response_code]
}

// Alias
resource "aws_lambda_alias" "alias_response" {
  name             = var.environment
  description      = "Latest function on ${var.environment} stage"
  function_name    = aws_lambda_function.lambda_response.function_name
  function_version = aws_lambda_function.lambda_response.version
}

