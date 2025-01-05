


#s3
resource "aws_s3_bucket" "django_s3" {
  bucket = "homme-django-static-media"

  tags = { 
    Name = "django-s3-bucket" 
  }
}

resource "aws_s3_bucket_ownership_controls" "django_s3_bucket_ownership" {
  bucket = aws_s3_bucket.django_s3.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "django_s3_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.django_s3_bucket_ownership]

  bucket = aws_s3_bucket.django_s3.id
  acl    = "private"
}

#iam
resource "aws_s3_bucket_policy" "allow_access_to_s3_policy" {
  bucket = aws_s3_bucket.django_s3.id
  policy = data.aws_iam_policy_document.allow_access_to_s3.json
}

data "aws_iam_policy_document" "allow_access_to_s3" {
  statement { 
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${aws_s3_bucket.django_s3.arn}/*",
    ]
  }
}

resource "aws_iam_user" "s3_access_iam_user" {
  name = "homme-s3-user"
  permissions_boundary = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

#ecr
resource "aws_ecr_repository" "django_aws_repo" {
  name                 = "django-aws-app"
  image_tag_mutability = "MUTABLE" 
  tags = {
    Name = "DjangoAWSAppECR"
  }
}

resource "aws_ecr_repository_policy" "django_aws_policy" {
  repository = aws_ecr_repository.django_aws_repo.name

  policy = data.aws_iam_policy_document.ecr_policy.json
}

data "aws_iam_policy_document" "ecr_policy" {
  statement {
    sid    = "PublicRead"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability"
    ]
  }
}

