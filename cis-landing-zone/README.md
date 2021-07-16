# CIS Landing Zone - Palo Alto Networks 

CIS Landing Zone template deploys a standardized environment in an Oracle Cloud Infrastructure (OCI) tenancy that helps organizations to comply with the [CIS OCI Foundations Benchmark v1.1](https://www.cisecurity.org/benchmark/oracle_cloud/). In this repo, you will be utilizing CIS landing Zone which you have created successfully then deploy Palo Alto Networks VM Series Firewall in high availability use-case i.e. active/passive with dynamic routing gateway to communicate between VCNs. 

For details of CIS Landing Zone, see [_CIS Landing Zone Enviornment_](https://github.com/oracle-quickstart/oci-cis-landingzone-quickstart).

## Validated Version Details

We have validated v10.0.3 PAN VM Series Firewall for this architecture.

## Prerequisites

You should complete below pre-requisites before proceeding to next section:
- You have an active Oracle Cloud Infrastructure Account.
  - Tenancy OCID, User OCID, Compartment OCID, Private and Public Keys are setup properly.
- Permission to `manage` the following types of resources in your Oracle Cloud Infrastructure tenancy: `vcns`, `internet-gateways`, `route-tables`, `security-lists`,`dynamic-routing-gateways`, `subnets`, `network-load-balancers` and `instances`.
- Quota to create the following resources: 3 VCNS, 6 subnets, and 6 compute instance.
- Successfully Run CIS landing zone hub/spoke architecture which supports Firewall Use-Case. 
  - You will need to follow **Executing Instructions** outlined on [CIS Landing Zone Page](https://github.com/oracle-quickstart/oci-cis-landingzone-quickstart)
  - You will be using some output variables from this pre-req work in your deployment. 

## Deployment Options

You can deploy this architecture using two approach explained in each section: 
1. Using Oracle Resource Manager 
2. Using Terraform CLI 

## Deploy Using Oracle Resource Manager

In this section you will follow each steps given below to create this architecture:

1. Click [![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://console.us-phoenix-1.oraclecloud.com/resourcemanager/stacks/create?region=home&zipUrl=https://github.com/oracle-quickstart/oci-palo-alto-networks/raw/master/cis-landing-zone/resource-manager/cis-landing-zone.zip)

    > If you aren't already signed in, when prompted, enter the tenancy and user credentials.

2. Review and accept the terms and conditions.

3. Select the region where you want to deploy the stack.

4. Follow the on-screen prompts and instructions to create the stack.

5. After creating the stack, click **Terraform Actions**, and select **Plan** from the stack on OCI console UI.

6. Wait for the job to be completed, and review the plan.

    > To make any changes, return to the Stack Details page, click **Edit Stack**, and make the required changes. Then, run the **Plan** action again.

7. If no further changes are necessary, return to the Stack Details page, click **Terraform Actions**, and select **Apply**. 

8. At this stage your architecture should have been deployed successfully. You can proceed to next section for configuring your Palo Alto Networks VM Series Firewall.

9. If you no longer require your infrastructure, return to the Stack Details page and **Terraform Actions**, and select **Destroy**.

## Deploy Using the Terraform CLI

In this section you will use **Terraform** locally to create this architecture: 

1. Create a local copy of this repo using below command on your terminal: 

    ```
    git clone https://github.com/oracle-quickstart/oci-paloaltonetworks.git
    cd oci-paloaltonetworks/cis-landing-zone/
    ls
    ```

2. Complete the prerequisites described [here] which are associated to install **Terraform** locally:(https://github.com/oracle-quickstart/oci-prerequisites#install-terraform).
    Make sure you have terraform v0.13+ cli installed and accessible from your terminal.

    ```bash
    terraform -v

    Terraform v0.13.0
    + provider.oci v4.14.0
    ```

3. Create a `terraform.tfvars` file in your **paloaltonetworks-ha** directory, and specify the following variables:

    ```
    # Authentication
    tenancy_ocid         = "<tenancy_ocid>"
    user_ocid            = "<user_ocid>"
    fingerprint          = "<finger_print>"
    private_key_path     = "<pem_private_key_pem_file_path>"
    private_key_password = "<pem_private_key_pem_file_password>"

    # SSH Keys
    ssh_public_key  = "<public_ssh_key_string_value>"

    # Region
    region = "<oci_region>"

    # CIS Benchmark Variabls
    network_compartment      = <cis_network_compartment_ocid>
    drg_ocid                 = <cis_drg_ocid>
    firewall_vcn             = <cis_firewall_dmz_hub_vcn_ocid>
    db_vcn                   = <cis_db_vcn_ocid>
    web_vcn                  = <cis_web_vcn_ocid>
    service_label            = <cis_service_label_used>
    vcn_names                = <cis_vcn_names_used>: Example: ["web", "db"]
    vcn_cidrs                = <cis_vcn_cidrs_used>: Example: ["10.0.0.0/20", "10.0.16.0/20"]
    ````

4. Create the Resources using the following commands:

    ```bash
    terraform init
    terraform plan
    terraform apply
    ```

5. At this stage your architecture should have been deployed successfully. You can proceed to configuring your Palo Alto Networks VM Series Firewall. 

6. If you no longer require your infrastructure, you can run this command to destroy the resources:

    ```bash
    terraform destroy
    ```

## Palo Alto Networks Subnets/Interfaces Mapping

Since you are using **CIS landing zone** to create your environment, you will see different subnet name but to clear any confusion you can follow table which reflect subnet names as per VM Series Firewall standards: 

    | Recommended  | Used Name                                |
    |--------------|------------------------------------------|
    | Management   | Mgmt                                     |
    | Untrust      | Outdoor                                  |
    | Trust        | Indoor                                   |
    | HA           | HA                                       |


## Feedback 

Feedbacks are welcome to this repo, please open a PR if you have any.