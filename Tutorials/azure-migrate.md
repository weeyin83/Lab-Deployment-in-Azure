# Assess the lab with Azure Migrate

## Deploy the Azure lab

The first that that you need to do is deploy the Azure virtual machine (VM) that will act as your on-prem environment.  You can start the deployment via the following button: 

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fweeyin83%2FLab-Deployment-in-Azure%2Fmain%2FVMdeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

_It can take 50-70 minutes for the lab to fully deploy._

## Set up the lab

Once the Azure deployment has completed, there are a few things you need to do within the lab before you can start using it. 

* Log onto your Azure VM
* Launch Hyper-V
* Log onto AD01, the login name is **tailwindtraders\administrator** and the password is: **Password**: demo@pass123 
* Configure the IP address to a static one, the configuration should be: 
    - IP Address: 192.168.0.2
    - Subnet Mask: 255.255.255.0
    - Default Gateway: 192.168.0.1
    - Preferred DNS: 127.0.0.1
    - Alternative DNS: 8.8.8.8
* Restart the 4 other servers hosted within the Hyper-V environment _(Restarting them will force them all to pick up an IP address from the AD01 server)_

## Discover with Azure Migrate

We are going to deploy Azure Migrate within our lab environment to assess the servers and look start the process for a migration.  Because we can't access the hypervisor layer we are going to treat our servers as if they were physical servers and deploy Azure Migrate in that manner. 

### Build a server to install Azure Migrate on

We need to build a server that can host the Azure Migrate software within our environment.  

* Obtain an ISO for Windows Server 2022 and store it within your Azure VM
* Open **Hyper-V Manager** within your Azure VM
* From the **Action** pane, click **New**, and then click **Virtual Machine**
* From the **New Virtual Machine Wizard**, click **Next**
* You will be asked to provide some information on the server:
    * Name
    * Generation: Specify Generation 1
    * Memory: Assign at least 8GB of memory
    * Networking: Select
    * Hard Disk: Specify at least 80GB
    * Select the Windows Server 2022 ISO for the operation system
* After verifying your choices in the **Summary** page, click **Finish**
* Once the VM is created, within the **Hyper-V Manager** tool, right click on the new VM
* Select **Settings**
* Ensure 8 virtual processors are assigned to the VM
* Click **OK**
* Now right click on the VM and select **Start**
* Walk through the process of installing the operating system
* When the VM has installed the operating system, we need to configure some settings within the VM
* Within the **Server Manager** click on **Local Server**
* Click on the **Computer Name** and give the server an appropriate name, click **OK** and restart the server
* When the VM restarts, within the **Server Manager** click on **Local Server**
* Click on the **IE Enchanced Security Configuration** setting and ensure it is turned off
* Now click on the **Ethernet** setting to launch the networking configuration window
* Right click on the network adapter and select **Properties**
* Click on **Internet Protocol Version 4 (TCP/IPv4)** and select **Properties**
* Configure the IP address to a static one, the configuration should be: 
    - IP Address: 192.168.0.7
    - Subnet Mask: 255.255.255.0
    - Default Gateway: 192.168.0.1
    - Preferred DNS: 192.168.0.2
    - Alternative DNS: 8.8.8.8

### Create an Azure Migrate project

* In the Azure portal > All services, search for Azure Migrate
* Under Services, select Azure Migrate
* In Overview, select Create project
* In Create project, select your Azure subscription and resource group. Create a resource group if you don't have one
* In Project Details, specify the project name and the geography in which you want to create the project
* Select Create
