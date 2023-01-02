resource "aws_s3_bucket" "codepipeline_artifacts" {
  bucket = "pipeline-artifacts-nausicaa"
} 


resource "aws_s3_bucket_acl" "codepipeline_artifacts_bucket_acl" {
  bucket = aws_s3_bucket.codepipeline_artifacts.id
  acl    = "private"
}


resource "aws_s3_bucket_versioning" "codepipeline_artifacts" {
  bucket = aws_s3_bucket.codepipeline_artifacts.id

  versioning_configuration {
    status = "Enabled"
  }
}