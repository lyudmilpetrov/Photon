param (
    [string]$country,
    [string]$state,
    [string]$city,
    [string]$street,
    [string]$streetNumber,
    [string]$postCode,
    [string]$email
)
function Get-CoordinatesFromAddress {
    param (
        [string]$country,
        [string]$state,
        [string]$city,
        [string]$street,
        [string]$streetNumber,
        [string]$postCode,
        [string]$email
    )

    $baseURL = "http://localhost:2322/api?q="
    $address = Concatenate-Address -country $country -state $state -city $city -street $street -streetNumber $streetNumber -postCode $postCode
    $url = $baseURL + $address + "&limit=1000"

    Write-Log -Message "URL: $url"
    try {
        $response = Invoke-WebRequest -Uri $url -UseBasicParsing
        if ($response.StatusCode -eq 200) {
            $jsonArray = ConvertFrom-Json $response.Content
            foreach ($feature in $jsonArray.features) {
                $isMatch = $true

                # Check each property only if the corresponding variable is not empty
                if ($country.Length -gt 0 -and $feature.properties.country -ne $country) { $isMatch = $false }
                if ($state.Length -gt 0 -and $feature.properties.state -ne $state) { $isMatch = $false }
                if ($city.Length -gt 0 -and $feature.properties.city -ne $city) { $isMatch = $false }
                if ($street.Length -gt 0 -and $feature.properties.street -ne $street) { $isMatch = $false }
                if ($streetNumber.Length -gt 0 -and $feature.properties.PSObject.Properties.Name -contains 'housenumber' -and $feature.properties.housenumber -ne $streetNumber) { $isMatch = $false }
                if ($postCode.Length -gt 0 -and $feature.properties.postcode -ne $postCode) { $isMatch = $false }
                if ($isMatch) {
                    $lat = $feature.geometry.coordinates[1]
                    $lon = $feature.geometry.coordinates[0]
                    $result = "Latitude: $lat, Longitude: $lon"
                    Write-Log -Message "Matching result - $result"
                    return $result
                }
            }
            Write-Log -Message "No matching results found"
            return "No matching results found"
        }
        else {
            Write-Log -Message "Error: Unable to retrieve coordinates"
            return "Error: Unable to retrieve coordinates"
        }
    }
    catch {
        Write-Log -Message "$($_.Exception.Message)"
        return "$($_.Exception.Message)"
    }
}

# Rest of the script remains the same


function Concatenate-Address {
    param (
        [string]$country,
        [string]$state,
        [string]$city,
        [string]$street,
        [string]$streetNumber,
        [string]$postCode
    )

    # Build address string
    $addressParts = @($streetNumber, $street, $city, $state, $postCode, $country)
    $address = ($addressParts -ne '' -join ',')
    #.Replace(' ', '+')
    return $address
}


function Write-Log {
    param (
        [string]$Message
    )
    $logFile = "C:\Photon\log.txt"
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $logFile -Value "[$timestamp] $Message"
}


# Invoke the function with command-line arguments
$result = Get-CoordinatesFromAddress -country $country -state $state -city $city -street $street -postCode $postCode -email $email
Write-Output $result
