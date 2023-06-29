function New-PrismCentralCollection {
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
    [Object] 
    $prismCentralInstance,
    
    [parameter(mandatory = $true)]
    [Object[]] 
    $clusterCollection,

    [parameter(mandatory = $true)]
    [Object[]] 
    $virtualMachineCollection,
    
    [parameter(mandatory = $true)]
    [Object] 
    $calmLicenses
  )
  
  begin {
  
  }
  
  process {
    try {
        $prismCentral = [PSCustomObject]@{
          PrismCentral     = $prismCentralInstance.name
          Cluster          = $clusterCollection.where({$_.PrismCentral -like $prismCentralInstance.name}).count
          VirtualMachines  = $virtualMachineCollection.where({$_.PrismCentral -like $prismCentralInstance.name}).count
          CalmApplications = $virtualMachineCollection.where({$_.CalmLicense -eq $true -and $_.PrismCentral -like $prismCentralInstance.name}).count
          calmLicenses     = $calmLicenses.active_vms
        }
        #//TODO Metrics
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
    return $prismCentral
  }
}