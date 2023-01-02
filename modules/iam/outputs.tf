output "build-iam-role-arn" {
  value = aws_iam_role.codebuild_role.arn
}

output "pipeline-iam-role-arn" {
  value = aws_iam_role.codepipeline_role.arn
}
