function Get-ClusterScenariosUuid {
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
        $prismCentralCredential = $prismCentralConnection.prismCentralCredential
        $prismCentralAddress = $prismCentralConnection.prismCentralAddress
        $prismCentralPort = $prismCentralConnection.prismCentralPort
        $apiEndpoint = "/api/nutanix/v3/capacity_planning/scenarios"
        $apiMethod = "GET"
        $jsonRootPath = "scenarios"
        #$apiKind = 'vm'
        
        write-host "https://${prismCentralAddress}:${prismCentralPort}${apiEndpoint}" 
        $restCallResult = Invoke-ApiCall `
            -credential $prismCentralCredential `
            -url "https://${prismCentralAddress}:${prismCentralPort}${apiEndpoint}" `
            -method $apiMethod 
          
        write-host 'Number of Capacity Scenarios found: ' $restCallResult.$jsonRootPath.count
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
      return $restCallResult.$jsonRootPath
    }
  }




###
function Get-AllClusterScenarios {
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
    [string[]] 
    $scenariosUuid

  )
  
  begin {
  
  }
  
  process {
    try {
      $prismCentralCredential = $prismCentralConnection.prismCentralCredential
      $prismCentralAddress = $prismCentralConnection.prismCentralAddress
      $prismCentralPort = $prismCentralConnection.prismCentralPort
      $apiEndpoint = "/api/nutanix/v3/capacity_planning/scenarios"
      $apiMethod = "GET"
      $jsonRootPath = "scenarios"
      #$apiKind = 'vm'
      $scenariosList = @()
      foreach ($uuid in $scenariosUuid){
        $restCallResult = Invoke-ApiCall `
            -credential $prismCentralCredential `
            -url "https://${prismCentralAddress}:${prismCentralPort}${apiEndpoint}/${uuid}" `
            -method $apiMethod
        $scenariosList = $scenariosList + $restCallResult
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
      return $scenariosList
    }
}
function Start-ScenarioByCluster {
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
      [string] 
      $scenarioUuid
  
    )
    
    begin {
    
    }
    
    process {
      try {
        $prismCentralCredential = $prismCentralConnection.prismCentralCredential
        $prismCentralAddress = $prismCentralConnection.prismCentralAddress
        $prismCentralPort = $prismCentralConnection.prismCentralPort
        $apiEndpoint = "/api/nutanix/v3/capacity_planning/recommendations"
        $apiMethod = "POST"
        $payloadParams = @{
            scenario_uuid = $scenarioUuid
        }
        $restCallResult = Invoke-ApiCall `
            -credential $prismCentralCredential `
            -url "https://${prismCentralAddress}:${prismCentralPort}${apiEndpoint}" `
            -method $apiMethod `
            -payload ($PayloadParams | ConvertTo-Json)
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
        return $restCallResult.task_uuid
      }
}
function Get-ScenarioResults {
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
      [string] 
      $scenarioTaskUuid
  
    )
    
    begin {
    
    }
    
    process {
      try {
        $prismCentralCredential = $prismCentralConnection.prismCentralCredential
        $prismCentralAddress = $prismCentralConnection.prismCentralAddress
        $prismCentralPort = $prismCentralConnection.prismCentralPort
        $apiEndpoint = "/api/nutanix/v3/capacity_planning/recommendations"
        $apiMethod = "GET"
        write-host $uuid
        write-host "https://${prismCentralAddress}:${prismCentralPort}${apiEndpoint}/${scenarioTaskUuid}" 
        $restCallResult = Invoke-ApiCall `
            -credential $prismCentralCredential `
            -url "https://${prismCentralAddress}:${prismCentralPort}${apiEndpoint}/${scenarioTaskUuid}" `
            -method $apiMethod `
            -payload ($PayloadParams | ConvertTo-Json)
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
        return $restCallResult
      }
}