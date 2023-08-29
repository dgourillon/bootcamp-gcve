Install-Module -Name VMware.PowerCLI -Scope CurrentUser -Force
Connect-VIServer -Server VCENTER_URL_PC1 -User 'CloudOwner@gve.local' -Password 'VCENTER_PWD_PC1' -Force
Get-VM | Select Id

	
Get-Command -Module VMware.VimAutomation.HCX

Connect-HCXServer -Server HCX_URL_PC1 -User 'CloudOwner@gve.local' -Password VCENTER_PWD_PC1

$SecureString = ConvertTo-SecureString -String "VCENTER_PWD_PC2" -AsPlainText -Force

New-HCXSitePairing -Password $SecureString -Url HCX_URL_PC2 -Username  'CloudOwner@gve.local'

$hcxServiceMeshName = "HCX-ServiceMesh"
$hcxComputeProfileName = "GCVE Compute Profile"
$hcxManagementNetworkProfileName = "GCVE MGMT Network Profile"
$hcxManagementNetworkBackingName = "HCX-MGMT"
$hcxComputeClusterName = "my-management-cluster"
$hcxDatastoreName = "vsanDatastore"
$hcxVDSName = "Datacenter-dvs"

New-HCXServiceMesh -Name $hcxServiceMeshName  `
-SourceComputeProfile $hcxLocalComputeProfile  `
-Destination $HcxDstSite  `
-DestinationComputeProfile $hcxRemoteComputeProfile  `
-Service BulkMigration,Interconnect,Vmotion,WANOptimization,NetworkExtension  `
-SourceUplinkNetworkProfile $hcxMgmtNetworkProfile