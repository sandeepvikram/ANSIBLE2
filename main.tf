terraform {
  required_providers {
    azurerm = {
      # ...
    }
  }
  required_version = ">= 0.13"
}

# This block goes outside of the required_providers block!
provider "azurerm" {
  features {}
}

resource   "azurerm_resource_group"   "rg"   { 
   name   =   "my-first-terraform-rg" 
   location   =   "southindia" 
 } 


resource   "azurerm_virtual_network"   "myvnet"   { 
   name   =   "my-vnet" 
   address_space   =   [ "10.0.0.0/16" ] 
   location   =   "southindia" 
   resource_group_name   =   azurerm_resource_group.rg.name 
 } 

 resource   "azurerm_subnet"   "frontendsubnet"   { 
   name   =   "frontendSubnet" 
   resource_group_name   =    azurerm_resource_group.rg.name 
   virtual_network_name   =   azurerm_virtual_network.myvnet.name 
   address_prefixes   =   ["10.0.1.0/24"] 
 }


resource   "azurerm_public_ip"   "myvm1publicip"   { 
   name   =   "pip1" 
   location   =   "southindia" 
   resource_group_name   =   azurerm_resource_group.rg.name 
   allocation_method   =   "Dynamic" 
   sku   =   "Basic" 
 } 


resource   "azurerm_network_interface"   "myvm1nic"   { 
   name   =   "myvm1-nic" 
   location   =   "southindia" 
   resource_group_name   =   azurerm_resource_group.rg.name 

   ip_configuration   { 
     name   =   "ipconfig1" 
     subnet_id   =   azurerm_subnet.frontendsubnet.id 
     private_ip_address_allocation   =   "Dynamic" 
     public_ip_address_id   =   azurerm_public_ip.myvm1publicip.id 
   } 
 }

resource "azurerm_network_security_group" "webnsg" {
    name                            = "webnsg"
    resource_group_name             = azurerm_resource_group.rg.name
    location                        = "southindia"
    security_rule {
        name                       = "openssh"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "openhttp"
        priority                   = 110
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
  
}

#az vm list-skus --location southindia --size Standard_D --all --output table


resource   "azurerm_linux_virtual_machine"   "example"   { 
   name                    =   "myvm1"   
   location                =   "southindia" 
   resource_group_name     =   azurerm_resource_group.rg.name 
   network_interface_ids   =   [ azurerm_network_interface.myvm1nic.id ] 
   size                    =   "Standard_D2ds_v5" 
   admin_username          =   "adminuser" 
   admin_password          =   "Password123!"
   disable_password_authentication     = false 

   source_image_reference   { 
     publisher   =   "Canonical" 
     offer       =   "UbuntuServer" 
     sku         =   "16.04-LTS" 
     version     =   "latest" 
   } 

   os_disk   { 
     caching                =   "ReadWrite" 
     storage_account_type   =   "Standard_LRS" 
   } 
 }


