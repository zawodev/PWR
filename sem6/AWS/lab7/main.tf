provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "qr_bucket" {
  bucket = var.bucket_name

  tags = {
    Name = "QR Code Bucket"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.qr_bucket.id

  block_public_acls = false
  block_public_policy = false
  ignore_public_acls = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "public_policy" {
  bucket = aws_s3_bucket.qr_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid = "PublicReadGetObject",
        Effect = "Allow",
        Principal = "*",
        Action = "s3:GetObject",
        Resource = "${aws_s3_bucket.qr_bucket.arn}/*"
      }
    ]
  })
}

data "aws_iam_role" "lambda_role" {
  name = var.lambda_role_name
}

resource "aws_lambda_function" "qr_generator" {
  function_name = var.lambda_fun_name
  role = data.aws_iam_role.lambda_role.arn
  filename = var.lambda_zip_file
  handler = var.lambda_handler
  runtime = var.lambda_runtime
  source_code_hash = filebase64sha256(var.lambda_zip_file)

  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.qr_bucket.bucket
      REGION_NAME = var.region
    }
  }

  timeout = 10
  tags = {
    Name = "qr-generator-lambda"
  }
}

resource "aws_apigatewayv2_api" "qr_api" {
  name = var.api_name
  protocol_type = "HTTP"
}

resource "aws_lambda_permission" "allow_apigw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.qr_generator.function_name
  principal = "apigateway.amazonaws.com"
  source_arn = "${aws_apigatewayv2_api.qr_api.execution_arn}/*/*"
}

resource "aws_apigatewayv2_integration" "qr_integration" {
  api_id = aws_apigatewayv2_api.qr_api.id
  integration_type = "AWS_PROXY"
  integration_uri = aws_lambda_function.qr_generator.invoke_arn
  integration_method = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "generate_route" {
  api_id = aws_apigatewayv2_api.qr_api.id
  route_key = "POST /generate"

  target = "integrations/${aws_apigatewayv2_integration.qr_integration.id}"
}

resource "aws_apigatewayv2_stage" "default_stage" {
  api_id = aws_apigatewayv2_api.qr_api.id
  name = var.api_stage_name
  auto_deploy = true
}
