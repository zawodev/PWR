variable "region" {
  default = "us-east-1"
}

variable "bucket_name" {
  default = "qr-code-bucket"
}

variable "lambda_fun_name" {
  default = "qr-code-generator"
}

variable "lambda_zip_file" {
  default = "lambda_qr_generator.zip"
}

variable "lambda_handler" {
  default = "lambda_function.lambda_handler"
}

variable "lambda_runtime" {
  default = "python3.12"
}

variable "lambda_role_name" {
  default = "LabRole"
}

variable "api_name" {
  default = "qr-code-api"
}

variable "api_stage_name" { 
  default = "$generate"
}