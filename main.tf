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

data "aws_lambda_function" "lambda_create_cart" {
  function_name = "createCart"
}

data "aws_lambda_function" "lambda_product_list" {
  function_name = "list-products"
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

# Integración para lambda createCart
resource "aws_apigatewayv2_integration" "create_cart_integration" {
  api_id                 = aws_apigatewayv2_api.api_gateway.id
  integration_type       = "AWS_PROXY"
  integration_uri        = data.aws_lambda_function.lambda_create_cart.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

# Integración para lambda produc list
resource "aws_apigatewayv2_integration" "product_list_integration" {
  api_id                 = aws_apigatewayv2_api.api_gateway.id
  integration_type       = "AWS_PROXY"
  integration_uri        = data.aws_lambda_function.lambda_product_list.invoke_arn
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

# Ruta POST /cart/create → lambda_create_cart
resource "aws_apigatewayv2_route" "create_cart_route" {
  api_id    = aws_apigatewayv2_api.api_gateway.id
  route_key = "POST /cart/create"
  target    = "integrations/${aws_apigatewayv2_integration.create_cart_integration.id}"
}

# Ruta GET /products/list → lambda_list_products
resource "aws_apigatewayv2_route" "product_list_route" {
  api_id    = aws_apigatewayv2_api.api_gateway.id
  route_key = "GET /products/list"
  target    = "integrations/${aws_apigatewayv2_integration.product_list_integration.id}"
}

# Implementación del deployment
resource "aws_apigatewayv2_stage" "api_stage" {
  api_id      = aws_apigatewayv2_api.api_gateway.id
  name        = "$default"
  auto_deploy = true
}

# Permisos para que API Gateway invoque lambda_register
resource "aws_lambda_permission" "register_permission" {
  statement_id  = "AllowAPIGatewayInvokeRegisterV2"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.lambda_register.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api_gateway.execution_arn}/*/*"
}

# Permisos para que API Gateway invoque lambda_login
resource "aws_lambda_permission" "login_permission" {
  statement_id  = "AllowAPIGatewayInvokeLoginV2"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.lambda_login.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api_gateway.execution_arn}/*/*"
}

# Permisos para que API Gateway invoque lambda_create_cart
resource "aws_lambda_permission" "create_cart_permission" {
  statement_id  = "AllowAPIGatewayInvokeCreateCart"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.lambda_create_cart.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api_gateway.execution_arn}/*/*"
}

# Permisos para que API Gateway invoque lambda_product_list
resource "aws_lambda_permission" "product_list_permission" {
  statement_id  = "AllowAPIGatewayInvokeProductList"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.lambda_product_list.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api_gateway.execution_arn}/*/*"
}