terraform {
  backend "remote" {
    organization = "Domjgiordano"

    workspaces {
      name = "angular-spotify-infrastructure"
    }
  }
}

data "aws_caller_identity" "web_app_account" {
  provider = aws
}
