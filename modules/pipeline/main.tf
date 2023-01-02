resource "aws_codebuild_project" "tf-plan" {
  name          = "${var.project-name}-build-plan"
  description   = "Plan stage for terraform"
  service_role  = var.codebuild-service-role-arn

  artifacts {
    type = "NO_ARTIFACTS"
   
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    #registry_credential{
     #   credential = var.dockerhub-credentials
      #  credential_provider = "SECRETS_MANAGER"
    #}

         
 }
 source {
     type   = "GITHUB"
     location = "https://github.com/chimezirimugochukwu/Group2_Nausicaa.git"
     git_clone_depth = 1

     git_submodules_config {
        fetch_submodules = true
     }   
       
 }
 source_version = "resources"
}

resource "aws_codebuild_project" "tf-apply" {
  name          = "${var.project-name}-build-apply"
  description   = "Apply stage for terraform"
  service_role  = var.codebuild-service-role-arn

  artifacts {
    type = "CODEPIPELINE"
    
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "hashicorp/terraform:latest"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"
    registry_credential{
        credential = var.dockerhub-credentials
        credential_provider = "SECRETS_MANAGER"
    }

       
 }
 source {
     type   = "CODEPIPELINE"
     buildspec = file("${var.apply}")
       
 }
}


resource "aws_codepipeline" "cicd_pipeline" {

    name = "${var.project-name}-cicd-pipeline"
    role_arn = var.codepipeline-role-arn

    artifact_store {
        type="S3"
        location = var.aws-s3-bucket
        #encryption_key {
         #   id   = var.kms_key_arn
          #  type = "KMS"
        #}    
    }

    stage {
        name = "Source"
        action{
            name = "Source"
            category = "Source"
            owner = "AWS"
            provider = "CodeStarSourceConnection"
            version = "1"
            output_artifacts = ["tf-code"]
            configuration = {
                FullRepositoryId = "chimezirimugochukwu/Group2_Nausicaa"
                BranchName   = "resources"
                ConnectionArn = var.codestar-credentials
                OutputArtifactFormat = "CODE_ZIP"
            }
        }
    }

    stage {
        name ="Plan"
        action{
            name = "Build"
            category = "Build"
            provider = "CodeBuild"
            version = "1"
            owner = "AWS"
            input_artifacts = ["tf-code"]
            output_artifacts = ["plan-code"]
            configuration = {
                ProjectName = "${var.project-name}-cicd-plan"
            }
        }
    }

    stage {
        name ="Deploy"
        action{
            name = "Deploy"
            category = "Build"
            provider = "CodeBuild"
            version = "1"
            owner = "AWS"
            input_artifacts = ["plan-code"]
            configuration = {
                ProjectName = "${var.project-name}-cicd-apply"
                EnvironmentVariables = jsonencode([
                    {
                        name  = "MY_ENVIRONMENT"
                        value = "production"
                        type  = "PLAINTEXT"
                    }
                ])     
            }
        }
    }

}