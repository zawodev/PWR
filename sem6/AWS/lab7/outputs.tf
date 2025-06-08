output "invoke_url" {
  value = "${aws_apigatewayv2_api.qr_api.api_endpoint}/${var.api_stage_name}/generate"
}
