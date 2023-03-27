terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
    datadog = {
      source = "DataDog/datadog"
    }
  }
}

variable "do_token" {}

variable "datadog_api_key" {}

variable "datadog_app_key" {}

variable "datadog_api_url" {}

variable "web_srv1" {}

variable "web_srv2" {}

variable "web_srv3" {}

provider "digitalocean" {
  token = var.do_token
}

provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
  api_url = var.datadog_api_url
}

resource "datadog_monitor" "cpumonitor" {
  name = "cpu monitor"
  type = "metric alert"
  message = "CPU usage alert"
  query = "avg(last_1m):avg:system.cpu.system{*} by {host} > 60"
}

resource "digitalocean_ssh_key" "my_ssh_key" {
  name = "new_ssh_key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "digitalocean_droplet" "web1" {
  image      = "ubuntu-18-04-x64"
  name       = var.web_srv1
  region     = "ams3"
  size       = "s-1vcpu-2gb"
  ssh_keys   = [digitalocean_ssh_key.my_ssh_key.fingerprint]

  connection {
    host = self.ipv4_address
    user = "root"
    type = "ssh"
    private_key = file("~/.ssh/id_rsa")
    timeout = "3m"
  }
  
  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install -y nginx",
      "echo '<h1><center>' > /var/www/html/index.html",
      "echo 'Servername: ' >> /var/www/html/index.html",
      "echo $(uname -n) >> /var/www/html/index.html",
      "echo '</center></h1>' >> /var/www/html/index.html"
    ]
  }
}

resource "digitalocean_droplet" "web2" {
  image      = "ubuntu-18-04-x64"
  name       = var.web_srv2
  region     = "ams3"
  size       = "s-1vcpu-2gb"
  ssh_keys   = [digitalocean_ssh_key.my_ssh_key.fingerprint]

  connection {
    host = self.ipv4_address
    user = "root"
    type = "ssh"
    private_key = file("~/.ssh/id_rsa")
    timeout = "3m"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install -y nginx",
      "echo '<h1><center>' > /var/www/html/index.html",
      "echo 'Servername: ' >> /var/www/html/index.html",
      "echo $(uname -n) >> /var/www/html/index.html",
      "echo '</center></h1>' >> /var/www/html/index.html"
    ]
  }
}

resource "digitalocean_droplet" "web3" {
  image      = "ubuntu-18-04-x64"
  name       = var.web_srv3
  region     = "ams3"
  size       = "s-1vcpu-2gb"
  ssh_keys   = [digitalocean_ssh_key.my_ssh_key.fingerprint]

  connection {
    host = self.ipv4_address
    user = "root"
    type = "ssh"
    private_key = file("~/.ssh/id_rsa")
    timeout = "3m"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install -y nginx",
      "echo '<h1><center>' > /var/www/html/index.html",
      "echo 'Servername: ' >> /var/www/html/index.html",
      "echo $(uname -n) >> /var/www/html/index.html",
      "echo '</center></h1>' >> /var/www/html/index.html"
    ]
  }
}

resource "digitalocean_loadbalancer" "www-lb" {
  name = "www-lb"
  region = "ams3"

  forwarding_rule {
    entry_port = 80
    entry_protocol = "http"

    target_port = 80
    target_protocol = "http"
  }

  healthcheck {
    port = 22
    protocol = "tcp"
  }

  droplet_ids = [digitalocean_droplet.web1.id,
                 digitalocean_droplet.web2.id,
                 digitalocean_droplet.web3.id]
}

resource "digitalocean_domain" "default" {
   name = "naturalwines.ge"
   ip_address = digitalocean_loadbalancer.www-lb.ip
}
