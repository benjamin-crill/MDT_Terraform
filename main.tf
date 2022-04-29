terraform {
  required_providers {
    nutanix = {
      source  = "nutanix/nutanix"
      version = "1.4.0"
    }
  }
}

locals {
    current_timestamp  = timestamp()
    current_day        = formatdate("YYYY-MM-DD", local.current_timestamp)
}

data "nutanix_cluster" "cluster" {
  name = var.cluster_name
}
data "nutanix_subnet" "subnet" {
  subnet_name = var.subnet_name
}

provider "nutanix" {
  username     = var.user
  password     = var.password
  endpoint     = var.endpoint
  insecure     = true
  wait_timeout = 60
}

resource "nutanix_virtual_machine" "vm" {
  name                 = "${var.vmname}${local.current_day}"
  description          = "created on this date"
  cluster_uuid         = data.nutanix_cluster.cluster.id
  num_vcpus_per_socket = "2"
  num_sockets          = "1"
  memory_size_mib      = 4096

  disk_list {
    disk_size_bytes = 70 * 1024 * 1024 * 1024
    device_properties {
      device_type = "DISK"
      disk_address = {
        "adapter_type" = "SCSI"
        "device_index" = "1"
      }
    }
  }
  nic_list {
    subnet_uuid = data.nutanix_subnet.subnet.id
  }
}
