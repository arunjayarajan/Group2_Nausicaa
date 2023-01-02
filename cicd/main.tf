# configure aws provider 
provider "aws" {
  region    = var.region
  profile   = "default"
}

# create iam roles
module "iam" {
  source        = "../modules/iam"
  project-name  = var.project-name
}

# create pipeline
module "pipeline" {
  source                      = "../modules/pipeline"
  project-name                = var.project-name
  codebuild-service-role-arn  = module.iam.build-iam-role-arn
  dockerhub-credentials       = var.dockerhub-credentials
  codepipeline-role-arn       = module.iam.pipeline-iam-role-arn
  codestar-credentials        = var.codestar-credentials
  aws-s3-bucket               = var.aws-s3-bucket
  #kms_key_arn                 = module.kms.kms-arn
  plan                        = var.plan
  apply                       = var.apply
}

# create s3 bucket
#module "s3" {
#  source = "../modules/s3"
#}

# create kms 
#module "kms" {
#  source                = "../modules/kms"
#  codepipeline-role-arn = module.iam.pipeline-iam-role-arn
#  account_id = module.security-token.account_id

#}

# create security token
module "security-token" {
  source = "../modules/security-token"
}