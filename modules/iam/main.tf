resource "aws_iam_role" "codepipeline_role" {
  name = "${var.project-name}-codepipeline_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

data "aws_iam_policy_document" "pipeline_policies" {
    statement{
        sid = ""
        actions = ["codestar-connections:UseConnection"]
        resources = ["*"]
        effect = "Allow"
    }
    statement{
        sid = ""
        actions = ["cloudwatch:*", "s3:*", "codebuild:*"]
        resources = ["*"]
        effect = "Allow"
    }
}

resource "aws_iam_policy" "pipeline_policy" {
    name = "${var.project-name}-pipeline_policy"
    path = "/"
    description = "Pipeline policy"
    policy = data.aws_iam_policy_document.pipeline_policies.json
}

resource "aws_iam_role_policy_attachment" "pipeline-attachment" {
    policy_arn = aws_iam_policy.pipeline_policy.arn
    role = aws_iam_role.codepipeline_role.id
}


resource "aws_iam_role" "codebuild_role" {
  name = "${var.project-name}-codebuild_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

data "aws_iam_policy_document" "build_policies" {
    statement{
        sid = ""
        actions = ["logs:*", "s3:*", "codebuild:*", "secretsmanager:*","iam:*"]
        resources = ["*"]
        effect = "Allow"
    }
}

resource "aws_iam_policy" "build_policy" {
    name = "${var.project-name}-build_policy"
    path = "/"
    description = "Codebuild policy"
    policy = data.aws_iam_policy_document.build_policies.json
}

resource "aws_iam_role_policy_attachment" "codebuild-attachment1" {
    policy_arn  = aws_iam_policy.build_policy.arn
    role        = aws_iam_role.codebuild_role.id
}

resource "aws_iam_role_policy_attachment" "tf-cicd-codebuild-attachment2" {
    policy_arn  = "arn:aws:iam::aws:policy/PowerUserAccess"
    role        = aws_iam_role.codebuild_role.id
}
