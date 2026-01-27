# 1. Провайдер та Група ресурсів
provider "azurerm" {
  features {}
  subscription_id = "8103f804-568e-4c9e-b325-a2d5578b24c2"
}

resource "azurerm_resource_group" "main" {
  name     = "rg-app-2026"
  location = "West Europe"
}

# 2. Мережева інфраструктура
resource "azurerm_virtual_network" "main" {
  name                = "vnet-main"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "frontend" {
  name                 = "snet-frontend"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "backend" {
  name                 = "snet-backend"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

# 3. Публічна IP для FrontEnd
resource "azurerm_public_ip" "frontend" {
  name                = "pip-frontend"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
}

# 4. Мережеві інтерфейси (NIC)
resource "azurerm_network_interface" "frontend" {
  name                = "nic-frontend"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.frontend.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.frontend.id
  }
}

resource "azurerm_network_interface" "backend" {
  name                = "nic-backend"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.backend.id
    private_ip_address_allocation = "Dynamic"
  }
}

# 5. Групи безпеки (NSG) - Дозволяємо HTTP та SSH для FrontEnd
resource "azurerm_network_security_group" "frontend" {
  name                = "nsg-frontend"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "frontend" {
  network_interface_id      = azurerm_network_interface.frontend.id
  network_security_group_id = azurerm_network_security_group.frontend.id
}

# 6. Віртуальні машини (Linux, Standard_B1s - 1 vCPU, 1GB RAM)
resource "azurerm_linux_virtual_machine" "frontend" {
  name                = "vm-frontend"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = "Standard_B1s"
  admin_username      = "azureuser"
  network_interface_ids = [azurerm_network_interface.frontend.id]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/owncloud/ANDOR/CREDENTIALS/azure/test_key.pub") # Шлях до вашого публічного ключа
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

resource "azurerm_linux_virtual_machine" "backend" {
  name                = "vm-backend"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = "Standard_B1s"
  admin_username      = "azureuser"
  network_interface_ids = [azurerm_network_interface.backend.id]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/owncloud/ANDOR/CREDENTIALS/azure/test_key.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

# Вивід публічної IP-адреси FrontEnd машини
output "frontend_public_ip" {
  description = "Публічна IP-адреса для доступу до FrontEnd"
  value       = azurerm_linux_virtual_machine.frontend.public_ip_address
}

# Додатково: Вивід приватної IP-адреси BackEnd машини
output "backend_private_ip" {
  description = "Внутрішня IP-адреса BackEnd машини"
  value       = azurerm_linux_virtual_machine.backend.private_ip_address
}
