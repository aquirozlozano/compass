resource "aws_s3_object" "requirements_txt" {
  bucket = "compass-data-mwaa"
  key    = "${var.prefix}/requirements.txt"
  source = "files/requirements.txt"
  etag   = filemd5("files/requirements.txt")
}

resource "aws_s3_object" "plugins_zip" {
  bucket = "compass-data-mwaa"
  key    = "${var.prefix}/plugins.zip"
  source = "files/plugins.zip"
  etag   = filemd5("files/plugins.zip")
}