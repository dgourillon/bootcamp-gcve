Install-Module -Name VMware.PowerCLI -Scope CurrentUser -Force
Connect-VIServer -Server VCENTER_URL -User 'CloudOwner@gve.local' -Password 'VCENTER_PWD' -Force
Get-VM | Select Id
