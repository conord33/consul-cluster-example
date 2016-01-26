variable "region" {
  default = "us-central1"
}

variable "region_zone" {
  default = "us-central1-a"
}

variable "project_name" {
  description = "The ID of the Google Cloud project"
}

variable "account_file_path" {
  description = "Path to the JSON file used to describe your account credentials"
}

variable "server_count" {
  description = "The number of consul servers to spin up. 3 or 5 is recommended"
  default = 3
}

variable "user" {
  description = "The ssh user of the machine"
}

variable "private_key_path" {
  description = "The path to the ssh private key"
  default = "~/.ssh/id_rsa"
}

variable "public_key_path" {
  description = "The path to the ssh public key"
  default = "~/.ssh/id_rsa.pub"
}
