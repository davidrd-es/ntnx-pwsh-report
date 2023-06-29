function New-VirtualMachineCollection {
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
    [Object[]] 
    $virtualMachineList,

    [parameter(mandatory = $true)]
    [string] 
    $prismCentralInstance,

    [parameter(mandatory = $true)]
    [Object[]] 
    $calmAppList
  )
  
  begin {
  
  }
  
  process {
    try {
      [array]$virtualMachineCollection = @()
      foreach ($object in $virtualMachineList) {
        $calmApp = Get-CalmAppByVmUuid -virtualMachineUuid $object.metadata.uuid -calmAppList $calmAppList
        if ($calmApp) {
          $license = "Yes"
        }
        else {
          $license = "No"
        }
        $virtualMachineObject = [PSCustomObject]@{
          Project            = $object.metadata.project_reference.name
          Owner              = $object.metadata.owner_reference.name
          Name               = $object.spec.name
          PrismCentral       = $prismCentralInstance
          Cluster            = $object.spec.cluster_reference.name
          vCPU               = $object.spec.resources.num_sockets * $object.spec.resources.num_vcpus_per_socket
          Memory             = $object.spec.resources.memory_size_mib
          Disks              = $object.spec.resources.disk_list.Where({ $_.device_properties.device_type -like "DISK" }).disk_size_mib
          Networks           = $object.spec.resources.nic_list.ForEach({ $_.subnet_reference.name + "-" + $_.ip_endpoint_list.ip })
          uuid               = $object.metadata.uuid
          Blueprint          = $calmApp.spec.resources.app_blueprint_reference.name
          ApplicationProfile = $calmApp.spec.resources.app_profile_config_reference.name
          CalmLicense        = $license
        }
        #//TODO Metrics
        $virtualMachineCollection += $virtualMachineObject
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
    return $virtualMachineCollection
  }
}