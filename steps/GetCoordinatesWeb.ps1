param (
    [string]$country,
    [string]$state,
    [string]$city,
    [string]$street,
    [string]$postCode,
    [string]$email
)
function Get-CoordinatesFromAddress {
param (
    [string]$country,
    [string]$state,
    [string]$city,
    [string]$street,
    [string]$postCode,
    [string]$email
)

    # Concatenate address
    $address = Concatenate-Address -country $country -state $state -city $city -street $street -postCode $postCode
    $baseURL = "https://nominatim.openstreetmap.org/search?q="
    $url = $baseURL + $address + "&format=json&addressdetails=0&extratags=0&limit=10&namedetails=0&bounded=0&email=$email&dedupe=0"
    $inputParams = "Inputs - Country: $country, State: $state, City: $city, Street: $street, PostCode: $postCode, Email: $email, URL: $url"
    Write-Log -Message $inputParams
    try {
        $response = Invoke-WebRequest -Uri $url -UseBasicParsing
        if ($response.StatusCode -eq 200) {
            $jsonArray = ConvertFrom-Json $response.Content
            $houseResult = $jsonArray | Where-Object { $_.type -eq 'house' } | Select-Object -First 1
            if ($houseResult) {
                $lat = $houseResult.lat
                $lon = $houseResult.lon
                return "Latitude: $lat, Longitude: $lon"
            } else {
                return "No house type results found at $url"
            }
        } else {
            return "Error: Unable to retrieve coordinates at $url"
        }
    }
    catch {
        return "$($_.Exception.Message) for $url"
    }
}

function Concatenate-Address {
    param (
        [string]$country,
        [string]$state,
        [string]$city,
        [string]$street,
        [string]$postCode
    )

    # Build address string
    $addressParts = @($street, $city, $state, $postCode, $country)
    $address = ($addressParts -ne '' -join ',').Replace(' ', '+')
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
