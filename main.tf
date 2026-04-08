terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 3.75.0"
    }
  }
}

provider "azurerm" {
  features {}

  skip_provider_registration = true
  client_id                  = "eefdc920-b24b-4425-b49d-1a37b0174eb2"
  client_secret              = "n.U8Q~Hxv94r30sPR57JY54PQT.EohMOHjUX5bdB"
  subscription_id            = "2035eca4-de6a-4fed-8299-b95d04f814de"
  tenant_id                  = "64c23c00-02d1-468f-bec7-729bb820a50e"
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "portfolio-project-rg-new"
  location = "Japan east"
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "portfolio-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Subnet
resource "azurerm_subnet" "subnet" {
  name                 = "portfolio-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Public IP
resource "azurerm_public_ip" "public_ip" {
  name                = "portfolio-public-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# NSG
resource "azurerm_network_security_group" "nsg" {
  name                = "portfolio-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# NIC
resource "azurerm_network_interface" "nic" {
  name                = "portfolio-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  depends_on = [
    azurerm_subnet.subnet,
    azurerm_public_ip.public_ip
  ]

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Associate NSG
resource "azurerm_network_interface_security_group_association" "nsg_assoc" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# VM
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "portfolio-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_D2s_v3"
  admin_username      = "azureuser"

  disable_password_authentication = false
  admin_password                  = "Sushmitha@12345"

  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  depends_on = [
    azurerm_network_interface.nic
  ]

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

  custom_data = base64encode(<<EOF
#!/bin/bash
apt update -y
apt install nginx -y
systemctl start nginx
systemctl enable nginx

cat <<'HTML' > /var/www/html/index.html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Sushmitha Kanathala | DevOps Portfolio</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      margin: 0;
      padding: 0;
      background: #f4f6f9;
      color: #333;
    }
.container {
  max-width: 1000px;
  margin: auto;
  padding: 40px 20px;
}

header {
  text-align: center;
  padding-bottom: 30px;
  border-bottom: 1px solid #334155;
}

header h1 {
  font-size: 36px;
  margin-bottom: 10px;
  color: #38bdf8;
}

header p {
  font-size: 18px;
  color: #cbd5f5;
}

.profile-pic {
  width: 140px;
  height: 140px;
  border-radius: 50%;
  border: 4px solid #38bdf8;
  object-fit: cover;
  position: absolute;
  top: 20px;
  right: 20px;
}

section {
  margin-top: 40px;
}

section h2 {
  font-size: 26px;
  color: #38bdf8;
  margin-bottom: 15px;
  border-left: 5px solid #38bdf8;
  padding-left: 10px;
}

.about p {
  font-size: 17px;
  line-height: 1.8;
  color: #d1d5db;
}

.skills {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  gap: 20px;
}

.skill-card {
  background-color: #020617;
  padding: 20px;
  border-radius: 10px;
  box-shadow: 0 0 15px rgba(56,189,248,0.1);
}

.skill-card h3 {
  margin-bottom: 10px;
  color: #22d3ee;
  font-size: 20px;
}

.skill-card ul {
  list-style: none;
  padding: 0;
}

.skill-card ul li {
  padding: 6px 0;
  border-bottom: 1px solid #1e293b;
}

footer {
  text-align: center;
  margin-top: 60px;
  padding-top: 20px;
  border-top: 1px solid #334155;
  color: #94a3b8;
}
  </style>
</head>
<body>
<img src="https://${azurerm_storage_account.portfolio_sa.name}.blob.core.windows.net/${azurerm_storage_container.images.name}/${azurerm_storage_blob.profile_photo.name}"
     class="profile-pic"
     alt="Profile Photo">

<div class="container">

<header>
  <h1>Sushmitha Kanathala</h1>
  <p>Cloud & DevOps Engineer</p>
</header>

<section>
  <h2>Objective</h2>
  <p>Motivated Cloud & DevOps Engineer trained in Azure and Terraform with project experience in automation, networking, and container deployment.</p>
</section>

<section>
  <h2>Education</h2>
  <ul>
    <li>B.Tech in ECE – CGPA: 7.5 (2025) - Annamacharya Institute of Technology</li>
    <li>Diploma in ECE – CGPA: 7.1 (2022)</li>
    <li>SSC – CGPA: 9.5 (2018)</li>
  </ul>
</section>

<section>
  <h2>Technical Skills</h2>
  <ul>
    <li>AWS (EC2, VPC)</li>
    <li>Docker & Kubernetes</li>
    <li>Terraform</li>
    <li>Jenkins</li>
    <li>Git & GitHub</li>
    <li>Linux</li>
  </ul>
</section>

<section>
  <h2>Projects</h2>
  <h3>AWS 3-Tier Architecture</h3>
  <p>Deployed a 3-tier architecture using AWS services.</p>

  <h3>CI/CD Pipeline</h3>
  <p>Automated pipeline using Jenkins and Docker.</p>
</section>

<section>
  <h2>Contact</h2>
  <p>Email: your-email@example.com</p>
  <p>GitHub: https://github.com/your-profile</p>
  <p>LinkedIn: https://linkedin.com/in/your-profile</p>
</section>

<footer>
  <p>© 2026 Sushmitha Kanathala</p>
</footer>

</body>
</html>
HTML
EOF
  )
}

# Output
output "public_ip" {
  value = azurerm_public_ip.public_ip.ip_address
}
