<#
.SYNOPSIS
    VMs creation.
.DESCRIPTION
    Create multiple VMs on the vCenter.
.NOTES
    File name : Create-VM.ps1
    Author : Pierre JACQUOT
    Date : 20/06/2017
    Version : 1.0
.LINK
    Website : https://www.pierrejacquot.go.yo.fr
    Reference : https://www.pierrejacquot.go.yo.fr/index.php/scripts/42-script-create-vm
#>

Clear-Host

## Log files creation ##
Function Write-Log([string]$Output, [string]$Message) {
    Write-Verbose $Message
    ((Get-Date -UFormat "[%d-%m-%Y %H:%M:%S] ") + $Message) | Out-File -FilePath $Output -Append -Force
}

## List of variables ##
$StartTime = Get-Date
$Hostname = [Environment]::MachineName
$FullLogin = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$Login = [Environment]::UserName
$Workfolder = Split-Path $script:MyInvocation.MyCommand.Path
$Date = Get-Date -UFormat "%Y-%m-%d"
$LogFile = $Workfolder + "\Logs\$Date-Create-VMs.log"
$TargetOU = "Path of your OU. Example : OU=Servers,DC=test,DC=local"

## Collect information from XML ##
$xml = [xml](Get-Content -Path ".\XML\VM-Configuration.xml")
$Node = $xml.selectnodes("//CreateVM/VM")
$VMNumber = $Node.Count

## Title of the script ##
Write-Host "############################################################################"
Write-Host "#    Script : Create-VM    |    Version : 1.0    |    Date : $Date    #"
Write-Host "############################################################################"
Write-Host "`r"

## Importing Active Directory module for Windows PowerShell ##
$Module = Get-Module -List ActiveDirectory
Import-Module ActiveDirectory -ErrorAction SilentlyContinue
If (!$Module) {
    Write-Host "[ERROR] Unable to locate Active Directory module for Windows PowerShell" -ForegroundColor Red
    Write-Log -Output $LogFile -Message "[ERROR] Unable to locate Active Directory module for Windows PowerShell"
    Exit
}

Write-Host "Launching the creation of [$VMNumber] Virtual Machine(s)." -ForegroundColor Cyan
Write-Log -Output $LogFile -Message "Launching the creation of $VMNumber Virtual Machine(s)"
Write-Host "`r"

## Connect to the vCenter ##
Try {
    Write-Host "Trying to connect on VMware Server..."
    Write-Host "`r"
    Write-Log -Output $LogFile -Message "Trying to connect on VMware Server..."
    $Connection = Connect-VIServer -Server vCenterServerName
}
Catch {
    Write-Host "[ERROR] Unable to connect on VMware Server" -ForegroundColor Red
    Write-Log -Output $LogFile -Message "[ERROR] Unable to connect on VMware Server"
    Write-Host "`r"
    "`r" | Out-File -FilePath $LogFile -Append -Force
    Exit
}

Write-Host "Connected on the vCenter [$Connection] :" -ForegroundColor Green
Write-Host "- From [$Hostname]" -ForegroundColor Green
Write-Host "- With [$FullLogin]" -ForegroundColor Green
Write-Host "`r"
Write-Log -Output $LogFile -Message "Connected on the vCenter $Connection :"
Write-Log -Output $LogFile -Message "- From : $Hostname"
Write-Log -Output $LogFile -Message "- With : $FullLogin"

## Ask your password to add the VM(s) in Active Directory ##
Write-Log -Output $LogFile -Message "Ask your admin password to add the VM(s) in Active Directory"
Write-Host "- Set your admin password to add the VM(s) in Active Directory :" -ForegroundColor Cyan
Write-Host "`r"
Do {
    $Pass = Read-Host "- Set your admin password [$FullLogin] " -AsSecureString
    $Password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Pass))
    If ($Password -eq "") {
        Write-Host "  Password is mandatory !" -ForegroundColor Red
        Write-Host "`r"
    }
} Until ($Password -ne "")
Write-Host "`r"

