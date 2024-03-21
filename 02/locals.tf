locals {
  vm_names = {
    web = "${var.vm_web_name}-${var.vpc_name}"
    db  = "${var.vm_db_name}-${var.db_vpc_name}"
  }
  resources = {
    web = {
        cores         = var.vm_web_cores
        memory        = var.vm_web_memory
        core_fraction = var.vm_web_core_fraction
    },
    db = {
        cores         = var.db_cores  
        memory        = var.db_memory  
        core_fraction = var.db_core_fraction  
    }
  }
}
