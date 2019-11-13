resource "digitalocean_droplet" "k3s-master-1" {
    image = "debian-10-x64"
    name = "k3s-m-0"
    region = "nyc1"
    size = "2GB"
    ssh_keys = [
      "${var.ssh_fingerprint}"
    ]
}

resource "digitalocean_droplet" "k3s-worker-1" {
    image = "debian-10-x64"
    name = "k3s-w-0"
    region = "nyc1"
    size = "2GB"
    ssh_keys = [
      "${var.ssh_fingerprint}"
    ]
}

resource "digitalocean_droplet" "k3s-worker-2" {
    image = "debian-10-x64"
    name = "k3s-w-1"
    region = "nyc1"
    size = "2GB"
    ssh_keys = [
      "${var.ssh_fingerprint}"
    ]
}

output "k3s-m-0" {
    value = "${digitalocean_droplet.k3s-master-1.ipv4_address}"
}

output "k3s-w-0" {
    value = "${digitalocean_droplet.k3s-worker-1.ipv4_address}"
}

output "k3s-w-1" {
    value = "${digitalocean_droplet.k3s-worker-2.ipv4_address}"
}