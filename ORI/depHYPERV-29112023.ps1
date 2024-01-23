<#
 .NOTES
	Script for fast deployment :)
	By ITIMAGING For EVOLUCARE-IMAGING
	Created : 20 dec 2022
	Updated : 08 juin 2023
	For V9.1
	@Author Julien SALLET --> itimaging@evolucare.com
#>

Write-Host "START INSTALL  !" -NoNewLine -ForeGroundColor Green
(Get-Date).ToString("dd/MM/yyyy HH:mm:ss")

##Activaiton policy
##Set-ExecutionPolicy RemoteSigned

#Activation HyperV 
#Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
# Ou -->
#DISM /Online /Enable-Feature /All /FeatureName:Microsoft-Hyper-V

#$DateAction = get-date -format "dd/MM/yyyy HH:mm:ss"
#write-host $DateAction Activation of high energy performance for Windows -NoNewLine -ForeGroundColor Green
write-host Activation of high energy performance for Windows -NoNewLine -ForeGroundColor Green

#Activation of high energy performance for Windows
powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 
powercfg -CHANGE -monitor-timeout-ac 0 
powercfg -CHANGE -monitor-timeout-dc 0 
powercfg -CHANGE -disk-timeout-ac 0 
powercfg -CHANGE -disk-timeout-dc 0 
powercfg -CHANGE -standby-timeout-ac 0 
powercfg -CHANGE -standby-timeout-dc 0 
powercfg -CHANGE -hibernate-timeout-ac 0 
powercfg -CHANGE -hibernate-timeout-dc 0

#Creating HyperV folders
Write-Host "Create Folder  !" -NoNewLine -ForeGroundColor Green
New-Item "N:\HYPERV\" -itemType Directory
New-Item "O:\HYPERV\" -itemType Directory
#New-Item "F:\HYPERV\" -itemType Directory

##Networking Variable
#$ethernet = Get-NetAdapter -Name ethernet
$SwitchLan = 'vSwitch From NIC1'
$SwitchInterne = 'vSwitch Interne'

##Create vSwith From NIC1
#New-VMSwitch -Name $SwitchLan -NetAdapterName $ethernet.Name -AllowManagementOS $true -Notes "For Evolucare Imaging VMs"
#Write-Host "Add $SwitchLan Ok !" -NoNewLine -ForeGroundColor Green

##Create vSwith Interne

$commutateursVirtuels = Get-VMSwitch

$existe = $false
foreach ($vSwitch in $commutateursVirtuels) {
    if ($vSwitch.Name -eq $SwitchInterne -and $vSwitch.SwitchType -eq "Internal") {
        $existe = $true
        break
    }
}

if (-not $existe) {
    New-VMSwitch -Name $SwitchInterne -SwitchType Internal -Notes "For Evolucare Imaging Internal VMs"
	New-NetIPAddress -IPAddress 10.42.42.1 -InterfaceAlias "vEthernet (vSwitch Interne)"
	Disable-NetAdapterBinding -InterfaceAlias "vEthernet (vSwitch Interne)" -ComponentID ms_tcpip6

    Write-Host "Le commutateur $SwitchInterne a ete cree avec succes."
} else {
    Write-Host "Le commutateur $SwitchInterne existe deja."
}

#Custom Cfg VMs

##APP
$VMsnameAPP= "VM-IMGPRD-APP"
$cpuAPP= 8
$ramAPP= 10GB
$PathVMAPP= "N:\HYPERV\"
$PathVMAPPDISK4= "O:\HYPERV\"


##BDD
$VMsnameBDD= "VM-IMGPRD-BDD"
$cpuBDD= 8
$ramBDD= 10GB
$PathVMBDD= "N:\HYPERV\"


##INTEROP
$VMsnameINTEROP= "VM-IMGPRD-INTEROP"
$cpuINTEROP= 6
$ramINTEROP= 8GB
$PathVMINTEROP= "N:\HYPERV\"


##HUB
$VMsnameHUB= "VM-IMGPRD-HUB"
$cpuHUB= 4
$ramHUB= 4GB
$PathVMHUB= "N:\HYPERV\"


##UVIEW
$VMsnameUVIEW= "VM-IMGPRD-UVIEW"
$cpuUVIEW= 4
$ramUVIEW= 4GB
$PathVMUVIEW= "N:\HYPERV\"


