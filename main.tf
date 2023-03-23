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

provider "digitalocean" {
  token = var.do_token
}

provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
  api_url = var.datadog_api_url
}

resource "digitalocean_droplet" "web1" {
  image  = "ubuntu-18-04-x64"
  name   = var.web_srv1
  region = "ams3"
  size   = "s-1vcpu-1gb"
}

resource "digitalocean_droplet" "web2" {
  image  = "ubuntu-18-04-x64"
  name   = var.web_srv2
  region = "ams3"
  size   = "s-1vcpu-1gb"
}

resource "datadog_monitor" "cpumonitor" {
  name = "cpu monitor"
  type = "metric alert"
  message = "CPU usage alert"
  query = "avg(last_1m):avg:system.cpu.system{*} by {host} > 60"
}
