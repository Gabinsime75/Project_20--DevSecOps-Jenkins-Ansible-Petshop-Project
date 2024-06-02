terraform {
  backend "s3" {
    bucket         = "proj20-backend-bucket"
    key            = "Jenkins/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "proj18-dbtable"
  }
}
