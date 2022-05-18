
resource "azurerm_linux_virtual_machine" "web1vm" {
    name                                = "myvm1"
    resource_group_name                 = azurerm_resource_group.rg.name
    location                            = "northeurope"
    network_interface_ids               = [ azurerm_network_interface.myvm1nic.id ] 
    size                                = "Standard_B1s"
    os_disk {
        caching                         = "ReadWrite"
        storage_account_type            = "Standard_LRS"
    }
    admin_username                      = "adminuser"
    admin_password                      = "Password123!"
    disable_password_authentication     = false
    source_image_reference {
        publisher = "Canonical"
        offer     = "0001-com-ubuntu-server-focal"
        sku       = "20_04-lts-gen2"
        version   = "latest"
    }


    depends_on = [
      azurerm_network_interface.web_nic,
      azurerm_network_security_group.webnsg
    ]

}