##APPBIS
$VMsnameAPPBIS= "VM-IMGPRD-APPBIS"
$cpuAPPBIS= 4
$ramAPPBIS= 4GB
$PathVMAPPBIS= "N:\HYPERV\"

Start-Sleep -s 10

#Create VMs :

new-vm -Name $VMsnameAPP -MemoryStartupBytes $ramAPP -Generation 1 -Switchname $SwitchLan -Path $PathVMAPP 
Set-VM -Name $VMsnameAPP -ProcessorCount $cpuAPP -StaticMemory -CheckpointType Disabled -AutomaticStopAction Shutdown -AutomaticStartAction Start -AutomaticStartDelay 20
Add-VMNetworkAdapter -VMName $VMsnameAPP -SwitchName $SwitchInterne
New-Item "$PathVMAPP\$VMsnameAPP\Virtual Hard Disks" -itemType Directory
Set-VM -Name $VMsnameAPP -Note "Installation le : $(Get-Date)"
#New-Item "$PathVMAPPDISK4\$VMsnameAPP\Virtual Hard Disks" -itemType Directory

#Start-VM $VMsnameAPP
Write-Host "Deployment $VMsnameAPP OK !" -NoNewLine -ForeGroundColor Green


new-vm -Name $VMsnameBDD -MemoryStartupBytes $ramBDD -Generation 1 -Switchname $SwitchLan -Path $PathVMBDD 
Set-VM -Name $VMsnameBDD -ProcessorCount $cpuBDD -StaticMemory -CheckpointType Disabled -AutomaticStopAction Shutdown -AutomaticStartAction Start -AutomaticStartDelay 0
Start-Sleep -Seconds 5
Add-VMNetworkAdapter -VMName $VMsnameBDD -SwitchName $SwitchInterne
New-Item "$PathVMBDD\$VMsnameBDD\Virtual Hard Disks" -itemType Directory
Set-VM -Name $VMsnameBDD -Note "Installation le : $(Get-Date)"

#Start-VM $VMsnameBDD
Write-Host "Deployment $VMsnameBDD OK !" -NoNewLine -ForeGroundColor Green


new-vm -Name $VMsnameINTEROP -MemoryStartupBytes $ramINTEROP -Generation 1 -Switchname $SwitchLan -Path $PathVMINTEROP 
Set-VM -Name $VMsnameINTEROP -ProcessorCount $cpuINTEROP -StaticMemory -CheckpointType Disabled -AutomaticStopAction Shutdown -AutomaticStartAction Start -AutomaticStartDelay 60
New-Item "$PathVMINTEROP\$VMsnameINTEROP\Virtual Hard Disks" -itemType Directory
Set-VM -Name $VMsnameINTEROP -Note "Installation le : $(Get-Date)"

#Start-VM $VMsnameINTEROP
Write-Host "Deployment $VMsnameINTEROP OK !" -NoNewLine -ForeGroundColor Green


new-vm -Name $VMsnameHUB -MemoryStartupBytes $ramHUB -Generation 1 -Switchname $SwitchLan -Path $PathVMHUB
Set-VM -Name $VMsnameHUB -ProcessorCount $cpuHUB -StaticMemory -CheckpointType Disabled -AutomaticStopAction Shutdown -AutomaticStartAction Start -AutomaticStartDelay 10
New-Item "$PathVMHUB\$VMsnameHUB\Virtual Hard Disks" -itemType Directory
Set-VM -Name $VMsnameHUB -Note "Installation le : $(Get-Date)"

#Start-VM $VMsnameHUB
Write-Host "Deployment $VMsnameHUB OK !" -NoNewLine -ForeGroundColor Green


new-vm -Name $VMsnameUVIEW -MemoryStartupBytes $ramUVIEW -Generation 1 -Switchname $SwitchLan -Path $PathVMUVIEW
Set-VM -Name $VMsnameUVIEW -ProcessorCount $cpuUVIEW -StaticMemory -CheckpointType Disabled -AutomaticStopAction Shutdown -AutomaticStartAction Start -AutomaticStartDelay 55
New-Item "$PathVMUVIEW\$VMsnameUVIEW\Virtual Hard Disks" -itemType Directory
Set-VM -Name $VMsnameUVIEW -Note "Installation le : $(Get-Date)"

