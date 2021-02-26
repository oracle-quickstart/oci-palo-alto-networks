# Palo Alto Networks VM Series Firewall - Reference Architecture

We are using hub-and-spoke network (often called star topology) has a central component (the hub) that's connected to multiple networks around it, like a wheel. Implementing this topology in the traditional data center can be costly. But in the Oracle Cloud, there’s no extra cost.

For details of the architecture, see [_Set up a hub-and-spoke network topology_](https://docs.oracle.com/en/solutions/hub-spoke-network/index.html).

## Prerequisites

- We'll need to do some pre deploy setup.  That's all detailed [here](https://github.com/oracle/oci-quickstart-prerequisites).
- Permission to `manage` the following types of resources in your Oracle Cloud Infrastructure tenancy: `vcns`, `internet-gateways`, `route-tables`, `security-lists`, `local-peering-gateways`, `subnets`, `dynamic-groups` and `instances`.
- Quota to create the following resources: 3 VCNS, 6 subnets, and 6 compute instance.

If you don't have the required permissions and quota, contact your tenancy administrator. See [Policy Reference](https://docs.cloud.oracle.com/en-us/iaas/Content/Identity/Reference/policyreference.htm), [Service Limits](https://docs.cloud.oracle.com/en-us/iaas/Content/General/Concepts/servicelimits.htm), [Compartment Quotas](https://docs.cloud.oracle.com/iaas/Content/General/Concepts/resourcequotas.htm).

## Deploy Using Oracle Resource Manager

1. Click [![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://console.us-phoenix-1.oraclecloud.com/resourcemanager/stacks/create?region=home&zipUrl=https://github.com/oracle-quickstart/oci-paloaltonetworks/raw/master/paloaltonetworks-ha/resource-manager/pan-ha.zip)

    If you aren't already signed in, when prompted, enter the tenancy and user credentials.

2. Review and accept the terms and conditions.

3. Select the region where you want to deploy the stack.

4. Follow the on-screen prompts and instructions to create the stack.

5. After creating the stack, click **Terraform Actions**, and select **Plan**.

6. Wait for the job to be completed, and review the plan.

    To make any changes, return to the Stack Details page, click **Edit Stack**, and make the required changes. Then, run the **Plan** action again.

7. If no further changes are necessary, return to the Stack Details page, click **Terraform Actions**, and select **Apply**. 


## Deploy Using the Terraform CLI

Make sure you have terraform v0.13+ cli installed and accessible from your terminal.

```bash
terraform -v

Terraform v0.13.0
+ provider.oci v4.14.0
```

### Clone the Module
Create a local copy of this repository:

    git clone https://github.com/oracle-quickstart/oci-paloaltonetworks.git
    cd oci-paloaltonetworks
    git checkout pan-reference-architecture  ## This will be updated.
    ls

### Set Up and Configure Terraform

1. Complete the prerequisites described [here](https://github.com/cloud-partners/oci-prerequisites).

2. Create a `terraform.tfvars` file, and specify the following variables:

    ```
    # Authentication
    tenancy_ocid         = "<tenancy_ocid>"
    user_ocid            = "<user_ocid>"
    fingerprint          = "<finger_print>"
    private_key_path     = "<pem_private_key_path>"

    # SSH Keys
    ssh_public_key  = "<public_ssh_key_path>"

    # Region
    region = "<oci_region>"

    # Compartment
    compute_compartment_ocid = "<compartment_ocid>"
    network_compartment_ocid = "<network_compartment_ocid>"
    availability_domain_number = "<availability_domain_number>

    ````

### Create the Resources
Run the following commands:

    terraform init
    terraform plan
    terraform apply

### Destroy the Deployment
When you no longer need the deployment, you can run this command to destroy the resources:

    terraform destroy

## Architecture Diagram

![](./images/hub-spoke-diagram.png)


## Palo Alto Networks Firewall Configuration 

This section will include necessary configuration which you need to configure to support HA (active/passive) use-case. 

Once you deploy the infrastructure either using Oracle Resource Manager or Terraform CLI. We have to upload configuration on Palo Alto Networks VM series Firewall. 


> This section will be automated as Palo Alto Networks personal add bootstrap configuration using either user-data or bucket. You can follow  [Config Directory](./config-ha) directory for the time being to support routes, policies, interfaces, HA config. 

Before you proceed to next section, you should setup a admin password through CLI (Instrcutions are printed after a successful run of this code) using below commands: 

```
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
1.  In a web browser, 
    - Connect to the VM Series UI Firewall-1: https://${oci_core_instance.ha-vms.0.public_ip}
    - Connect to the VM Series UI Firewall-2: https://${oci_core_instance.ha-vms.1.public_ip}
```

### Firewall-1 Configuration 

We have added required configuration for Palo Alto Networks Firewall 1 (HA Cluster First Instance) [Firewall A Configuration](./config-ha/firewallA.xml). You can use this as a reference and upload this on your Firewall. Configuration should be same but you can compare your configuration with your Firewall Instances.

1. Connect to Firewall UI 
2. Go to Device > Operation Tab 
3. Select Import Configuration and Choose FirewallA.xml file described here. 
4. Now Select Load Configuration and choose file from dropdown which you just imported. 
5. Verify Configuration; Interfaces, Security Policies, NAT Policies, Default Routes, Address Objects
6. Commit your changes


Once you commit your change you won't be able to use your previously set admin password, you should use `admin/Pal0Alt0@123` login details to UI now. 

At some point you will need to enable jumbo frame you can do this using below steps: 
1. Connect to Firewall UI 
2. Select Device > Session > Setting > Setting button 
3. Check jumbo frame icon. 

### Firewall-2 Configuration 


We have added required configuration for Palo Alto Networks Firewall 2 (HA Cluster Second Instance) [Firewall B Configuration](./config-ha/firewallB.xml). You can use this as a reference and upload this on your Firewall. Configuration should be same but you can compare your configuration with your Firewall Instances.

1. Connect to Firewall UI 
2. Go to Device > Operation Tab 
3. Select Import Configuration and Choose FirewallA.xml file described here. 
4. Now Select Load Configuration and choose file from dropdown which you just imported. 
5. Verify Configuration; Interfaces, Security Policies, NAT Policies, Default Routes, Address Objects
6. Commit your changes

Once you commit your change you won't be able to use your previously set admin password, you should use `admin/Pal0Alt0@123` login details to UI now. 

At some point you will need to enable jumbo frame you can do this using below steps: 
1. Connect to Firewall UI 
2. Select Device > Session > Setting > Setting button 
3. Check jumbo frame icon. 


#### Some Sample Configuration Pics on Palo Alto Networks Firewall 

I am attaching some sample configuration from one of the Firewall-B for your reference as below: 

1. Interfaces Configuration 
    - Ethernet1/1 ; Trust Interface 
    - Ethernet1/2 ; Untrust Interface 
    - Ethernet1/3 ; HA Interface

![](./images/FirewallB_Interfaces.png)


2. Security Policies 
    - Untrust to Trust and Vice Versa 
    - Intra Zone Policies 

![](./images/FirewallB_Policies.png)

3. HA Communication 
    - HA 1 is tied to Managment Interface 
    - HA 2 is tied to ethernet1/3 interface 

![](./images/FirewallB_HA.png)


4. Default Routes Configuration 
    - Default route via untrust interface gateway (eth1/2)
    - Static Routes for Spoke VCNs and Oracle Storage Networks via trust interface gateway (eth1/1)

![](./images/FirewallB_Routes.png)

5. NAT Policies 
    - We have two NAT policies 
        - First: Traffic to Web Spoke VCN so end user can connect to VM from outside using public IP of untrust interface of Firewall (Floating IP)
        - Second: Traffic towards interent from Spoke VCNs

6. Jumbo Frame Configuration 
    - End user need to enable this manually and restart each firewall VM afterwards. 
    - Below image shows where you need to go to enable jumbo frame. 

![](./images/FirewallB_JumboFrame.png)



## Feedback 

Feedbacks are welcome to this repo, please open a PR if you have any.