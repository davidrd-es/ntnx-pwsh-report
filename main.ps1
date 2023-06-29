# Modules import
Import-Module .\src\modules\utils\pwsh-rest\rest-api.psm1 -Force
Import-Module .\src\modules\utils\pwsh-html\report.psm1 -Force
Import-Module .\src\modules\nxapi-v3\get-items.psm1 -Force
Import-Module .\src\modules\entities\virtual-machine\virtual-machine.psm1 -Force
Import-Module .\src\modules\entities\virtual-machine\virtual-machine-view.psm1 -Force
Import-Module .\src\modules\entities\calm\applications.psm1 -Force
Import-Module .\src\modules\entities\calm\licenses.psm1 -Force
Import-Module .\src\modules\entities\cluster\cluster.psm1 -Force
Import-Module .\src\modules\entities\cluster\capacity.psm1 -Force
Import-Module .\src\modules\entities\cluster\cluster-view.psm1 -Force
Import-Module .\src\modules\entities\prism-central\prism-central-view.psm1 -Force
Import-Module .\src\modules\entities\host\host.psm1 -force
Import-Module .\src\modules\entities\engineers\engineers-view.psm1

[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}

$config = Get-Content -Path .\config\config.json | ConvertFrom-Json
$prismCentralInstances = $config.prismCentralInstances
$calmLicenses = $config.calmLicensesPurchased
[string]$userName = $config.user
[securestring]$secStringPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR((Import-CliXml -Path $config.passwordXmlPath))) | ConvertTo-SecureString -AsPlainText -Force
[pscredential]$prismCentralCredential = New-Object System.Management.Automation.PSCredential ($userName, $secStringPassword)
[array]$clusterCollection = @()
[array]$prismCentrallCollection = @()

foreach ($pcInstance in $prismCentralInstances){

    $prismCentralConnection = @{
        prismCentralAddress    = $pcInstance.ipAddress
        prismCentralPort       = $pcInstance.port
        prismCentralCredential = $prismCentralCredential
    }

    write-host 'Retrieving all Calm Applications from Prism Central:' $pcInstance.name 
    $calmAppUuidList = Get-allCalmAppsfromPc -prismCentralConnection $prismCentralConnection
    $calmAppUuidList = $calmAppUuidList.foreach({ $_.metadata.uuid })
    $calmAppList = Get-CalmAppDetailsByUuid -prismCentralConnection $prismCentralConnection -calmAppsUuidList $calmAppUuidList

    write-host 'Retrieving Calm Licenses from Prism Central:'
    $calmLicenses = Get-CalmLicenses -prismCentralConnection $prismCentralConnection
    
    write-host 'Retrieving all Virtual Machines from Prism Central:' $pcInstance.name 
    $virtualMachineList = Get-allVMsfromPc -prismCentralConnection $prismCentralConnection
    
    write-host 'Retrieving all Clusters from Prism Central:' $pcInstance.name 
    $clusterList = Get-allClustersfromPc $prismCentralConnection

    write-host 'Retrieving all Hosts from Prism Central:' $pcInstance.name 
    $hostList = Get-allHostsfromPc -prismCentralConnection $prismCentralConnection

    write-host 'Retrieving all Capacity scenarios'
    $scenariosListUuid = Get-ClusterScenariosUuid -prismCentralConnection $prismCentralConnection
    $scenariosList = Get-AllClusterScenarios -prismCentralConnection $prismCentralConnection -scenariosUuid $scenariosListUuid.uuid
    
    write-host 'Create Virtual Machine Collection'
    $virtualMachineCollection = $virtualMachineCollection + (New-VirtualMachineCollection `
        -virtualMachineList $virtualMachineList `
        -calmAppList $calmAppList `
        -prismCentralInstance $pcInstance.name)

    write-host 'Create Cluster Collection'
    $clusterCollection = $clusterCollection + (New-ClusterCollection `
        -prismCentralConnection $prismCentralConnection `
        -clusterList $clusterList `
        -prismCentralInstance $pcInstance.name `
        -scenariosList $scenariosList `
        -hostList $hostList `
        -virtualMachineCollection $virtualMachineCollection)

    write-host 'Create Prism Central Collection'
    $prismCentrallCollection = $prismCentrallCollection + (New-PrismCentralCollection `
        -prismCentralInstance $pcInstance `
        -clusterCollection $clusterCollection `
        -virtualMachineCollection $virtualMachineCollection `
        -calmLicenses $calmLicenses)
}


$engineerCollection = New-EngineersCollection -virtualMachineCollection $virtualMachineCollection -resourceLimits $config.defaultPerEngineer

$nutanixInventory = @{
    virtualMachines = $virtualMachineCollection
    clusters        = $clusterCollection
    prismCentral    = $prismCentrallCollection
    engineers       = $engineerCollection
    calmLicensesPurchased = $config.calmLicensesPurchased
}

New-NutanixReport -nutanixInventory $nutanixInventory -reportPath $config.reportPath