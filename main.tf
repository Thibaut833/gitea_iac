terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "2.9.14"
    }
  }
}

provider "proxmox" {
  pm_api_url = var.prox_url
  pm_user = var.prox_user
  pm_password = var.prox_pass
}

resource "proxmox_vm_qemu" "gitea" {
  name = "gitea"
  cores = 2
  sockets = 1
  cpu = "host"
  memory  = 2048
  target_node = "prox"
  full_clone = true
  clone = "debian12"
  pool = "VM"
  os_type = "cloud-init"
  ipconfig0 = "ip=${var.ip_gitea},gw=${var.ip_gtw}"
  onboot = true
}

resource "null_resource" "ansible" {
  provisioner "local-exec" {
    command = "sleep 60 && ansible-playbook --user=ansible --vault-pass-file=passvault.txt --private-key=ansible --inventory=inventories/gitea/hosts gitea.yml"
  }
  depends_on = [proxmox_vm_qemu.gitea]
  
}
