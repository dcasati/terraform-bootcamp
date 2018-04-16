# DevOps in Practice: 
## Deploying Infrastructure as Code with Terraform on Azure

This tutorial walks you through the deplyment of a VM with Terraform on Microsoft Azure.

## Target Audience

The target audience for this tutorial is someone that is looking for a hands-on introduction on Terraform.

## Solution Details

1. Setup Terraform on Azure.
1. Configure the Terraform template.
1. Plan the new infrastructure template.
1. Apply the new infrastructure template.
1. Destroy the infrastructure.

## Prerequisites

For these exercises, you will need:

* A [Github](https://github.com/) account
* An [Azure](https://azure.microsoft.com/) account
* The Terraform [binary](https://www.terraform.io/downloads.html)

Another option is to use the Cloud Shell on Azure at [https://shell.azure.com](https://shell.azure.com)

The examples here will use [Microsoft Azure](https://azure.microsoft.com/en-us/). For more information please refer to the Before You Begin section.

While Azure is used for basic infrastructure requirements most of the lessons learned in this tutorial can be applied to other platforms that support Kubernetes.

## Before You Begin

For this solution, you will need:

* An account on [Microsoft Azure](https://azure.microsoft.com). You can
create your Azure account for [free](https://azure.microsoft.com/en-us/free/)

* Azure CLI 2.0 (more instructions below)

## Microsoft Azure CLI 2.0

### Install the Microsoft Azure CLI 2.0

Follow the Azure CLI 2.0 [documentation](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) to install the `az` command line utility. You can install utility in various platforms such as macOS, Windows, Linux (various distros) and as a Docker container.

The examples here are based on the version 2.0.18 of the utility. You can verify the version of the tool by running:

```
az --version
```

> Note: If this is your first time using the Azure CLI tool, you can familiarize yourself with it's syntax and command options by running `az interactive`

### First Things First

Before we can use Azure, your first step, aside from having an account, is to login. Once Azure CLI is installed, open up a terminal and run the following:

```
az login
```

This will prompt you to sign in using a web browser to https://aka.ms/devicelogin and to enter the displayed code. This single step is needed in order to allow `az` to talk back to Azure.

## Basic setup - Do this before proceeding

The first thing you should do is to clone this repo as most of the examples here will do relative reference to files.
 

Before we proceed, please do this now:

1. Clone this repo:
  ```bash
  git clone https://github.com/dcasati/terraform-bootcamp.git
  ```
2. If you are using VS Code, install the Terraform extension:

![vs-terraform|20%](images/vs-terraform.png)

## What is Infrastructure as Code anyway - aka IaC?

### What is it?

In a nutshell - 

> "This allows a blueprint of your datacenter to be versioned and treated as
> you would any other code. Additionally, infrastructure can be shared and re-used."
>
> -- <cite>www.terraform.io/intro</cite>

![Infrastructure as Code](images/iac-book.jpg)

### Why use it?

> "The goal of DevOps is to make software delivery more efficient.""
>
> -- <cite>Yevgeniy Brikman on Terraform Up and Running</cite>

<br/>
Infrastructure as Code: 

- **SPEEDS** up the deployment of new infrastructure

- **ALLOWS** you to version control your infrastructure, making it easy to perform roll-backs

- **ENABLES** a repeatable model for deploying your infrastructure, reducing the "fat-finger-effect"

### Trade-offs

Using Infrastructure as Code brings some important considerations: 

- How to provide file isolation, file locking and safeguard the state of the infrastructure managed by Terraform? 

- Declarative vs Imperative.

The good: 

  - Its clear, concise, reproducible method are a plus. 
  
The bad: 

  - The drawback to have in mind is this: when not careful, a commit can break your entire infrastructure. 
  
The ugly: 

  - This could be your production.red[*] and staging environment.

*Version control and file isolation can mitigate most of these issues.

## Terraform

### What is Terraform ?

Terraform is a tool for building, changing, and versioning infrastructure safely and efficiently. Terraform can manage existing and popular 
service providers as well as custom in-house solutions.

Configuration files describe to Terraform the components needed to run a single application or your entire datacenter. 
Terraform generates an execution plan describing what it will do to reach the desired state, and then executes it to build the 
described infrastructure. As the configuration changes, Terraform is able to determine what changed and create incremental execution 
plans which can be applied.

The infrastructure Terraform can manage includes low-level components such as compute instances, storage, and networking, as well 
as high-level components such as DNS entries, SaaS features, etc.

More on the [Terraform website](http://www.terraform.io).

### - Installing Terraform

Terraform is distributed as a binary package for various OSes, including: Linux, MacOS, OpenBSD, FreeBSD, Windows and Solaris.

Download the binary at: [https://www.terraform.io/downloads.html](https://www.terraform.io/downloads.html)

Another option is to use the Cloud Shell on Azure at [https://shell.azure.com](https://shell.azure.com)

### - Verifying the Installation

Run the following command on a terminal: `terraform`. You should see an output similar to this:

```bash
$ terraform
Usage: terraform [--version] [--help] <command> [args]

The available commands for execution are listed below.
The most common, useful commands are shown first, followed by
less common or more advanced commands. If you're just getting
started with Terraform, stick with the common commands. For the
other commands, please read the help and docs before usage.

Common commands:
    apply              Builds or changes infrastructure
    console            Interactive console for Terraform interpolations
    destroy            Destroy Terraform-managed infrastructure
    env                Workspace management
    fmt                Rewrites config files to canonical format
    get                Download and install modules for the configuration
    graph              Create a visual graph of Terraform resources
    import             Import existing infrastructure into Terraform
    init               Initialize a Terraform working directory
    output             Read an output from a state file
    plan               Generate and show an execution plan
    providers          Prints a tree of the providers used in the configuration
    push               Upload this Terraform module to Atlas to run
    refresh            Update local state file against real resources
    show               Inspect Terraform state or plan
```

### - Setting up access to Azure

Terraform uses an Azure AD service principal to provision resources on Azure. Here we have two options:

1. Manually setup the service principal as described [here](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/terraform-install-configure#set-up-terraform-access-to-azure)
1. Use the [setup_terraform.sh](https://github.com/dcasati/terraform-bootcamp/blob/master/tools/setup_terraform.sh) found under the `tools/` directory. 

Procedure:

1. If not done already, log into Azure
   ```bash
   $ az login
   ```
1. Next, select a SUBSCRIPTION
   ```bash
   $ az account list -o table
   ```
1. The output should look similar to this

<pre><code>
  Name                                CloudName    SubscriptionId  State    IsDefault
  ----------------------------------  -----------  --------------  -------  ---------
  Microsoft Azure Sponsorship         AzureCloud   XXXXXXXX-XXXX.  Enabled  
  Visual Studio Enterprise            AzureCloud   XXXXXXXX-XXXX.  Enabled  True
</code></pre>

Execute the `setup_terraform.sh` script:

  ```bash
  $ cd tools/
  $ chmod +x setup_terraform.sh
  $ SUBSCRIPTION=XXXXXXXXXX
  $ ./setup_terraform.sh -s $SUBSCRIPTION
  ```

  OUTPUT
  ```bash
  Setting up the subscription
  ----------------------------------------------------------
  $ az account set --subscription=XXXXXXXXXXXXX
  Retrying role assignment creation: 1/36
  Setting environment variables for Terraform
  ----------------------------------------------------------
  $ source terraform.rc
  Here are the Terraform environment variables for your setup
  ----------------------------------------------------------
  export ARM_SUBSCRIPTION_ID="XXXXXXXXX"
  export ARM_CLIENT_ID="XXXXXXXXX"
  export ARM_CLIENT_SECRET="XXXXXXXX"
  export ARM_TENANT_ID="XXXXXXX"
  ----------------------------------------------------------
  Setup is done. Your Terraform variables were saved on the terraform.rc file.
  ```
]
## Ready ? Let's try this !

### Running a sample script: init, plan, apply and destroy

1. Create a test file with the following information.red[*]:
  ```bash
  provider "azurerm" {
  }
  resource "azurerm_resource_group" "rg" {
          name = "testResourceGroup"
          location = "westus"
  }
  ```
  
1. then run `terraform init` to bootstrap Terraform.

1. verify what will be created with `terraform plan`

1. create the infrastructure with `terraform apply`

1. clean up with `terraform destroy`

* Or use the file under the `labs` directory

## Let's see that in action
### - init
  
Run `terraform init` to bootstrap Terraform.

  ```bash
  $ terraform init

  Initializing provider plugins...
  - Checking for available provider plugins on https://releases.hashicorp.com...
  - Downloading plugin for provider "azurerm" (1.3.2)...

  The following providers do not have any version constraints in configuration,
  so the latest version was installed.

  To prevent automatic upgrades to new major versions that may contain breaking
  changes, it is recommended to add version = "..." constraints to the
  corresponding provider blocks in configuration, with the constraint strings
  suggested below.

  * provider.azurerm: version = "~> 1.3"

  Terraform has been successfully initialized!

  You may now begin working with Terraform. Try running "terraform plan" to see
  any changes that are required for your infrastructure. All Terraform commands
  should now work.

  If you ever set or change modules or backend configuration for Terraform,
  rerun this command to reinitialize your working directory. If you forget, other
  commands will detect it and remind you to do so if necessary.
  ```
### - plan

Verify what will be created with `terraform plan`

<pre><code>
  $ terraform plan
  Refreshing Terraform state in-memory prior to plan...
  The refreshed state will be used to calculate this plan, but will not be
  persisted to local or remote state storage.
  ------------------------------------------------------------------------
  
  An execution plan has been generated and is shown below.
  Resource actions are indicated with the following symbols:
    + create
  
  Terraform will perform the following actions:
  
    + azurerm_resource_group.rg
        id:       <computed>
        location: "westus"
        name:     "testResourceGroup"
        tags.%:   <computed>
  
  
  Plan: 1 to add, 0 to change, 0 to destroy.
  ------------------------------------------------------------------------

  Note: You didn't specify an "-out" parameter to save this plan, so Terraform
  can't guarantee that exactly these actions will be performed if
  "terraform apply" is subsequently run.
</code></pre>

### - apply

Create the infrastructure with `terraform apply`
<pre><code>
  $ terraform apply
  An execution plan has been generated and is shown below.
  Resource actions are indicated with the following symbols:
    + create

  Terraform will perform the following actions:
    + azurerm_resource_group.rg
        id:       <computed>
        location: "westus"
        name:     "testResourceGroup"
        tags.%:   <computed>

  Plan: 1 to add, 0 to change, 0 to destroy.

  Do you want to perform these actions?
    Terraform will perform the actions described above.
    Only 'yes' will be accepted to approve.

    Enter a value: yes

  azurerm_resource_group.rg: Creating...
    location: "" => "westus"
    name:     "" => "testResourceGroup"
    tags.%:   "" => "<computed>"
  azurerm_resource_group.rg: Creation complete after 2s

  Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
</code></pre>

### - destroy

Finally clean up with `terraform destroy`

```bash
  $ terraform destroy
  azurerm_resource_group.rg: Refreshing state...
  
  An execution plan has been generated and is shown below.
  Resource actions are indicated with the following symbols:
    - destroy
  
  Terraform will perform the following actions:
  
    - azurerm_resource_group.rg
  
  
  Plan: 0 to add, 0 to change, 1 to destroy.
  
  Do you really want to destroy?
    Terraform will destroy all your managed infrastructure, as shown above.
    There is no undo. Only 'yes' will be accepted to confirm.
  
    Enter a value: yes
  
  azurerm_resource_group.rg: Destroying...
  azurerm_resource_group.rg: Destruction complete after 47s
  
  Destroy complete! Resources: 1 destroyed.
```

## Next: Let's create something more interesting

### Bootcamp infra

![Our architecture](images/diagram.png)
  
### - Core files

Reference files are under: `labs/bootcamp/`

| File         | Comment       |
|:------------- |:------------- |
| main.tf      | This is our core file. All of the definitions are here |
| outputs.tf   | Defines the output from `terraform show` |
| variables.tf | Defines the variables and default values used on `main.tf` |
| common.tfvars| User defined values for the variables.red[*] |

We will also run a few commands after the VM is up and running as defined on the file
`tools/addons.sh`.

```bash
#!/bin/bash

apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y lynx

apt-get install cowsay && cowsay "Howdy Azure Bootcamp!" > /tmp/cowsay.txt
```

* You will be editing this file.

### - Default values

The following table shows our default values:

| Parameter | Default Value |
| :- | :- |
| vm_size | Standard A0 |
| location | East US |
| Admin user.red[*] | azureuser |
| VNet | 10.0.0.0/16 |
| Management Subnet | 10.0.1.0/24 |


* Admin user will connect with ssh using public and private key pair

## What resources are we creating ? 

- azurerm_resource_group
- azurerm_virtual_network
- azurerm_subnet
- azurerm_network_security_group
- azurerm_network_interface
- azurerm_public_ip
- azurerm_storage_account
- azurerm_managed_disk
- azurerm_virtual_machine
- azurerm_virtual_machine_extension

## Deploying the bootcamp VM

1. `terraform init`
1. `terraform plan -var-file=common.tfvars -out bootcamp-infra`
1. `terraform apply "bootcamp-infra"`
1. Connect to the vm: `terraform show`

```bash
ssh azureuser@<publicIp>
```

## Cleaning up

1. `terraform destroy -var-file=common.tfvars`

Say `yes` when you see this prompt:

<pre><code>
  Do you really want to destroy?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: .red[yes]
</code></pre>

## Next Steps

- Terraform Examples on Azure [https://github.com/hashicorp/terraform/tree/master/examples](https://github.com/hashicorp/terraform/tree/master/examples)

- Terraform Resources on Azure: [https://www.terraform.io/docs/providers/azurerm/index.html](https://www.terraform.io/docs/providers/azurerm/index.html)

- Terraform Up and Running - Awesome book on Terraform !