#Start-VM $VMsnameUVIEW
Write-Host "Deployment $VMsnameUVIEW OK !" -NoNewLine -ForeGroundColor Green


#new-vm -Name $VMsnameAPPBIS -MemoryStartupBytes $ramAPPBIS -Generation 1 -Switchname $SwitchLan -Path $PathVMAPPBIS
new-vm -Name $VMsnameAPPBIS -MemoryStartupBytes $ramAPPBIS -Generation 2 -Switchname $SwitchLan -Path $PathVMAPPBIS
Set-VM -Name $VMsnameAPPBIS -ProcessorCount $cpuAPPBIS -StaticMemory -CheckpointType Disabled -AutomaticStopAction Shutdown -AutomaticStartAction Start -AutomaticStartDelay 45
New-Item "$PathVMAPPBIS\$VMsnameAPPBIS\Virtual Hard Disks" -itemType Directory
Set-VM -Name $VMsnameAPPBIS -Note "Installation le : $(Get-Date)"

#Start-VM $VMsnameAPPBIS
Write-Host "Deployment $VMsnameAPPBIS OK !" -NoNewLine -ForeGroundColor Green

Write-Host "Deployment $VMsnameHUB OK !" -ForeGroundColor Green
Write-Host "The creation architecture VMs is now complete ;) !" -ForeGroundColor Yellow
Write-Host "Download Master in progress ..." -ForeGroundColor Green


##Download FULL Master

$URIAPP="https://downloads-imaging.evolucare.com/masters/IMGPRD-APPv9.1_master/IMGPRD-APP9.1_MASTER_HV.zip";
$URIBDD="https://downloads-imaging.evolucare.com/masters/IMGPRD-BDDv9.1_master/IMGPRD-BDD9.1_MASTER_HV.zip";
$URIINTEROP="https://downloads-imaging.evolucare.com/masters/IMGPRD-INTEROPv4_master/IMGPRD-INTEROP4.2_MASTER_HV.zip";
$URIUVIEW="https://downloads-imaging.evolucare.com/masters/IMGPRD-UVIEWv2.2.1_master/IMGPRD-UVIEW_MASTER_HV.zip";
$URIHUB="https://downloads-imaging.evolucare.com/masters/IMGPRD-HUBv3_master/IMGPRD-HUB_MASTER_HV.zip";
$URIAPPBIS="https://downloads-imaging.evolucare.com/masters/IMGPRD-APPBIS-2022_master/IMGPRD-APPBIS-2022-BI_MASTER_HV.zip";

$pair = "$('DownloadsMaster'):$('1Y6fhgt?MQ?InkR#75UWy1TujTNN?Sf&5bvE#BnX')"
$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))
$basicAuthValue = "Basic $encodedCreds"
$Headers = @{
	Authorization = $basicAuthValue
}

$ProgressPreference = 'SilentlyContinue'

Write-Host "Download Master $VMsnameAPP in progress..." -ForeGroundColor Green

Measure-Command { DownloadFile -SourceUri $URIAPP -OutFile "$PathVMAPP$VMsnameAPP\Virtual Hard Disks\IMGPRD-APP9.1_MASTER_HV.zip" -Headers $Headers
 }
Write-Host "Download Master $VMsnameAPP OK !" -ForeGroundColor Green
Write-Host "Download Master $VMsnameBDD in progress..." -ForeGroundColor Green

Measure-Command { DownloadFile -SourceUri $URIBDD -OutFile "$PathVMBDD$VMsnameBDD\Virtual Hard Disks\IMGPRD-BDD9.1_MASTER_HV.zip" -Headers $Headers
 }
Write-Host "Download Master $VMsnameBDD OK !" -ForeGroundColor Green
Write-Host "Download Master $VMsnameINTEROP in progress..." -ForeGroundColor Green

Measure-Command { DownloadFile -SourceUri $URIINTEROP -OutFile "$PathVMINTEROP$VMsnameINTEROP\Virtual Hard Disks\IMGPRD-INTEROP4.2_MASTER_HV.zip" -Headers $Headers
 }
