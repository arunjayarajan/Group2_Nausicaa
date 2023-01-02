output "aws-code-pipeline-s3-bucket" {
  value = aws_s3_bucket.codepipeline_artifacts.id
}