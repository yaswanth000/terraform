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

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "index.py"
  output_path = "index_payload.zip"
}

resource "aws_lambda_function" "mylambda" {
  role          = aws_iam_role.iam_for_lambda.arn
  function_name = "samplefunction"
  runtime       = "python3.9"
  handler       = "index.lambda_handler"
  architectures = ["x86_64"]

  # Zip file code
  filename         = data.archive_file.lambda.output_path
  source_code_hash = filebase64sha256(data.archive_file.lambda.output_path)
}