Write-Host "Download Master  $VMsnameINTEROP OK !"
Write-Host "Download Master $VMsnameHUB in progress..."
Measure-Command { DownloadFile -SourceUri $URIHUB -OutFile $PathVMHUB$VMsnameHUB\"Virtual Hard Disks\IMGPRD-HUB_MASTER_HV.zip" -Headers $Headers
 }
Write-Host "Download Master $VMsnameHUB OK !"
Write-Host "Download Master $VMsnameUVIEW in progress..."
Measure-Command { DownloadFile -SourceUri $URIUVIEW -OutFile $PathVMUVIEW$VMsnameUVIEW\"Virtual Hard Disks\IMGPRD-UVIEW_MASTER_HV.zip" -Headers $Headers
 }
Write-Host "Download Master $VMsnameUVIEW OK !"
Write-Host "Download Master $VMsnameAPPBIS in progress..."
Measure-Command { DownloadFile -SourceUri $URIAPPBIS -OutFile $PathVMAPPBIS$VMsnameAPPBIS\"Virtual Hard Disks\IMGPRD-APPBIS-2022-BI_MASTER_HV.zip" -Headers $Headers
}
Write-Host "Download Master $VMsnameAPPBIS OK !"

<#Unzip Master#>
Write-Host "Unzip Master $VMsnameAPP in progress ..." -ForeGroundColor Green
Expand-Archive -LiteralPath $PathVMAPP$VMsnameAPP\"Virtual Hard Disks\IMGPRD-APP9.1_MASTER_HV.zip" -DestinationPath $PathVMAPP$VMsnameAPP\"Virtual Hard Disks\" -Force

Write-Host "Unzip Master $VMsnameBDD TO DO" -ForeGroundColor Green
Expand-Archive -LiteralPath $PathVMBDD$VMsnameBDD\"Virtual Hard Disks\IMGPRD-BDD9.1_MASTER_HV.zip" -DestinationPath $PathVMBDD$VMsnameBDD\"Virtual Hard Disks\" -Force

Write-Host "Unzip Master $VMsnameINTEROP in progress ..." -ForeGroundColor Green
Expand-Archive -LiteralPath $PathVMINTEROP$VMsnameINTEROP\"Virtual Hard Disks\IMGPRD-INTEROP4.2_MASTER_HV.zip" -DestinationPath $PathVMINTEROP$VMsnameINTEROP\"Virtual Hard Disks\" -Force

Write-Host "Unzip Master $VMsnameHUB in progress ..." -ForeGroundColor Green
Expand-Archive -LiteralPath $PathVMHUB$VMsnameHUB\"Virtual Hard Disks\IMGPRD-HUB_MASTER_HV.zip" -DestinationPath $PathVMHUB$VMsnameHUB\"Virtual Hard Disks\" -Force

Write-Host "Unzip Master $VMsnameUVIEW in progress ..." -ForeGroundColor Green
Expand-Archive -LiteralPath $PathVMUVIEW$VMsnameUVIEW\"Virtual Hard Disks\IMGPRD-UVIEW_MASTER_HV.zip" -DestinationPath $PathVMUVIEW$VMsnameUVIEW\"Virtual Hard Disks\" -Force

Write-Host "Unzip Master $VMsnameAPPBIS in progress ..." -ForeGroundColor Green
Expand-Archive -LiteralPath $PathVMAPPBIS$VMsnameAPPBIS\"Virtual Hard Disks\IMGPRD-APPBIS-2022-BI_MASTER_HV.zip" -DestinationPath $PathVMAPPBIS$VMsnameAPPBIS\"Virtual Hard Disks\" -Force

Write-Host "Clean directory $VMsnameAPP..." -ForeGroundColor Green
Write-Host "Clean directory $VMsnameBDD..." -ForeGroundColor Green
Write-Host "Clean directory $VMsnameINTEROP..." -ForeGroundColor Green
Write-Host "Clean directory $VMsnameHUB..." -ForeGroundColor Green
Write-Host "Clean directory $VMsnameUVIEW..." -ForeGroundColor Green
Write-Host "Clean directory $VMsnameAPPBIS..." -ForeGroundColor Green

Start-Sleep -Seconds 30

Write-Host "Convert VHD TO VHDX MOVE AND RENAME IT $VMsnameAPP..." -ForeGroundColor Green

<#Convert vhd --> vhdx, rename, mv in Virtual Hard Disks Folder#>

