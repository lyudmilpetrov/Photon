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
    # https://nominatim.openstreetmap.org/search.php?street=412%20Asbury%20Avenue&city=Ocean%20City&state=New%20Jersey&country=United%20States&postalcode=08226&polygon_geojson=1&format=jsonv2

    $baseURL = "http://localhost:2322/api?q="
    $url = $baseURL + $address + "&limit=1000"
    # Log input parameters
    $inputParams = "Inputs - Country: $country, State: $state, City: $city, Street: $street, PostCode: $postCode, Email: $email, URL: $url"
    Write-Log -Message $inputParams
    try {
        $response = Invoke-WebRequest -Uri $url -UseBasicParsing
        if ($response.StatusCode -eq 200) {
            $jsonArray = ConvertFrom-Json $response.Content
            if ($jsonArray.features.Count -gt 0) {
                $firstFeature = $jsonArray.features[0]
                $lat = $firstFeature.geometry.coordinates[1]
                $lon = $firstFeature.geometry.coordinates[0]
                # Log result
                $result = "Latitude: $lat, Longitude: $lon"
                Write-Log -Message "Result - $result"
                return $result
            }
            else {
                Write-Log -Message "No results found at $url"
                return "No results found at $url"
            }
        }
        else {
            Write-Log -Message "Error: Unable to retrieve coordinates at $url"
            return "Error: Unable to retrieve coordinates at $url"
        }
    }
    catch {
        Write-Log -Message "$($_.Exception.Message) for $url"
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
