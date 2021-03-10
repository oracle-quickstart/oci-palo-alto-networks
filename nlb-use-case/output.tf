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
    - Enter the command to go to config mode: configure
    - Change the password using command: set mgt-config users admin password
4. Save the configuration. Enter the command: commit

After saving the password, you should be able to connect to VM Series UI using admin/<password_set>:
1.  In a web browser, 
    - Connect to the VM Series UI Firewall-1: https://${oci_core_instance.ha-vms.0.public_ip}
    - Connect to the VM Series UI Firewall-2: https://${oci_core_instance.ha-vms.1.public_ip}
2.  For additional details follow the official documentation.
EOT
}
