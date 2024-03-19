variable "zones" {
  type        = list(string)
  description = "List of zones to use for resources"
  default     = ["ru-central1-a", "ru-central1-b"]
}

#variable "zone-1" {
#  default = "ru-central1-a"
#}

#variable "zone-2" {
#  default = "ru-central1-b"
#}



resource "yandex_vpc_network" "develop" {
  name = var.vpc_name
}

resource "yandex_vpc_subnet" "develop" {
  name           = var.subnet_name
  zone           = var.zones[0]
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = var.default_cidr
}


data "yandex_compute_image" "ubuntu" {
  family = var.image_family
}

resource "yandex_compute_instance" "platform" {
  name        = local.vm_names["web"]
  platform_id = var.vm_web_platform_id
  zone        = var.zones[0]
  resources {
#    cores         = var.vm_web_cores
#    memory        = var.vm_web_memory
#    core_fraction = var.vm_web_core_fraction
#  }
  cores = local.resources["web"]["cores"]
  memory = local.resources["web"]["memory"]
  core_fraction = local.resources["web"]["core_fraction"]
  }
  
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }
  
  scheduling_policy {
    preemptible = true
  }
  
  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = true
  }

  metadata = {
    serial-port-enable = 1
    ssh-keys = var.vm_metadata
}
}

#netology-develop-platform-db

resource "yandex_vpc_network" "develop_db" {
  name = var.db_vpc_name
}

resource "yandex_vpc_subnet" "develop_db" {
  name           = var.db_subnet_name
  zone           = var.zones[1]
  network_id     = yandex_vpc_network.develop_db.id
  v4_cidr_blocks = var.db_default_cidr
}

data "yandex_compute_image" "db_ubuntu" {
  family = var.db_image_family
}

resource "yandex_compute_instance" "platform_db" {
  name        = local.vm_names["db"]
  platform_id = var.vm_db_platform_id
  zone        = var.zones[1]
  resources {
#    cores         = var.db_cores
#    memory        = var.db_memory
#    core_fraction = var.db_core_fraction
#  }
  cores = local.resources["db"]["cores"]
  memory = local.resources["db"]["memory"]
  core_fraction = local.resources["db"]["core_fraction"]
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }
  
  scheduling_policy {
    preemptible = true
  }
  
  network_interface {
    subnet_id = yandex_vpc_subnet.develop_db.id
    nat       = true
  }

  metadata = {
    serial-port-enable = 1
    ssh-keys = var.vm_metadata
}
}

output "instance_details" {
  value = {
    netology-develop-platform-web = {
      instance_name = yandex_compute_instance.platform.name
      external_ip   = yandex_compute_instance.platform.network_interface[0].nat_ip_address
      fqdn          = "${yandex_compute_instance.platform.network_interface[0].nat_ip_address}.platform-web"
    }
    netology-develop-platform-db = {
      instance_name = yandex_compute_instance.platform_db.name
      external_ip   = yandex_compute_instance.platform_db.network_interface[0].nat_ip_address
      fqdn          = "${yandex_compute_instance.platform_db.network_interface[0].nat_ip_address}.platform-db"
    }
  }
}
