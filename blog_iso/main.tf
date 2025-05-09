resource "proxmox_vm_qemu" "resource-name" {
  name        = "VM-name"
  target_node = "Node to create the VM on"

  disks {
    ide {
      ide2 {
        cdrom {
          iso = "ubuntu-24.04.2-live-server-amd64.iso"
        }
      }
    }
  }

  ### or for a Clone VM operation
  # clone = "template to clone"

  ### or for a PXE boot VM operation
  # pxe = true
  # boot = "scsi0;net0"
  # agent = 0
}