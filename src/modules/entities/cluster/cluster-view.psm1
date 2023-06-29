function New-ClusterCollection {
  <#
    .SYNOPSIS
      Makes api call to prism based on passed parameters. Returns the json response.
    .DESCRIPTION
      Makes api call to prism based on passed parameters. Returns the json response.
    .NOTES
      Author: Stephane Bourdeaud
    .PARAMETER method
      REST method (POST, GET, DELETE, or PUT)
    .PARAMETER credential
      PSCredential object to use for authentication.
    .PARAMETER url
      URL to the api endpoint.
    .PARAMETER payload
      JSON payload to send.
    .EXAMPLE
    .\Invoke-PrismAPICall -credential $MyCredObject -url https://myprism.local/api/v3/vms/list -method 'POST' -payload $MyPayload
    Makes a POST api call to the specified endpoint with the specified payload.
    #>
  param(
    [parameter(mandatory = $true)]
    [Hashtable] 
    $prismCentralConnection,

    [parameter(mandatory = $true)]
    [Object[]] 
    $clusterList,

    [parameter(mandatory = $true)]
    [string] 
    $prismCentralInstance,

    [parameter(mandatory = $true)]
    [Object[]] 
    $scenariosList,

    [parameter(mandatory = $true)]
    [Object[]] 
    $hostList,

    [parameter(mandatory = $true)]
    [Object[]] 
    $virtualMachineCollection
  )
  
  begin {
  
  }
  
  process {
    try {
      [array]$clusterCollection = @()
      $clusterList = $clusterList.Where({$_.status.resources.config.build.version -notlike "pc"}) | where-object { $_.status.resources.nodes.hypervisor_server_list[0].type -like "AHV"}
      foreach ($object in $clusterList) {

        if ($scenariosList.where({$_.cluster_uuid -like $object.metadata.uuid})) {
          $scenarioTaskUuid = Start-ScenarioByCluster -prismCentralConnection $prismCentralConnection -scenarioUuid ($scenariosList.where({$_.cluster_uuid -like $object.metadata.uuid})).uuid
          Start-Sleep 60
          $runway = Get-ScenarioResults -prismCentralConnection $prismCentralConnection -scenarioTaskUuid $scenarioTaskUuid
        }
        $clusterCpuResources = $null
        $clusterMemoryResources = $null
        $hosts = $hostList | where-object {$_.status.cluster_reference.uuid -like $object.metadata.uuid}
        foreach ($ahvHost in $hosts){
          $clusterCpuResources = $clusterCpuResources + ($ahvHost.status.resources.num_cpu_sockets * $ahvHost.status.resources.num_cpu_cores)
          $clusterMemoryResources = $clusterMemoryResources + ($ahvHost.status.resources.memory_capacity_mib / 1024)
        }
        $AssignedVcpu = (($virtualMachineCollection | Where-Object {$_.cluster -like $object.spec.name} | Where-Object {$_.PrismCentral -like $prismCentralInstance}).vcpu | Measure-Object -Sum).sum
        $AssignedMemory = ((($virtualMachineCollection | Where-Object {$_.cluster -like $object.spec.name} | Where-Object {$_.PrismCentral -like $prismCentralInstance}).Memory | Measure-Object -Sum).sum) / 1024
        $clusterObject = [PSCustomObject]@{
          PrismCentral                    = $prismCentralInstance
          Cluster                         = $object.spec.name
          Nodes                           = ($object.status.resources.nodes.hypervisor_server_list.count - 1)
          AosVersion                      = $object.spec.resources.config.software_map.NOS.version
          AhvVersion                      = $object.status.resources.nodes.hypervisor_server_list[0].version
          RedundancyFactor                = $object.spec.resources.config.redundancy_factor
          VirtualMachines                 = ($virtualMachineCollection | Where-Object {$_.cluster -like $object.spec.name} | Where-Object {$_.PrismCentral -like $prismCentralInstance}).count
          GlobalRunwayDays                = $runway.runway.min_runway_days
          CPURunwayDays                   = $runway.runway.cpu_runway_days
          MemoryRunwayDays                = $runway.runway.memory_runway_days
          StorageRunwayDays               = $runway.runway.storage_runway_days
          vCpu                            = $clusterCpuResources
          AssignedVcpu                    = $AssignedVcpu
          vCPURatio                       = ($clusterCpuResources / $AssignedVcpu)
          Memory                          = $clusterMemoryResources
          AssignedMemory                  = $AssignedMemory
          FreeMemory                      = ($clusterMemoryResources - $AssignedMemory)
          DeadVirtualMachines             = $object.status.resources.analysis.vm_efficiency_map.dead_vm_num
          BullyVirtualMachines            = $object.status.resources.analysis.vm_efficiency_map.bully_vm_num
          OverprovisionedVirtualMachines  = $object.status.resources.analysis.vm_efficiency_map.overprovisioned_vm_num
          InefficientVirtualMachines      = $object.status.resources.analysis.vm_efficiency_map.inefficient_vm_num
          ConstrainedVirtualMachines      = $object.status.resources.analysis.vm_efficiency_map.constrained_vm_num
        }
        #//TODO Metrics
        $clusterCollection += $clusterObject
      }
    }
    catch {
      $saved_error = $_.Exception.Message
      # Write-Host "$(Get-Date) [INFO] Headers: $($headers | ConvertTo-Json)"
      Write-Host "$(Get-Date) [INFO] Payload: $payload" -ForegroundColor Green
      Throw "$(get-date) [ERROR] $saved_error"
    }
    finally {
      #add any last words here; this gets processed no matter what
    }    
  }
  end {
    return $clusterCollection
  }
}