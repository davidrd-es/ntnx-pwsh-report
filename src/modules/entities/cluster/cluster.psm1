function Get-allClustersfromPc {
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
  begin {}
  process {
    try {
      $apiEndpoint = "/api/nutanix/v3/clusters/list"
      $apiMethod = "POST"
      $jsonRootPath = "entities"
      $apiKind = 'cluster'
        
      $clusterList = Get-AllPrismCentralObjectsByType `
        -prismCentralAddress $prismCentralConnection.prismCentralAddress `
        -prismCentralPort $prismCentralConnection.prismCentralPort `
        -prismCentralCredential $prismCentralConnection.prismCentralCredential `
        -apiEndpoint $apiEndpoint `
        -apiMethod $apiMethod `
        -jsonRootPath $jsonRootPath `
        -apiKind $apiKind
    
      write-host 'Number of clusters found: ' $clusterList.count
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
    return $clusterList
  }
}