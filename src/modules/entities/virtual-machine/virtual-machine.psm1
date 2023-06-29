function Get-allVMsfromPc {
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
    $prismCentralConnection
  )
  
  begin {
  
  }
  
  process {
    try {
      $apiEndpoint = "/api/nutanix/v3/vms/list"
      $apiMethod = "POST"
      $jsonRootPath = "entities"
      $apiKind = 'vm'
            
      $virtualMachineList = Get-AllPrismCentralObjectsByType `
        -prismCentralAddress $prismCentralConnection.prismCentralAddress `
        -prismCentralPort $prismCentralConnection.prismCentralPort `
        -prismCentralCredential $prismCentralConnection.prismCentralCredential `
        -apiEndpoint $apiEndpoint `
        -apiMethod $apiMethod `
        -jsonRootPath $jsonRootPath `
        -apiKind $apiKind
        
      write-host 'Number of Virtual Machines found: ' $virtualMachineList.count
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
    return $virtualMachineList
  }
}

function Get-VirtualMachineMetrics {
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
    [string] 
    $prismCentralAddress,

    [parameter(mandatory = $true)]
    [string] 
    $prismCentralPort,

    [parameter(mandatory = $true)]
    [pscredential] 
    $prismCentralCredential
  )
  
  begin {}

  process {
    try {
      # Hello world
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
    return $result
  }
}