## Process the XML file ##
ForEach ($vm in $xml.CreateVM.VM) {
    $VMName = $vm.VMName
    $Template = $vm.Template
    $Datacenter = $vm.Datacenter
    $Cluster = $vm.Cluster
    $ESX = $vm.ESX
    $Datastore = $vm.Datastore
    $Drive = $vm.Drive
    $Drive2 = $vm.Drive2
    $Drive3 = $vm.Drive3
    $DiskStorageFormat = "Thick"
    $CPU = $vm.CPU
    $Memory = $vm.MemoryGB
    $VLAN = $vm.VLAN
    $IP = $vm.IP
    $Mask = $vm.Mask
    $Gateway = $vm.Gateway
    $DNS = $($vm.DNS).split(" ")
    $Description = $vm.Description
    $TSEADGroup = "GRP_"+$VMName+"_TSE"
    $ADMADGroup = "GRP_"+$VMName+"_ADM"
    $TSEADGroupDescription = "Groupe des utilisateurs ayant des droits d'accès à distance sur $VMName"
    $ADMADGroupDescription = "Groupe des administrateurs locaux de $VMName"
    Try {
        ## Collect information of the XML file ##
        Write-Log -Output $LogFile -Message "Creation of the log file :"
        Write-Log -Output $LogFile -Message "- Path : $Workfolder\Logs"
        Write-Log -Output $LogFile -Message "- File name : $Date-Create-VMs.log"
        Write-Log -Output $LogFile -Message "Configuration of the XML file :"
        Write-Log -Output $LogFile -Message "#############################################"
        Write-Log -Output $LogFile -Message "- Hostname : $VMName"
        Write-Log -Output $LogFile -Message "- Template : $Template"
        Write-Log -Output $LogFile -Message "- Datacenter : $Datacenter"
        Write-Log -Output $LogFile -Message "- Cluster : $Cluster"
        Write-Log -Output $LogFile -Message "- ESX : $ESX"
        Write-Log -Output $LogFile -Message "- Datastore : $Datastore"
        Write-Log -Output $LogFile -Message "- Drive (GB) : $Drive"
        Write-Log -Output $LogFile -Message "- Drive2 (GB) : $Drive2"
        Write-Log -Output $LogFile -Message "- Drive3 (GB) : $Drive3"
        Write-Log -Output $LogFile -Message "- CPU : $CPU"
        Write-Log -Output $LogFile -Message "- Memory (GB) : $Memory"
        Write-Log -Output $LogFile -Message "- VLAN : $VLAN"
        Write-Log -Output $LogFile -Message "- IP : $IP"
        Write-Log -Output $LogFile -Message "- Mask : $Mask"
        Write-Log -Output $LogFile -Message "- Gateway : $Gateway"
        Write-Log -Output $LogFile -Message "- DNS : $DNS"
        Write-Log -Output $LogFile -Message "- VM Description : $Description"
        Write-Log -Output $LogFile -Message "#############################################"

        Write-Host "- Creation of the VM [$VMName] started :" -ForegroundColor Green
        Write-Log -Output $LogFile -Message "Creation of the VM $VMName started :"

        ## Collect information of the datastore ##
        $Datastores = Get-Datastore $Datastore
        $Spacefree = [Math]::round($Datastores[0].FreeSpaceMB / 1024)
        $DatastoreName = $Datastores[0].Name
        Write-Host "  Datastore [$DatastoreName] selected -> [$Spacefree GB] free space" -ForegroundColor Cyan
        Write-Log -Output $LogFile -Message "- Datastore $DatastoreName selected -> $Spacefree (GB) free space"
        $TotalDriveNeeded = ([int]$Drive + [int]$Drive2 + [int]$Drive3)
        Write-Host "  Space needed for the VM creation : [$TotalDriveNeeded GB]" -ForegroundColor Cyan
        Write-Log -Output $LogFile -Message "- Space needed for the VM creation : $TotalDriveNeeded (GB)"
        If ($TotalDriveNeeded -ge $Spacefree) {
            Write-Host "  Not enough space on [$Datastore]. Please free up some space or create another Datastore !" -ForegroundColor Red
            Write-Log -Output $LogFile -Message "- [ERROR] Not enough space on $DatastoreName datastore !"
            "`r" | Out-File -FilePath $LogFile -Append -Force
            Write-Host "`r"
            Exit
        }

        ## Ask the local admin password of the VM ##
        Write-Log -Output $LogFile -Message "- Ask the local admin password on $VMName"
        Write-Host "  Set the local admin password on [$VMName]" -ForegroundColor Cyan
        Write-Host "`r"
        Do {
            $AdminPass = Read-Host "- Set the local admin password on [$VMName] " -AsSecureString
            $AdminPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($AdminPass))
            If ($AdminPassword -eq "") {
                Write-Host "  Password is mandatory !" -ForegroundColor Red
                Write-Host "`r"
            }
        } Until ($AdminPassword -ne "")
        Write-Host "`r"

        ## Select the right template ##
        $Template = Get-Template -Location $Datacenter | ? { $_.Name -like $Template }
        Write-Host "  Using [$Template] template" -ForegroundColor Cyan
        Write-Log -Output $LogFile -Message "- Using $Template template"

        ## Cloning the template ##
        $ResourcePool = Get-Cluster -Location $Datacenter -Name $Cluster
        Try {
            Write-Host "  Cloning [$Template] template" -ForegroundColor Green
            New-VM -VMHost $ESX -Name $VMName -Template $Template -Datastore $Datastore -ResourcePool $ResourcePool -Description $Description -ErrorAction Stop | Out-Null
            Write-Log -Output $LogFile -Message "- Cloning $Template template"
        }
        Catch {
            $ErrorMessage = $_.Exception.Message
            Write-Host "  [ERROR] Unable to clone [$Template] : $ErrorMessage" -ForegroundColor Red
            Write-Log -Output $LogFile -Message "- [ERROR] Unable to clone $Template : $ErrorMessage"
            "`r" | Out-File -FilePath $LogFile -Append -Force
            Continue
        }

        ## Setting the VM (Hostname, CPU, RAM) ##
        Try {
            Write-Host "  Setting Hostname, CPU and RAM on [$VMName]" -ForegroundColor Green
            Set-VM -VM $VMName -Name $VMName -NumCpu $CPU -MemoryGB $Memory -Confirm:$false -ErrorAction Stop | Out-Null
            Write-Log -Output $LogFile -Message "- Setting Hostname, CPU and RAM on $VMName"
        }
        Catch {
            $ErrorMessage = $_.Exception.Message
            Write-Host "  [ERROR] Unable to configure [$VMName] : $ErrorMessage" -ForegroundColor Red
            Write-Log -Output $LogFile -Message "- [ERROR] Unable to configure $VMName : $ErrorMessage"
            "`r" | Out-File -FilePath $LogFile -Append -Force
            Continue
        }

        ## Setting up disk(s) space ##
        $vmToChange = Get-VM -Name $VMName
        If ($Drive -gt 40) {
            Try {
                Get-HardDisk -VM $vmToChange | ? {$_.CapacityGB -like "40"} | Set-HardDisk -CapacityGB $Drive -Confirm:$false -ErrorAction Stop | Out-Null
                Write-Host "  Extend done on the first virtual disk. Please extend the disk in Windows !" -ForegroundColor Yellow
                Write-Log -Output $LogFile -Message "- Setting first virtual disk size to $Drive (GB)"
            }
            Catch {
                $ErrorMessage = $_.Exception.Message
                Write-Host "  [ERROR] Unable to resize the first virtual disk on [$VMName] : $ErrorMessage" -ForegroundColor Red
                Write-Log -Output $LogFile -Message "- [ERROR] Unable to resize the first virtual disk on $VMName : $ErrorMessage"
                "`r" | Out-File -FilePath $LogFile -Append -Force
                Continue
            }
        }
        If ($Drive2 -gt 10) {
            Try {
                Get-HardDisk -VM $vmToChange | ? {$_.CapacityGB -like "10"} | Set-HardDisk -CapacityGB $Drive2 -Confirm:$false -ErrorAction Stop | Out-Null
                Write-Host "  Extend done on the second virtual disk. Please extend the disk in Windows !" -ForegroundColor Yellow
                Write-Log -Output $LogFile -Message "- Setting second virtual disk size to $Drive2 (GB)"
            }
            Catch {
                $ErrorMessage = $_.Exception.Message
                Write-Host "  [ERROR] Unable to resize the second virtual disk on [$VMName] : $ErrorMessage" -ForegroundColor Red
                Write-Log -Output $LogFile -Message "- [ERROR] Unable to resize the second virtual disk on $VMName : $ErrorMessage"
                "`r" | Out-File -FilePath $LogFile -Append -Force
                Continue
            }
        }

        ## Add a third virtual disk ##
        If ($Drive3 -gt 0) {
            Try {
                $vmToChange | New-HardDisk -CapacityGB $Drive3 -StorageFormat $DiskStorageFormat -Confirm:$false -ErrorAction Stop | Out-Null
                Write-Host "  Third virtual disk with [$Drive3 GB] added. Please initialize the disk in Windows !" -ForegroundColor Yellow
                Write-Log -Output $LogFile -Message "- Third virtual disk with $Drive3 (GB) added. Please initialize the disk in Windows !"
            }
            Catch {
                $ErrorMessage = $_.Exception.Message
                Write-Host "  [ERROR] Unable to add the third virtual disk on [$VMname] : $ErrorMessage" -ForegroundColor Red
                Write-Log -Output $LogFile -Message "- [ERROR] Unable to add the third virtual disk on $VMname : $ErrorMessage"
                "`r" | Out-File -FilePath $LogFile -Append -Force
                Continue
            }
        }

        ## Setting the VM (VLAN) ##
        Try {
            Write-Host "  Setting the VM [$VMName] on VLAN [$VLAN]" -ForegroundColor Green
            Get-VM -Name $VMName | Get-NetworkAdapter | Set-NetworkAdapter -Type "Vmxnet3" -NetworkName $VLAN -StartConnected:$true -Confirm:$false –ErrorAction Stop | Out-Null
            Write-Log -Output $LogFile -Message "- Setting the VM $VMName on VLAN $VLAN"
        }
        Catch {
            $ErrorMessage = $_.Exception.Message
            Write-Host "  [ERROR] Unable to set network card : $ErrorMessage" -ForegroundColor Red
            Write-Log -Output $LogFile -Message "- [ERROR] Unable to set network card : $ErrorMessage"
            "`r" | Out-File -FilePath $LogFile -Append -Force
            Continue
        }

        ## Customizing VM ##
        Try {
            $OSCustSpec = New-OSCustomizationSpec -Name $VMName -NamingScheme Fixed -NamingPrefix $VMName -OSType Windows -FullName Name -OrgName "OrgName" -ChangeSid -Domain "DomainName" -DomainUsername $Login -DomainPassword $Password -AdminPassword $AdminPassword -TimeZone 105
            Write-Host "  Applying customization on [$VMName]" -ForegroundColor Green
            $OSCustSpec | Get-OSCustomizationNicMapping | Set-OSCustomizationNicMapping -IpMode UseStaticIp -IpAddress $IP -SubnetMask $Mask -DefaultGateway $Gateway -DNS $DNS | Out-null
            Set-VM -VM $VMName -OSCustomizationSpec $OSCustSpec -Confirm:$false | Out-Null
            Get-OSCustomizationSpec -Name $VMName | Remove-OSCustomizationSpec -Confirm:$false | Out-null
            Write-Log -Output $LogFile -Message "- Applying customization on $VMName"
            }
        Catch {
            $ErrorMessage = $_.Exception.Message
            Write-Host "  [ERROR] Unable to apply customization on [$VMName] : $ErrorMessage" -ForegroundColor Red
            Write-Log -Output $LogFile -Message "- [ERROR] Unable to apply customization on $VMName : $ErrorMessage"
            "`r" | Out-File -FilePath $LogFile -Append -Force
            Continue
        }

        ## Power ON the VM ##
        Try {
            Write-Host "`r"
            Write-Host "- Power ON the VM [$VMName]" -ForegroundColor Green
            Start-VM -VM $VMname –ErrorAction Stop | Out-Null
            Write-Log -Output $LogFile -Message "Power ON the VM $VMName"
            Write-Host "`r"
            Write-Host "After starting, the VM will be restarted several times in order to finalize customization. Please don't touch the VM until everything is done." -ForegroundColor Red -BackgroundColor Yellow
        }
        Catch {
            $ErrorMessage = $_.Exception.Message
            Write-Host "- [ERROR] Unable to start the VM [$VMName] : $ErrorMessage" -ForegroundColor Red
            Write-Log -Output $LogFile -Message "- [ERROR] Unable to start the VM $VMName : $ErrorMessage"
            "`r" | Out-File -FilePath $LogFile -Append -Force
            Continue
        }

        ## Creation of AD groups (TSE, ADM) ##
        Write-Host "`r"
        Write-Host "- Creation of AD groups started :" -ForegroundColor Green
        Write-Log -Output $LogFile -Message "Creation of AD groups :"

        ## AD group creation (TSE) ##
        Try {
            New-ADGroup -Name $TSEADGroup -GroupScope Global -Description $TSEADGroupDescription -Path $TargetOU
            Write-Host "  AD group [$TSEADGroup] created" -ForegroundColor Green
            Write-Log -Output $LogFile -Message "- AD group $TSEADGroup created - Groupe des utilisateurs ayant des droits d'accès à distance sur $VMName"
        }
        Catch {
            $ErrorMessage = $_.Exception.Message
            Write-Host "  [ERROR] Unable to create the group $TSEADGroup on AD : $ErrorMessage" -ForegroundColor Red
            Write-Log -Output $LogFile -Message "- [ERROR] Unable to create the group $TSEADGroup on AD : $ErrorMessage"
            "`r" | Out-File -FilePath $LogFile -Append -Force
        }

        ## AD group creation (ADM) ##
        Try {
            New-ADGroup -Name $ADMADGroup -GroupScope Global -Description $ADMADGroupDescription -Path $TargetOU
            Write-Host "  AD group [$ADMADGroup] created" -ForegroundColor Green
            Write-Log -Output $LogFile -Message "- AD group $ADMADGroup created - Groupe des administrateurs locaux de $VMName"
            "`r" | Out-File -FilePath $LogFile -Append -Force
        }
        Catch {
            $ErrorMessage = $_.Exception.Message
            Write-Host "  [ERROR] Unable to create the group $ADMADGroup on AD : $ErrorMessage" -ForegroundColor Red
            Write-Log -Output $LogFile -Message "- [ERROR] Unable to create the group $ADMADGroup on AD : $ErrorMessage"
            "`r" | Out-File -FilePath $LogFile -Append -Force
        }
        Write-Host "`r"
        Write-Host "Please move the server to the right folder/OU !" -ForegroundColor Yellow
        Write-Host "Please add AD groups (TSE & ADM) in the VM !" -ForegroundColor Yellow
        Write-Host "`r"
    }
    Catch {
        $ErrorMessage = $_.Exception.Message
        Write-Host "$ErrorMessage" -ForegroundColor Red
        Write-Log -Output "$LogFile" -Message "$ErrorMessage"
        "`r" | Out-File -FilePath $LogFile -Append -Force
    }
}

Write-Host "`r"
Disconnect-VIServer -Server * -Force -Confirm:$false
Write-Host "Disconnecting of VMware Server" -ForegroundColor Green
Write-Host "`r"

$EndTime = Get-Date
$Duration = [math]::Round((New-TimeSpan -Start $StartTime -End $EndTime).TotalMinutes,2)

Write-Host "`r"
Write-Host "Script launched from : " -NoNewline; Write-Host $Hostname -ForegroundColor Red
Write-Host "By : " -NoNewline; Write-Host $FullLogin -ForegroundColor Red
Write-Host "Path : " -NoNewline; Write-Host $Workfolder -ForegroundColor Red
Write-Host "Start time : " -NoNewline; Write-Host $StartTime -ForegroundColor Red
Write-Host "End time : " -NoNewline; Write-Host $EndTime -ForegroundColor Red
Write-Host "Duration : " -NoNewline; Write-Host $Duration -ForegroundColor Red -nonewline; Write-Host " minutes"
Write-Host "`r"
