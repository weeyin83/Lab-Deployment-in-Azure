# Build Linux Server to use within the Lab

## Deploy the Azure lab

The first thing that you need to do is deploy the Azure virtual machine (VM) that will act as your on-prem environment.  You can start the deployment via the following button: 

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fweeyin83%2FLab-Deployment-in-Azure%2Fmain%2FVMdeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

_It can take 50-70 minutes for the lab to fully deploy._

# Table of contents

- [Set up the lab](#set-up-the-lab)
- [Download Ubuntu Server ISO](#download-ubuntu-server-iso)
- [Create the virtual machine](#create-the-virtual-machine)
- [Install operating system](#install-the-operating-system)

## Set up the lab

Once the Azure deployment has completed, there are a few things you need to do within the lab before you can start using it. 

* Log onto your Azure VM
* Launch Hyper-V
* Log onto AD01, the login name is **tailwindtraders\administrator** and the password is: demo@pass123 
* Configure the IP address to a static one, the configuration should be: 
    - IP Address: 192.168.0.2
    - Subnet Mask: 255.255.255.0
    - Default Gateway: 192.168.0.1
    - Preferred DNS: 127.0.0.1
    - Alternative DNS: 8.8.8.8
* For the other winodws servers configure the IP addresses as follows:

|  VM Name  | IP Address   | Subnet   |  Default Gateway | Preferred DNS | Alternative DNS |
|---|---|---|---|---|---|
|  AD01 |  192.168.0.2 | 255.255.255.0   |  192.168.0.1 | 192.168.0.2 | 8.8.8.8 |
|  FS01 | 192.168.0.3   | 255.255.255.0  |   192.168.0.1 | 192.168.0.2 | 8.8.8.8 |
| SQL01  | 192.168.0.4   | 255.255.255.0  |  192.168.0.1 | 192.168.0.2 | 8.8.8.8  |
| WEB01  | 192.168.0.5   | 255.255.255.0  |   192.168.0.1 | 192.168.0.2 | 8.8.8.8 |
* Log onto the Hyper-V Manager, right click on WEB02 and select **Delete**. We're going to create a new one. 

## Download Ubuntu Server ISO

You need to download the latest Ubuntu server ISO to create the virtual machine, you can grab that from here: [https://ubuntu.com/download/server)](https://ubuntu.com/download/server)

## Create the virtual machine

* Launch **Hyper-V Manager**
* Click on **New**
* Select **Virtual Machine**
* Select **Next**
* Give the server a name, I am going to use **WEB03**
* Tick **Store the virtual machine in a different location**
* Use **C:\VM** as the location, then select **Next**
* Select **Generation 1**, then select **Next**
* Type **2048** as the start up memory and select **Next**
* Select **Natswitch** for the connection and select **Next**
* Use **C:\VM** as the location, then tyle **40** as the size, then select **Next**
* Select **Install an operating system from a bootable CD/DVD-ROM** and then select **Image File**
* Browse to the location of the Ubuntu ISO you downloaded and then select **Finish**
* Right click on the new virtual machine and select **Settings**
* Give the virtual machine **2 virtual processors**
* And select **Dynamic memory** and give the virtual machine:
    - Minimum RAM: 512
    - Maximum RAM: 4000
* Click **OK**
* Right click on the new virtual machine and select **Start**

## Install the operating system
When you start the virtual machine it will automatically start the install of the operating system.  During the installation you will be asked several questions:

    - Language
    - Installer update available, it's okay to select continue without updating
    - Keyboard configuration
    - Type of install, select Ubuntu Server
    - Network connections, it should pick up the DHCP settings from AD01
    - Proxy connection, you can skip this
    - Ubuntu Archive Mirror, allow this to pass it's tests and then select done
    - Storage configuration, use the entire disk
    - Your name, a username and password.  This will be used as the main administrator of the server. 
    - Server name, I am using WEB03
    - You can skip the Ubuntu Pro configuration
    - SSH Setup, select the installation of OpenSSH server
    - Server features, you can select any additional packages you may want or skip this step

