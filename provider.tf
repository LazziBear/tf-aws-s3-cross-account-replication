provider "aws" {
  alias  = "source"
  region = "us-east-1"
  assume_role {
    role_arn = "arn:aws:iam::338521073506:role/deployment" // Dev
    # role_arn     = "arn:aws:iam::218980707526:role/deployment"  // Live
    # role_arn     = "arn:aws:iam::785617728136:role/deployment"  // Main

    session_name = "deployment"
  }
}

provider "aws" {
  alias  = "dest"
  region = "us-east-1"
  assume_role {
    role_arn = "arn:aws:iam::338521073506:role/deployment" // Dev
    # role_arn     = "arn:aws:iam::218980707526:role/deployment"  // Live
    # role_arn     = "arn:aws:iam::785617728136:role/deployment"  // Main

    session_name = "deployment"
  }
}