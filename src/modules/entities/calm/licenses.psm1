
#api/nutanix/v3/groups
#{"entity_type":"nucalm_consumption","query_name":"prism:CPQueryModel","group_member_attributes":[{"attribute":"required_packs"},{"attribute":"unique_active_vms"},{"attribute":"cluster_wise_consumption"}]}


function Get-CalmLicenses {
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
        $apiEndpoint = "/api/nutanix/v3/groups"
        $apiMethod = "POST"
        $payloadParams = @{
            entity_type             = "nucalm_consumption"
            query_name              = "prism:CPQueryModel"
            group_member_attributes = @(
                @{attribute = "required_packs"}
                @{attribute = "unique_active_vms"}
                @{attribute = "cluster_wise_consumption"}
            )
        }
        $restCallResult = Invoke-ApiCall `
            -credential $prismCentralCredential `
            -url "https://${prismCentralAddress}:${prismCentralPort}${apiEndpoint}" `
            -method $apiMethod `
            -payload ($PayloadParams | ConvertTo-Json)
        $licenseSummary = $restCallResult.group_results.entity_results.data.where({$_.name -like "cluster_wise_consumption"}).values.values | ConvertFrom-Json
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
        return $licenseSummary
      }
}