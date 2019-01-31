<# 
Microsoft Lab Environment - Azure Backup
.File Name
 - HyperVHostConfig.ps1
 
.What calls this script?
 - 

.What does this script do?  
 - Creates an Internal Switch in Hyper-V called "NatSwitch"
    
 - Downloads an images of several servers for the lab environment

 - Repartitions the OS disk to 400GB in size

 - Add a new IP address to the Internal Network for Hyper-V attached to the NATSwitch

 - Creates a NAT Network on 192.168.2.0/24

 - Creates the Virtual Machines in Hyper-V

 - Issues a Start Command for the new VMs
#>

Configuration Main
{
	Param ( [string] $nodeName )

	Import-DscResource -ModuleName 'PSDesiredStateConfiguration', 'xHyper-V'

	node $nodeName
  	{
		# Ensures a VM with default settings
        xVMSwitch InternalSwitch
        {
            Ensure         = 'Present'
            Name           = 'NatSwitch'
            Type           = 'Internal'
        }
		
		Script ConfigureHyperV
    	{
			GetScript = 
			{
				@{Result = "ConfigureHyperV"}
			}	
		
			TestScript = 
			{
           		return $false
        	}	
		
			SetScript =
			{
				$zipDownload = "https://sarahlabfiles.blob.core.windows.net/backuplab/AzureLabVMs.zip"
				$downloadedFile = "D:\AzureLabVMs.zip"
				$vmFolder = "C:\VM"
				Resize-Partition -DiskNumber 0 -PartitionNumber 2 -Size (400GB)
				Invoke-WebRequest $zipDownload -OutFile $downloadedFile
				Add-Type -assembly "system.io.compression.filesystem"
				[io.compression.zipfile]::ExtractToDirectory($downloadedFile, $vmFolder)
				$NatSwitch = Get-NetAdapter -Name "vEthernet (NatSwitch)"
				New-NetIPAddress -IPAddress 192.168.2.1 -PrefixLength 24 -InterfaceIndex $NatSwitch.ifIndex
				New-NetNat -Name NestedVMNATnetwork -InternalIPInterfaceAddressPrefix 192.168.2.0/24 -Verbose
				New-VM -Name AD01 `
					   -MemoryStartupBytes 2GB `
					   -BootDevice VHD `
					   -VHDPath 'C:\VM\AD01.vhdx' `
                       -Path 'C:\VM' `
					   -Generation 1 `
				       -Switch "NATSwitch"
				Start-VM -Name AD01
				New-VM -Name FS01 `
				-MemoryStartupBytes 2GB `
				-BootDevice VHD `
				-VHDPath 'C:\VM\FS01.vhdx' `
				-Path 'C:\VM' `
				-Generation 1 `
				-Switch "NATSwitch"
				Start-VM -Name FS01
				New-VM -Name BP01 `
				-MemoryStartupBytes 8GB `
				-BootDevice VHD `
				-VHDPath 'C:\VM\BP01.vhdx' `
				-Path 'C:\VM' `
				-Generation 1 `
				-Switch "NATSwitch"
				Start-VM -Name BP01
			}
		}	
  	}
}