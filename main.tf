provider "aws" {
  region = var.region
}

# Referencias a las Lambdas existentes
data "aws_lambda_function" "lambda_register" {
  function_name = "lambda_register"
}

data "aws_lambda_function" "lambda_login" {
  function_name = "lambda_login"
}

# Crear API Gateway HTTP
resource "aws_apigatewayv2_api" "api_gateway" {
  name          = var.api_name
  protocol_type = "HTTP"
}

# Integración para lambda_register
resource "aws_apigatewayv2_integration" "register_integration" {
  api_id                 = aws_apigatewayv2_api.api_gateway.id
  integration_type       = "AWS_PROXY"
  integration_uri        = data.aws_lambda_function.lambda_register.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

# Integración para lambda_login
resource "aws_apigatewayv2_integration" "login_integration" {
  api_id                 = aws_apigatewayv2_api.api_gateway.id
  integration_type       = "AWS_PROXY"
  integration_uri        = data.aws_lambda_function.lambda_login.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

# Ruta POST /user/register → lambda_register
resource "aws_apigatewayv2_route" "register_route" {
  api_id    = aws_apigatewayv2_api.api_gateway.id
  route_key = "POST /user/register"
  target    = "integrations/${aws_apigatewayv2_integration.register_integration.id}"
}

# Ruta POST /user/login → lambda_login
resource "aws_apigatewayv2_route" "login_route" {
  api_id    = aws_apigatewayv2_api.api_gateway.id
  route_key = "POST /user/login"
  target    = "integrations/${aws_apigatewayv2_integration.login_integration.id}"
}

# Implementación del deployment
resource "aws_apigatewayv2_stage" "api_stage" {
  api_id      = aws_apigatewayv2_api.api_gateway.id
  name        = "$default"
  auto_deploy = true
}

# Permisos para que API Gateway invoque lambda_register
resource "aws_lambda_permission" "register_permission" {
  statement_id  = "AllowAPIGatewayInvokeRegister"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.lambda_register.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api_gateway.execution_arn}/*/*"
}

# Permisos para que API Gateway invoque lambda_login
resource "aws_lambda_permission" "login_permission" {
  statement_id  = "AllowAPIGatewayInvokeLogin"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.lambda_login.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api_gateway.execution_arn}/*/*"
}

