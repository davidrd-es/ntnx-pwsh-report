function New-EngineersCollection {
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
    $virtualMachineCollection,

    [parameter(mandatory = $true)]
    [Object] 
    $resourceLimits
  )
  
  begin {
  
  }
  
  process {
    try {
      [array]$engineersCollection = @()
      $engineerList = $virtualMachineCollection | Select-Object -ExpandProperty Owner | Sort-Object -Unique
      foreach ($engineer in $engineerList){
        $engineerVmList = $virtualMachineCollection.Where({$_.owner -like $engineer})
        if ($resourceLimits.virtualMachine -lt ($engineerVmList.count)){
          $ExceedsVmResources = $true
        }
        if (($resourceLimits.vCPU * $resourceLimits.virtualMachine) -lt ($engineerVmList.ForEach({$_.vcpu}) | Measure-Object -sum).sum){
          $ExceedsCpuResources = $true
        }
        if (($resourceLimits.memory * $resourceLimits.virtualMachine) -lt ($engineerVmList.ForEach({$_.memory}) | Measure-Object -sum).sum){
          $ExceedsMemoryResources = $true
        }
        $engineerObject = [PSCustomObject]@{
          Engineer               = $engineer
          VirtualMachines        = $engineerVmList.count
          CalmApplications       = $engineerVmList.Where({$_.CalmLicense -eq $true}).count
          Totalvcpu              = ($engineerVmList.ForEach({$_.vcpu}) | Measure-Object -sum).sum
          TotalMemoryGb          = ($engineerVmList.ForEach({$_.memory}) | Measure-Object -sum).sum/ 1024
          TotalStorageGb         = ($engineerVmList.ForEach({$_.disks}) | Measure-Object -sum).sum / 1024
          ExceedsVmResources     = $ExceedsVmResources 
          ExceedsCpuResources    = $ExceedsCpuResources
          ExceedsMemoryResources = $ExceedsMemoryResources
        }
        #//TODO Metrics 
        $engineersCollection += $engineerObject
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
    return $engineersCollection
  }
}