[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', '', Justification='Test automation script; authentication helper uses PSCredential.')]
param(
    [string]$GatewayBaseUrl = "http://localhost:8081",
    [string]$BackendBaseUrl = "http://localhost:8080",
    [string]$ChatbotBaseUrl = "http://localhost:5005",
    [string]$FrontendBaseUrl = "http://localhost:4200"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Continue"

# Couleurs pour l'affichage
function Write-Success { Write-Host "[OK] $($args -join ' ')" -ForegroundColor Green }
function Write-Error-Custom { Write-Host "[FAIL] $($args -join ' ')" -ForegroundColor Red }
function Write-Warning-Custom { Write-Host "[WARN] $($args -join ' ')" -ForegroundColor Yellow }
function Write-Info { Write-Host "[INFO] $($args -join ' ')" -ForegroundColor Cyan }
function Write-Section { Write-Host "`n$('='*60)" -ForegroundColor Blue; Write-Host "$($args -join ' ')" -ForegroundColor Blue; Write-Host "$('='*60)" -ForegroundColor Blue }

# Compteurs
$totalTests = 0
$passedTests = 0
$failedTests = 0

function Test-Service {
    param(
        [string]$ServiceName,
        [string]$HealthEndpoint,
        [int]$Port
    )
    
    $totalTests++
    Write-Info "Testing $ServiceName..."
    
    try {
        Invoke-RestMethod -Uri $HealthEndpoint -Method Get -TimeoutSec 5 -ErrorAction Stop | Out-Null
        Write-Success "$ServiceName is running (port $Port)"
        $passedTests++
        return $true
    }
    catch {
        Write-Error-Custom "$ServiceName is NOT running (port $Port)"
        Write-Error-Custom "  Error: $($_.Exception.Message)"
        $failedTests++
        return $false
    }
}

function Test-Database {
    param(
        [string]$DBHost = "localhost",
        [int]$Port = 27017
    )
    
    $totalTests++
    Write-Info "Testing MongoDB connection..."
    
    try {
        $tcpClient = New-Object System.Net.Sockets.TcpClient
        $tcpClient.Connect($DBHost, $Port)
        if ($tcpClient.Connected) {
            Write-Success "MongoDB is accessible on $DBHost`:$Port"
            $passedTests++
            $tcpClient.Close()
            return $true
        }
    }
    catch {
        Write-Error-Custom "Cannot connect to MongoDB on $DBHost`:$Port"
        Write-Error-Custom "  Error: $($_.Exception.Message)"
        $failedTests++
        return $false
    }
    
    return $false
}

function Test-Authentication {
    param(
        [PSCredential]$Credential = $(
            New-Object System.Management.Automation.PSCredential(
                "admin@agrismart.gn",
                (ConvertTo-SecureString "admin123" -AsPlainText -Force)
            )
        ),
        [string]$LoginEndpoint
    )
    
    $totalTests++
    Write-Info "Testing authentication..."
    
    try {
        $resolvedEmail = if ($Credential -and $Credential.UserName) { $Credential.UserName } else { "admin@agrismart.gn" }
        $resolvedPassword = if ($Credential) { $Credential.GetNetworkCredential().Password } else { "" }

        $body = @{
            email = $resolvedEmail
            password = $resolvedPassword
        } | ConvertTo-Json
        
        $response = Invoke-RestMethod -Uri $LoginEndpoint `
            -Method Post `
            -ContentType "application/json" `
            -Body $body `
            -TimeoutSec 5 `
            -ErrorAction Stop
        
        if ($response.token -or $response.accessToken -or $response.access_token) {
            Write-Success "Authentication successful - Token received"
            $passedTests++
            return $response
        }
        else {
            Write-Warning-Custom "Authentication returned no token"
            $failedTests++
            return $null
        }
    }
    catch {
        Write-Error-Custom "Authentication failed"
        Write-Error-Custom "  Error: $($_.Exception.Message)"
        $failedTests++
        return $null
    }
}

function Resolve-AccessToken {
    param(
        [Parameter(Mandatory = $true)]$LoginResponse
    )

    if ($null -eq $LoginResponse) {
        return $null
    }

    if ($LoginResponse.PSObject.Properties.Name -contains 'token' -and $LoginResponse.token) {
        return [string]$LoginResponse.token
    }
    if ($LoginResponse.PSObject.Properties.Name -contains 'accessToken' -and $LoginResponse.accessToken) {
        return [string]$LoginResponse.accessToken
    }
    if ($LoginResponse.PSObject.Properties.Name -contains 'access_token' -and $LoginResponse.access_token) {
        return [string]$LoginResponse.access_token
    }

    return $null
}

function Test-AuthenticatedEndpoint {
    param(
        [string]$Endpoint,
        [string]$Token,
        [string]$TestName
    )
    
    $totalTests++
    Write-Info "Testing $TestName..."
    
    try {
        $headers = @{
            "Authorization" = "Bearer $Token"
        }
        
        $response = Invoke-RestMethod -Uri $Endpoint `
            -Method Get `
            -Headers $headers `
            -TimeoutSec 5 `
            -ErrorAction Stop
        
        Write-Success "$TestName successful"
        $passedTests++
        return $response
    }
    catch {
        Write-Error-Custom "$TestName failed"
        Write-Error-Custom "  Error: $($_.Exception.Message)"
        $failedTests++
        return $null
    }
}

function Test-CORS {
    param(
        [string]$Endpoint,
        [string]$Origin = "http://localhost:4200"
    )
    
    $totalTests++
    Write-Info "Testing CORS headers..."
    
    try {
        $response = Invoke-WebRequest -Uri $Endpoint `
            -Method Options `
            -Headers @{"Origin" = $Origin} `
            -TimeoutSec 5 `
            -ErrorAction Stop
        
        $corsHeader = $response.Headers["Access-Control-Allow-Origin"]
        
        if ($corsHeader -eq $Origin -or $corsHeader -eq "*") {
            Write-Success "CORS is properly configured"
            $passedTests++
            return $true
        }
        else {
            Write-Warning-Custom "CORS header not as expected: $corsHeader"
            $failedTests++
            return $false
        }
    }
    catch {
        Write-Error-Custom "CORS test failed"
        Write-Error-Custom "  Error: $($_.Exception.Message)"
        $failedTests++
        return $false
    }
}

# ==================== MAIN EXECUTION ====================

Write-Section "AGRISMART COMPLETE VERIFICATION"
Write-Info "Gateway: $GatewayBaseUrl"
Write-Info "Backend: $BackendBaseUrl"
Write-Info "Chatbot: $ChatbotBaseUrl"
Write-Info "Frontend: $FrontendBaseUrl"

# 1. Database Check
Write-Section "1. DATABASE CHECK"
Test-Database

# 2. Services Health Check
Write-Section "2. SERVICES HEALTH CHECK"
Test-Service "Backend Spring Boot" "$BackendBaseUrl/actuator/health" 8080
Test-Service "Chatbot Flask" "$ChatbotBaseUrl/health" 5005
Test-Service "API Gateway" "$GatewayBaseUrl/api/auth/health" 8081

# 3. Frontend Accessibility
Write-Section "3. FRONTEND ACCESSIBILITY"
$totalTests++
try {
    $response = Invoke-WebRequest -Uri $FrontendBaseUrl -TimeoutSec 5 -ErrorAction Stop
    if ($response.StatusCode -eq 200) {
        Write-Success "Frontend is accessible"
        $passedTests++
    }
}
catch {
    Write-Error-Custom "Cannot access frontend"
    Write-Error-Custom "  Error: $($_.Exception.Message)"
    $failedTests++
}

# 4. Authentication Test
Write-Section "4. AUTHENTICATION TEST"
$loginEndpoint = "$GatewayBaseUrl/api/auth/login"
$authResponse = Test-Authentication -LoginEndpoint $loginEndpoint

if ($authResponse) {
    $token = Resolve-AccessToken -LoginResponse $authResponse
    if (-not $token) {
        Write-Error-Custom "Authentication succeeded but no usable JWT token was found"
        $failedTests++
    }
    
    if ($token) {
        # 5. API Access with Token
        Write-Section "5. AUTHENTICATED ENDPOINTS TEST"
        Test-AuthenticatedEndpoint -Endpoint "$GatewayBaseUrl/api/users/profile" -Token $token -TestName "User Profile"

        # 6. Chatbot Integration
        Write-Section "6. CHATBOT INTEGRATION TEST"
        $totalTests++
        Write-Info "Testing chatbot message endpoint..."
        try {
            $chatbotBody = @{
                message = "Bonjour"
            } | ConvertTo-Json

            $chatbotHeaders = @{
                "Authorization" = "Bearer $token"
            }

            Invoke-RestMethod -Uri "$GatewayBaseUrl/chatbot/message" `
                -Method Post `
                -ContentType "application/json" `
                -Headers $chatbotHeaders `
                -Body $chatbotBody `
                -TimeoutSec 10 `
                -ErrorAction Stop | Out-Null

            Write-Success "Chatbot message sent and response received"
            $passedTests++
        }
        catch {
            Write-Warning-Custom "Chatbot message test failed (might need LLM key configured)"
            Write-Warning-Custom "  Error: $($_.Exception.Message)"
            $failedTests++
        }
    }
}
else {
    Write-Warning-Custom "Cannot proceed with authenticated tests - authentication failed"
}

# 7. CORS Test
Write-Section "7. CORS CONFIGURATION TEST"
Test-CORS -Endpoint "$GatewayBaseUrl/api/auth/health"

# 8. Gateway Routing Test
Write-Section "8. GATEWAY ROUTING TEST"
$totalTests++
Write-Info "Testing gateway routing to backend..."
try {
    $response = Invoke-RestMethod -Uri "$GatewayBaseUrl/api/actuator/info" -TimeoutSec 5 -ErrorAction Stop
    Write-Success "Gateway correctly routes to Spring Boot"
    $passedTests++
}
catch {
    Write-Warning-Custom "Cannot verify backend routing through gateway"
    $failedTests++
}

# ==================== SUMMARY ====================
Write-Section "TEST SUMMARY"
Write-Host "Total Tests: $totalTests" -ForegroundColor Cyan
Write-Success "Passed: $passedTests"
if ($failedTests -gt 0) {
    Write-Error-Custom "Failed: $failedTests"
}

$percentage = if ($totalTests -gt 0) { [math]::Round(($passedTests / $totalTests) * 100, 2) } else { 0 }
Write-Info "Success Rate: $percentage%"

if ($failedTests -eq 0) {
    Write-Host "`n*** ALL TESTS PASSED! Application is ready for testing. ***" -ForegroundColor Green
    exit 0
}
else {
    Write-Host "`n*** Some services may need attention. Check logs above. ***" -ForegroundColor Yellow
    exit 1
}
