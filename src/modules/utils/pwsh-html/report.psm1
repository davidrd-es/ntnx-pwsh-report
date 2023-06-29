function New-NutanixReport {
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
    [PSCustomObject[]] 
    $nutanixInventory,

    [parameter(mandatory = $true)]
    [string] 
    $reportPath
    #
    #[parameter(mandatory = $true)]
    #[pscredential] 
    #$prismCentralCredential
  )
  
  begin {}

  process {
    try {
      $timestamp = Get-Date -Format o | ForEach-Object { $_ -replace ":", "." }
      # Create Reports:
      New-HTML -TitleText 'Renesas Reporting tool' -Online -FilePath "${reportPath}\${timestamp}.html" {
        New-HTMLContent { #-HeaderText 'Summary' {
          New-HTMLContainer -Margin 'auto' {
            New-HTMLHeading -Heading h1 -HeadingText 'Instances Summary'
            New-HTMLContent -Invisible {
              New-HTMLPanel -Invisible {
                New-HTMLToast -TextHeader 'Prism Central' -Text $nutanixInventory.prismCentral.count -IconRegular building
              }
              New-HTMLPanel -Invisible {
                New-HTMLToast -TextHeader 'Clusters' -Text $nutanixInventory.clusters.count -IconRegular address-card
              }
              New-HTMLPanel -Invisible {
                New-HTMLToast -TextHeader 'Virtual Machines' -Text $nutanixInventory.virtualMachines.count -IconRegular address-card
              }
              New-HTMLPanel -Invisible {
                New-HTMLToast -TextHeader 'Calm Applications' -Text ($nutanixInventory.prismCentral | Select-Object -expand CalmApplications | Measure-Object -Sum).sum -IconRegular address-card
              }
              New-HTMLPanel -Invisible {
                New-HTMLToast -TextHeader 'Engineers' -Text $nutanixInventory.engineers.count -IconRegular user
              }
              New-HTMLPanel -Invisible {
                New-HTMLToast -TextHeader 'Purchased Calm Licenses' -Text $nutanixInventory.calmLicensesPurchased  -IconRegular credit-card
              }
              New-HTMLPanel -Invisible {
                if (($nutanixInventory.calmLicensesPurchased - ($nutanixInventory.prismCentral | Select-Object -expand CalmLicenses | Measure-Object -Sum).sum) -le 0){
                  New-HTMLToast -TextHeader 'Available Calm Licenses' -Text ($nutanixInventory.calmLicensesPurchased - ($nutanixInventory.prismCentral | Select-Object -expand CalmLicenses | Measure-Object -Sum).sum)  -IconRegular address-card -TextHeaderColor DarkRed -TextColor DarkRed -IconColor DarkRed -BarColorLeft DarkRed
                }
                elseif (($nutanixInventory.calmLicensesPurchased - ($nutanixInventory.prismCentral | Select-Object -expand CalmLicenses | Measure-Object -Sum).sum) -le 25) {
                  New-HTMLToast -TextHeader 'Available Calm Licenses' -Text ($nutanixInventory.calmLicensesPurchased - ($nutanixInventory.prismCentral | Select-Object -expand CalmLicenses | Measure-Object -Sum).sum)  -IconRegular address-card -TextHeaderColor DarkOrange -TextColor DarkOrange -IconColor DarkOrange -BarColorLeft DarkOrange
                }
                else {
                  New-HTMLToast -TextHeader 'Available Calm Licenses' -Text ($nutanixInventory.calmLicensesPurchased - ($nutanixInventory.prismCentral | Select-Object -expand CalmLicenses | Measure-Object -Sum).sum)  -IconRegular address-card
                }
              }
            }                 
          }
        }
        New-HTMLContent { #-HeaderText 'Licenses' {
          New-HTMLContainer -Margin 'auto' {
            New-HTMLHeading -Heading h1 -HeadingText 'Licenses'
            New-HTMLContent -Invisible {
              New-HTMLTableOption -DataStore JavaScript
              New-HTMLTable -DataTable $nutanixInventory.prismCentral -DataTableID 'prismCentral' 
            }
          }
        }

        New-HTMLContent {
          New-HTMLContainer -Margin 'auto' {
            New-HTMLHeading -Heading h1 -HeadingText 'Cluster Inventory'
            New-HTMLContent -Invisible {
              New-HTMLPanel {
                New-HTMLTable -DataTable $nutanixInventory.clusters -DataTableID 'cluster' {
                  New-HTMLTableCondition -Name 'GlobalRunwayDays' -ComparisonType number -Operator between -Value 121 180 -BackgroundColor Yellow -Color Black -HighlightHeaders GlobalRunwayDays 
                  New-HTMLTableCondition -Name 'GlobalRunwayDays' -ComparisonType number -Operator between -Value 61 120 -BackgroundColor DarkOrange -Color White -HighlightHeaders GlobalRunwayDays 
                  New-HTMLTableCondition -Name 'GlobalRunwayDays' -ComparisonType number -Operator between -Value 0 60 -BackgroundColor DarkRed -Color White -HighlightHeaders GlobalRunwayDays
                  
                  New-HTMLTableCondition -Name 'CPURunwayDays' -ComparisonType number -Operator between -Value 121 180 -BackgroundColor Yellow -Color Black -HighlightHeaders CPURunwayDays
                  New-HTMLTableCondition -Name 'CPURunwayDays' -ComparisonType number -Operator between -Value 61 120 -BackgroundColor DarkOrange -Color White -HighlightHeaders CPURunwayDays
                  New-HTMLTableCondition -Name 'CPURunwayDays' -ComparisonType number -Operator between -Value 0 60 -BackgroundColor DarkRed -Color White -HighlightHeaders CPURunwayDays
                  
                  New-HTMLTableCondition -Name 'MemoryRunwayDays' -ComparisonType number -Operator between -Value 121 180 -BackgroundColor Yellow -Color Black -HighlightHeaders MemoryRunwayDays             
                  New-HTMLTableCondition -Name 'MemoryRunwayDays' -ComparisonType number -Operator between -Value 61 120 -BackgroundColor DarkOrange -Color White -HighlightHeaders MemoryRunwayDays 
                  New-HTMLTableCondition -Name 'MemoryRunwayDays' -ComparisonType number -Operator between -Value 0 60 -BackgroundColor DarkRed -Color White -HighlightHeaders MemoryRunwayDays 

                  New-HTMLTableCondition -Name 'StorageRunwayDays' -ComparisonType number -Operator between -Value 121 180 -BackgroundColor Yellow -Color Black -HighlightHeaders StorageRunwayDays 
                  New-HTMLTableCondition -Name 'StorageRunwayDays' -ComparisonType number -Operator between -Value 61 120 -BackgroundColor DarkOrange -Color White -HighlightHeaders StorageRunwayDays 
                  New-HTMLTableCondition -Name 'StorageRunwayDays' -ComparisonType number -Operator between -Value 0 60 -BackgroundColor DarkRed -Color White -HighlightHeaders StorageRunwayDays 
                }
              }
            }
          }
        }
        New-HTMLContent { 
          New-HTMLContainer -Margin 'auto' {
            New-HTMLHeading -Heading h1 -HeadingText 'Virtual Machine Inventory'
            New-HTMLContent -Invisible {
              New-HTMLPanel {
                New-HTMLTable -DataTable $nutanixInventory.virtualMachines -DataTableID 'virtualMachine'
              }
            }
          }
        }
        New-HTMLContent { 
          New-HTMLContainer -Margin 'auto' {
            New-HTMLHeading -Heading h1 -HeadingText 'Engineers Inventory'
            New-HTMLContent -Invisible {
              New-HTMLPanel {
                New-HTMLTable -DataTable $nutanixInventory.engineers -DataTableID 'engineers'
              }
            }
          }
        }   
      } -Show

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