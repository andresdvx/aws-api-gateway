output "api_gateway_url" {
  description = "URL base de la API Gateway"
  value       = aws_apigatewayv2_api.api_gateway.api_endpoint
}
