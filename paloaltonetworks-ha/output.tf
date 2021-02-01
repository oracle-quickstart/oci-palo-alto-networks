## Copyright © 2020, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

output "subscription" {
  value = data.oci_core_app_catalog_subscriptions.mp_image_subscription.*.app_catalog_subscriptions
}

output "firewallA_instance_public_ips" {
  value = [oci_core_instance.ha-vms[0].*.public_ip]
}

output "firewallA_instance_private_ips" {
  value = [oci_core_instance.ha-vms[0].*.private_ip]
}

output "firewallB_instance_public_ips" {
  value = [oci_core_instance.ha-vms[1].*.public_ip]
}

output "firewallB_instance_private_ips" {
  value = [oci_core_instance.ha-vms[1].*.private_ip]
}

output "instance_https_urls" {
  value = formatlist("https://%s", oci_core_instance.ha-vms.*.public_ip)
}

output "initial_instruction" {
value = <<EOT
1.  Open an SSH client.
2.  Use the following information to connect to the instance
username: admin
IP_Address: ${oci_core_instance.ha-vms.0.public_ip}
SSH Key
For example:
$ ssh –i id_rsa admin@${oci_core_instance.ha-vms.0.public_ip}
3.  Set the user password for the administrator. 
    - Enter the command: set user admin password
    - Change the password using command: set mgt-config users admin password
4. Save the configuration. Enter the command: commit
After saving the password, you should run the first time wizard in the VM Series UI:
1.  In a web browser, connect to the VM Series UI: https://${oci_core_instance.ha-vms.0.public_ip}
2.  Follow the First Time Configuration Wizard.
3.  For additional details follow the documentation.
EOT
}
