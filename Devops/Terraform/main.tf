data "template_file" "bucket_policy" {
  template = file("./website_bucket_policy.json")

  vars = {
    bucket = var.bucket_name
  }
}

resource "aws_s3_bucket" "prod_media" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.prod_media.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false

  depends_on = [aws_s3_bucket.prod_media]
}

resource "aws_s3_bucket_acl" "prod_media" {
  bucket = aws_s3_bucket.prod_media.id
  acl    = "public-read-write"

  depends_on = [aws_s3_bucket.prod_media]
}

resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.prod_media.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }

  depends_on = [aws_s3_bucket.prod_media]
}

resource "aws_s3_bucket_policy" "prod_media_bucket" {
  bucket = aws_s3_bucket.prod_media.id
  policy = data.template_file.bucket_policy.rendered

  depends_on = [aws_s3_bucket.prod_media]
}

# Rest of your configuration...
