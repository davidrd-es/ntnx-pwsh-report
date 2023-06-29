function Get-AllPrismCentralObjectsByType {
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
        $prismCentralCredential,

        [parameter(mandatory = $true)]
        [string] 
        $apiEndpoint,

		[parameter(mandatory = $true)]
        [string] 
        $apiMethod,

		[parameter(mandatory = $false)]
        [string] 
        $jsonRootPath,

		[parameter(mandatory = $true)]
        [string] 
        $apiKind
    )
  
    begin{
  
    }
  
    process{
        try{
			$globalPayloadParams = @{
				kind = $apiKind
				offset = 0
				length = 200
			}
			$discoverRestApiCall = Invoke-ApiCall `
				-credential $prismCentralCredential `
				-url "https://${prismCentralAddress}:${prismCentralPort}${apiEndpoint}" `
				-method $apiMethod `
				-payload ($globalPayloadParams | ConvertTo-Json)
		
			$restApiIterations= [math]::ceiling($discoverRestApiCall.metadata.total_matches / $globalPayloadParams.length)
			
			for ($i = 0 ; $i -lt $restApiIterations; $i++){
				if (([int]$restApiIterations- [int]$i) -eq 1){
					$length = $discoverRestApiCall.metadata.total_matches - ($i * $globalPayloadParams.length)
				}
				else{
					$length = $globalPayloadParams.length
				}
				$payloadParams = @{
					kind = $globalPayloadParams.kind
					offset = ($i * $globalPayloadParams.length)
					length = $length 
				}
				$restCallResult = Invoke-ApiCall `
					-credential $prismCentralCredential `
					-url "https://${prismCentralAddress}:${prismCentralPort}${apiEndpoint}" `
					-method $apiMethod `
					-payload ($PayloadParams | ConvertTo-Json)
				if ($jsonRootPath){
					$objectList = $objectList + $restCallResult.$jsonRootPath
				} 
				else {
					$objectList = $objectList + $restCallResult
				}
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
        return $objectList
    }
}

function Get-PrismCentralObjectsByUuid {
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
      $prismCentralCredential,

      [parameter(mandatory = $true)]
      [string] 
      $apiEndpoint,

		  [parameter(mandatory = $true)]
      [string] 
      $apiMethod,
  
		  [parameter(mandatory = $false)]
      [string] 
      $jsonRootPath,
  
		  [parameter(mandatory = $false)]
      [string[]] 
      $uuidArray
    )
  
    begin{
  
    }
  
  process{
    try{
		  [array]$ObjectList = @()
		  foreach ($uuid in $uuidArray){
        if ($apiMethod -eq "GET"){
        	$restCallResult = Invoke-ApiCall `
		        -credential $prismCentralCredential `
		        -url "https://${prismCentralAddress}:${prismCentralPort}${apiEndpoint}${uuid}" `
		        -method $apiMethod `
		  	}
		  	else{
          $restCallResult = Invoke-ApiCall `
		      	-credential $prismCentralCredential `
		      	-url "https://${prismCentralAddress}:${prismCentralPort}${apiEndpoint}${uuid}" `
		      	-method $apiMethod `
		      	-payload ($PayloadParams | ConvertTo-Json)					
		  	}
		  	if ($jsonRootPath){
		      	$ObjectList += $restCallResult.$jsonRootPath
		    } 
		    else {
		      	$objectList += $restCallResult
		    }
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
      return $objectList
  }
}

function Get-PrismCentralObjectsByUuid {
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
      $prismCentralCredential,

      [parameter(mandatory = $true)]
      [string] 
      $apiEndpoint,

		  [parameter(mandatory = $true)]
      [string] 
      $apiMethod,
  
		  [parameter(mandatory = $false)]
      [string] 
      $jsonRootPath,
  
		  [parameter(mandatory = $false)]
      [string[]] 
      $uuidArray
    )
  
    begin{
  
    }
  
  process{
    try{
		  [array]$ObjectList = @()
		  foreach ($uuid in $uuidArray){
        if ($apiMethod -eq "GET"){
        	$restCallResult = Invoke-ApiCall `
		        -credential $prismCentralCredential `
		        -url "https://${prismCentralAddress}:${prismCentralPort}${apiEndpoint}${uuid}" `
		        -method $apiMethod `
		  	}
		  	else{
          $restCallResult = Invoke-ApiCall `
		      	-credential $prismCentralCredential `
		      	-url "https://${prismCentralAddress}:${prismCentralPort}${apiEndpoint}${uuid}" `
		      	-method $apiMethod `
		      	-payload ($PayloadParams | ConvertTo-Json)					
		  	}
		  	if ($jsonRootPath){
		      	$ObjectList += $restCallResult.$jsonRootPath
		    } 
		    else {
		      	$objectList += $restCallResult
		    }
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
      return $objectList
  }
}