#APP
Convert-VHD -Path $PathVMAPP$VMsnameAPP\"Virtual Hard Disks\MASTER-IMGPRD-APP9.1-disk1.vhd" -DestinationPath $PathVMAPP$VMsnameAPP\"Virtual Hard Disks\"$VMsnameAPP"-disk1-fixe.vhdx" -VHDType Fixed
Convert-VHD -Path $PathVMAPP$VMsnameAPP\"Virtual Hard Disks\MASTER-IMGPRD-APP9.1-disk2.vhd" -DestinationPath $PathVMAPP$VMsnameAPP\"Virtual Hard Disks\"$VMsnameAPP"-disk2-fixe.vhdx" -VHDType Fixed
Convert-VHD -Path $PathVMAPP$VMsnameAPP\"Virtual Hard Disks\MASTER-IMGPRD-APP9.1-disk3.vhd" -DestinationPath $PathVMAPP$VMsnameAPP\"Virtual Hard Disks\"$VMsnameAPP"-disk3-fixe.vhdx" -VHDType Fixed
Convert-VHD -Path $PathVMAPP$VMsnameAPP\"Virtual Hard Disks\MASTER-IMGPRD-APP9.1-disk4.vhd" -DestinationPath $PathVMAPPDISK4$VMsnameAPP\"Virtual Hard Disks\"$VMsnameAPP"-disk4-dyn.vhdx" -VHDType Dynamic

Write-Host "Convert VHD TO VHDX MOVE AND RENAME IT $VMsnameBDD..." -ForeGroundColor Green
#BDD
Convert-VHD -Path $PathVMBDD$VMsnameBDD\"Virtual Hard Disks\MASTER-IMGPRD-BDD9.1-disk1.vhd" -DestinationPath $PathVMBDD$VMsnameBDD\"Virtual Hard Disks\"$VMsnameBDD"-disk1-fixe.vhdx" -VHDType Fixed
Convert-VHD -Path $PathVMBDD$VMsnameBDD\"Virtual Hard Disks\MASTER-IMGPRD-BDD9.1-disk2.vhd" -DestinationPath $PathVMBDD$VMsnameBDD\"Virtual Hard Disks\"$VMsnameBDD"-disk2-fixe.vhdx" -VHDType Fixed

Write-Host "Convert VHD TO VHDX MOVE AND RENAME IT $VMsnameINTEROP..." -ForeGroundColor Green
#INTEROP
Convert-VHD -Path $PathVMINTEROP$VMsnameINTEROP\"Virtual Hard Disks\MASTER-IMGPRD-INTEROP4.2-disk1.vhd" -DestinationPath $PathVMINTEROP$VMsnameINTEROP\"Virtual Hard Disks\"$VMsnameINTEROP"-disk1-fixe.vhdx" -VHDType Fixed
Convert-VHD -Path $PathVMINTEROP$VMsnameINTEROP\"Virtual Hard Disks\MASTER-IMGPRD-INTEROP4.2-disk2.vhd" -DestinationPath $PathVMINTEROP$VMsnameINTEROP\"Virtual Hard Disks\"$VMsnameINTEROP"-disk2-fixe.vhdx" -VHDType Fixed
Convert-VHD -Path $PathVMINTEROP$VMsnameINTEROP\"Virtual Hard Disks\MASTER-IMGPRD-INTEROP4.2-disk3.vhd" -DestinationPath $PathVMINTEROP$VMsnameINTEROP\"Virtual Hard Disks\"$VMsnameINTEROP"-disk3-fixe.vhdx" -VHDType Fixed

Write-Host "Convert VHD TO VHDX MOVE AND RENAME IT $VMsnameHUB..." -ForeGroundColor Green
#HUB
Convert-VHD -Path $PathVMHUB$VMsnameHUB\"Virtual Hard Disks\MASTER-IMGPRD-HUB-disk1.vhd" -DestinationPath $PathVMHUB$VMsnameHUB\"Virtual Hard Disks\"$VMsnameHUB"-disk1-fixe.vhdx" -VHDType Fixed
Convert-VHD -Path $PathVMHUB$VMsnameHUB\"Virtual Hard Disks\MASTER-IMGPRD-HUB-disk2.vhd" -DestinationPath $PathVMHUB$VMsnameHUB\"Virtual Hard Disks\"$VMsnameHUB"-disk2-fixe.vhdx" -VHDType Fixed

