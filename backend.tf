terraform {
  backend "s3" {
    bucket         = "your-terraform-state-bucket-name" # ZASTĄP NAZWĄ SWOJEGO BUCKETA
    key            = "path/to/key/terraform.tfstate"    # ZOSTANIE NADPISANE W KONFIGURACJI ŚRODOWISKA
    region         = "us-east-1"                        # ZMIEŃ NA SWÓJ REGION
    dynamodb_table = "your-terraform-state-lock-table"  # ZASTĄP NAZWĄ SWOJEJ TABELI
    encrypt        = true
  }
}
