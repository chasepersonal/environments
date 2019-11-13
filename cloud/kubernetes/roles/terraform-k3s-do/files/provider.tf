variable "digitalocean_token" {}
variable "ssh_fingerprint" {}

provider "digitalocean" {
  token = "${var.digitalocean_token}"
}