Write-Host "Convert VHD TO VHDX MOVE AND RENAME IT $VMsnameUVIEW..." -ForeGroundColor Green
#UVIEW
Convert-VHD -Path $PathVMUVIEW$VMsnameUVIEW\"Virtual Hard Disks\MASTER-IMGPRD-UVIEW-disk1.vhd" -DestinationPath $PathVMUVIEW$VMsnameUVIEW\"Virtual Hard Disks\"$VMsnameUVIEW"-disk1-fixe.vhdx" -VHDType Fixed
Convert-VHD -Path $PathVMUVIEW$VMsnameUVIEW\"Virtual Hard Disks\MASTER-IMGPRD-UVIEW-disk2.vhd" -DestinationPath $PathVMUVIEW$VMsnameUVIEW\"Virtual Hard Disks\"$VMsnameUVIEW"-disk2-fixe.vhdx" -VHDType Fixed

Write-Host "Convert VHD TO VHDX MOVE AND RENAME IT $VMsnameAPPBIS..." -ForeGroundColor Green
#APPBIS
Convert-VHD -Path $PathVMAPPBIS$VMsnameAPPBIS\"Virtual Hard Disks\MASTER-IMGPRD-APPBIS-2022-BI.vhdx" -DestinationPath $PathVMAPPBIS$VMsnameAPPBIS\"Virtual Hard Disks\"$VMsnameAPPBIS"-disk1-fixe.vhdx" -VHDType Fixed

Write-Host "Plug VHDX to $VMsnameAPP ..." -ForeGroundColor Green
<#Plug disks to VM#>

#APP
Add-VMHardDiskDrive -VMName $VMsnameAPP -Path $PathVMAPP$VMsnameAPP\"Virtual Hard Disks\$VMsnameAPP-disk1-fixe.vhdx"
Add-VMHardDiskDrive -ControllerType SCSI -VMName $VMsnameAPP -Path $PathVMAPP$VMsnameAPP\"Virtual Hard Disks\$VMsnameAPP-disk2-fixe.vhdx"
Add-VMHardDiskDrive -ControllerType SCSI -VMName $VMsnameAPP -Path $PathVMAPP$VMsnameAPP\"Virtual Hard Disks\$VMsnameAPP-disk3-fixe.vhdx"
Add-VMHardDiskDrive -ControllerType SCSI -VMName $VMsnameAPP -Path $PathVMAPPDISK4$VMsnameAPP\"Virtual Hard Disks\$VMsnameAPP-disk4-dyn.vhdx"

##BDD
Add-VMHardDiskDrive -VMName $VMsnameBDD -Path $PathVMBDD$VMsnameBDD\"Virtual Hard Disks\$VMsnameBDD-disk1-fixe.vhdx"
Add-VMHardDiskDrive -ControllerType SCSI -VMName $VMsnameBDD -Path $PathVMBDD$VMsnameBDD\"Virtual Hard Disks\$VMsnameBDD-disk2-fixe.vhdx"

Write-Host "Plug VHDX to $VMsnameINTEROP ..." -ForeGroundColor Green
#INTEROP
Add-VMHardDiskDrive -VMName $VMsnameINTEROP -Path $PathVMINTEROP$VMsnameINTEROP\"Virtual Hard Disks\$VMsnameINTEROP-disk1-fixe.vhdx"
Add-VMHardDiskDrive -ControllerType SCSI -VMName $VMsnameINTEROP -Path $PathVMINTEROP$VMsnameINTEROP\"Virtual Hard Disks\$VMsnameINTEROP-disk2-fixe.vhdx"
Add-VMHardDiskDrive -ControllerType SCSI -VMName $VMsnameINTEROP -Path $PathVMINTEROP$VMsnameINTEROP\"Virtual Hard Disks\$VMsnameINTEROP-disk3-fixe.vhdx"

Write-Host "Plug VHDX to $VMsnameHUB ..." -ForeGroundColor Green
#HUB
Add-VMHardDiskDrive -VMName $VMsnameHUB -Path $PathVMHUB$VMsnameHUB\"Virtual Hard Disks\$VMsnameHUB-disk1-fixe.vhdx"
Add-VMHardDiskDrive -ControllerType SCSI -VMName $VMsnameHUB -Path $PathVMHUB$VMsnameHUB\"Virtual Hard Disks\$VMsnameHUB-disk2-fixe.vhdx"

