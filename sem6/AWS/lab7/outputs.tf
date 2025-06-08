output "invoke_url" {
  value = "${aws_apigatewayv2_api.qr_api.api_endpoint}/generate"
}
