function Get-allCalmAppsfromPc{
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
  
    begin{
  
    }
  
    process{
        try{
            $apiEndpoint = '/api/nutanix/v3/apps/list'
            $apiMethod = 'POST'
            $jsonRootPath = 'entities'
            $apiKind = 'app'
            
            $calmAppList = Get-AllPrismCentralObjectsByType `
                -prismCentralAddress $prismCentralConnection.prismCentralAddress `
                -prismCentralPort $prismCentralConnection.prismCentralPort `
                -prismCentralCredential $prismCentralConnection.prismCentralCredential `
                -apiEndpoint $apiEndpoint `
                -apiMethod $apiMethod `
                -jsonRootPath $jsonRootPath `
                -apiKind $apiKind
        
            write-host 'Number of Calm Applications found: ' $calmAppList.count
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
    
    end{
        return $calmAppList
    }
}

function Get-CalmAppDetailsByUuid {
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
        $calmAppsUuidList
    )
  
    begin{
  
    }
  
    process{
        try{
            $apiEndpoint = '/api/nutanix/v3/apps/'
            $apiMethod = 'GET'
            $jsonRootPath = ''
            #$apiKind = 'app'
			$calmAppList = Get-PrismCentralObjectsByUuid `
				-prismCentralAddress $prismCentralConnection.prismCentralAddress `
				-prismCentralPort $prismCentralConnection.prismCentralPort `
				-prismCentralCredential $prismCentralConnection.prismCentralCredential `
				-apiEndpoint $apiEndpoint `
				-apiMethod $apiMethod `
				-jsonRootPath $jsonRootPath `
				-uuidArray $calmAppsUuidList

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
    end{
        return $calmAppList
    }  
}

function Get-CalmAppByVmUuid{
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
        $virtualMachineUuid,
   
        [parameter(mandatory = $true)]
        [Object[]] 
        $calmAppList
    )
  
    begin{
  
    }
  
    process{
        try{
			foreach ($calmApp in $calmAppList){
				if ($calmApp.status.resources.deployment_list.Where({$_.substrate_configuration.element_list.instance_id -eq $virtualMachineUuid})){
					$result = $calmApp
					break
				}
				else{}
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
    end{
        return $result
    }
}