Write-Host "Plug VHDX to $VMsnameUVIEW ..." -ForeGroundColor Green
#UVIEW
Add-VMHardDiskDrive -VMName $VMsnameUVIEW -Path $PathVMUVIEW$VMsnameUVIEW\"Virtual Hard Disks\$VMsnameUVIEW-disk1-fixe.vhdx"
Add-VMHardDiskDrive -ControllerType SCSI -VMName $VMsnameUVIEW -Path $PathVMUVIEW$VMsnameUVIEW\"Virtual Hard Disks\$VMsnameUVIEW-disk2-fixe.vhdx"

Write-Host "Plug VHDX to $VMsnameAPPBIS ..." -ForeGroundColor Green
#APPBIS
Add-VMHardDiskDrive -ControllerType SCSI -VMName $VMsnameAPPBIS -Path $PathVMAPPBIS$VMsnameAPPBIS\"Virtual Hard Disks\$VMsnameAPPBIS-disk1-fixe.vhdx"

#Write-Host "Clean directory..." -ForeGroundColor Green

Start-Sleep -Seconds 15
rm $PathVMAPP$VMsnameAPP\"Virtual Hard Disks"\IMGPRD-APP9.1_MASTER_HV.zip -r -Force
rm $PathVMBDD$VMsnameBDD\"Virtual Hard Disks"\IMGPRD-BDD9.1_MASTER_HV.zip -r -Force
rm $PathVMINTEROP$VMsnameINTEROP\"Virtual Hard Disks"\IMGPRD-INTEROP4.2_MASTER_HV.zip -r -Force
rm $PathVMHUB$VMsnameHUB\"Virtual Hard Disks"\IMGPRD-HUB_MASTER_HV.zip -r -Force
rm $PathVMUVIEW$VMsnameUVIEW\"Virtual Hard Disks"\IMGPRD-UVIEW_MASTER_HV.zip -r -Force
rm $PathVMAPPBIS$VMsnameAPPBIS\"Virtual Hard Disks"\IMGPRD-APPBIS-2022-BI_MASTER_HV.zip -r -Force

Start-Sleep -Seconds 15
<#Clean all work Folder#>
rm $PathVMAPP$VMsnameAPP\"Virtual Hard Disks"\*.vhd -r -Force
rm $PathVMBDD$VMsnameBDD\"Virtual Hard Disks"\*.vhd -r -Force
rm $PathVMINTEROP$VMsnameINTEROP\"Virtual Hard Disks"\*.vhd -r -Force
rm $PathVMHUB$VMsnameHUB\"Virtual Hard Disks"\*.vhd -r -Force
rm $PathVMUVIEW$VMsnameUVIEW\"Virtual Hard Disks"\*.vhd -r -Force
rm $PathVMAPPBIS$VMsnameAPPBIS\"Virtual Hard Disks"\MASTER-IMGPRD-APPBIS-2022-BI.vhdx -r -Force

#Write-Host "Start VMs ..." -ForeGroundColor Green

<#Start VMs #>
Start-VM $VMsnameAPP
Start-VM $VMsnameBDD
Start-VM $VMsnameINTEROP
Start-VM $VMsnameHUB
Start-VM $VMsnameUVIEW
Start-VM $VMsnameAPPBIS

####################ENDDDDDDDDDDDDDDD#########################

Write-Host "Deployment Succes !" -ForeGroundColor Green
Write-Host "Go have a coffee now ;) !" -ForeGroundColor Green

<# /!\ Delete and Clean VMs /!\

Stop-VM Ã¢â‚¬â€œName VM-IMGPRD-* Ã¢â‚¬â€œTurnOff
REMOVE-VM Ã¢â‚¬â€œName VM-IMGPRD-* -Force
Remove-item -R Ã¢â‚¬â€œpath "C:\HYPERV\VM-IMGPRD-*"
#>

Write-Host "FINISH INSTALL  !" -NoNewLine -ForeGroundColor Green 
(Get-Date).ToString("dd/MM/yyyy HH:mm:ss")