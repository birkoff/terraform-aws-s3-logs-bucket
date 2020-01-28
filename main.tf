data "aws_elb_service_account" "main" {}

data "aws_iam_policy_document" "bucket_policy" {
  statement {
    sid       = "AllowToPutLogsToS3Bucket"
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${var.name}/*/AWSLogs/${var.account_id}/*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_elb_service_account.main.id}:root"]
    }
  }
}

resource "aws_s3_bucket" "logs-bucket" {
  bucket = "${var.name}"
  acl    = "log-delivery-write"
  policy = "${data.aws_iam_policy_document.bucket_policy.json}"

  force_destroy = true

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = "${merge(map("Name", var.name))}"
}
