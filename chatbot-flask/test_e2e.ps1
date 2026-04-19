$ErrorActionPreference = 'Stop'

# ==============================================================
# test_e2e.ps1 - Tests end-to-end du système chatbot AgriSmart
# Usage:
#   powershell -ExecutionPolicy Bypass -File .\test_e2e.ps1
#   $env:JWT_TOKEN = "<token>"; .\test_e2e.ps1
# ==============================================================

$McpUrl = 'http://127.0.0.1:5001'
$FlaskUrl = 'http://127.0.0.1:5002'
$SpringUrl = 'http://127.0.0.1:8080'
$GatewayUrl = 'http://127.0.0.1:8081'
$JwtToken = $env:JWT_TOKEN
$AdminEmail = if ($env:E2E_ADMIN_EMAIL) { $env:E2E_ADMIN_EMAIL } else { 'admin@agrismart.gn' }
$AdminPassword = if ($env:E2E_ADMIN_PASSWORD) { $env:E2E_ADMIN_PASSWORD } else { 'admin123' }

$results = @()

function Add-Result {
    param(
        [string]$Test,
        [string]$Status,
        [string]$Detail
    )
    $script:results += [pscustomobject]@{
        Test = $Test
        Status = $Status
        Detail = $Detail
    }
}

function Invoke-Test {
    param(
        [string]$Name,
        [scriptblock]$Action
    )
    try {
        $detail = & $Action
        Add-Result -Test $Name -Status 'PASS' -Detail $detail
    }
    catch {
        Add-Result -Test $Name -Status 'FAIL' -Detail $_.Exception.Message
    }
}

function Invoke-Json {
    param(
        [string]$Method,
        [string]$Uri,
        [hashtable]$Headers,
        [object]$Body,
        [int]$TimeoutSec = 12
    )

    $params = @{
        Method = $Method
        Uri = $Uri
        TimeoutSec = $TimeoutSec
    }

    if ($Headers) {
        $params.Headers = $Headers
    }

    if ($null -ne $Body) {
        $params.ContentType = 'application/json'
        $params.Body = ($Body | ConvertTo-Json -Depth 8)
    }

    return Invoke-RestMethod @params
}

Write-Host "=================================================="
Write-Host " AgriSmart - Tests E2E (PowerShell)"
Write-Host "=================================================="

Invoke-Test -Name 'MCP /health' -Action {
    $r = Invoke-Json -Method 'GET' -Uri "$McpUrl/health"
    return "mongo=$($r.mongo); status=$($r.status)"
}

Invoke-Test -Name 'MCP /execute users' -Action {
    $r = Invoke-Json -Method 'POST' -Uri "$McpUrl/execute" -Body @{
        collection = 'users'
        filter = @{}
        projection = @{ email = 1 }
        limit = 1
    }
    if ($r.status -ne 'ok') {
        throw "MCP returned status=$($r.status)"
    }
    return "count=$($r.count)"
}

Invoke-Test -Name 'Flask /health' -Action {
    $r = Invoke-Json -Method 'GET' -Uri "$FlaskUrl/health"
    return "mongo=$($r.mongo); groq=$($r.groq)"
}

$existingEmail = $null
try {
    $emailProbe = Invoke-Json -Method 'POST' -Uri "$McpUrl/execute" -Body @{
        collection = 'users'
        filter = @{}
        projection = @{ email = 1 }
        limit = 1
    }
    if ($emailProbe.results -and $emailProbe.results[0].email) {
        $existingEmail = [string]$emailProbe.results[0].email
    }
}
catch {
    # If probe fails, Flask /chat test below will mark failure with context.
}

if ([string]::IsNullOrWhiteSpace($existingEmail)) {
    Add-Result -Test 'Flask /chat (real user)' -Status 'FAIL' -Detail 'Impossible de récupérer un email depuis MCP/users'
}
else {
    Invoke-Test -Name 'Flask /chat (real user)' -Action {
        $r = Invoke-Json -Method 'POST' -Uri "$FlaskUrl/chat" -Body @{
            user_id = $existingEmail
            user_role = 'agriculteur'
            query = 'montre moi mes parcelles actives'
            lang = 'fr'
        } -TimeoutSec 20

        $intent = if ($r.intent) { $r.intent } else { 'n/a' }
        $err = if ($null -eq $r.error) { 'null' } else { [string]$r.error }
        return "intent=$intent; error=$err"
    }
}

if ([string]::IsNullOrWhiteSpace($JwtToken)) {
    try {
        $login = Invoke-Json -Method 'POST' -Uri "$GatewayUrl/api/auth/login" -Body @{
            email = $AdminEmail
            password = $AdminPassword
        } -TimeoutSec 20

        if ($login.accessToken) {
            $JwtToken = [string]$login.accessToken
        }
        elseif ($login.token) {
            $JwtToken = [string]$login.token
        }

        if ([string]::IsNullOrWhiteSpace($JwtToken)) {
            Add-Result -Test 'JWT auto-login' -Status 'FAIL' -Detail 'Login réussi mais token/accessToken absent'
        }
        else {
            Add-Result -Test 'JWT auto-login' -Status 'PASS' -Detail "email=$AdminEmail"
        }
    }
    catch {
        Add-Result -Test 'JWT auto-login' -Status 'FAIL' -Detail $_.Exception.Message
    }
}

if ([string]::IsNullOrWhiteSpace($JwtToken)) {
    Add-Result -Test 'Spring /api/chatbot/health (JWT)' -Status 'FAIL' -Detail 'JWT indisponible (login auto échoué)'
    Add-Result -Test 'Spring /api/chatbot/message (JWT)' -Status 'FAIL' -Detail 'JWT indisponible (login auto échoué)'
    Add-Result -Test 'Gateway /api/chatbot/message (JWT)' -Status 'FAIL' -Detail 'JWT indisponible (login auto échoué)'
}
else {
    $headers = @{ Authorization = "Bearer $JwtToken" }

    Invoke-Test -Name 'Spring /api/chatbot/health (JWT)' -Action {
        $r = Invoke-Json -Method 'GET' -Uri "$SpringUrl/api/chatbot/health" -Headers $headers
        return ($r | ConvertTo-Json -Compress)
    }

    Invoke-Test -Name 'Spring /api/chatbot/message (JWT)' -Action {
        $r = Invoke-Json -Method 'POST' -Uri "$SpringUrl/api/chatbot/message" -Headers $headers -Body @{
            query = 'montre moi mes parcelles'
            lang = 'fr'
        } -TimeoutSec 20
        return ($r | ConvertTo-Json -Compress)
    }

    Invoke-Test -Name 'Gateway /api/chatbot/message (JWT)' -Action {
        $r = Invoke-Json -Method 'POST' -Uri "$GatewayUrl/api/chatbot/message" -Headers $headers -Body @{
            query = 'comment ajouter une parcelle'
            lang = 'fr'
        } -TimeoutSec 20
        return ($r | ConvertTo-Json -Compress)
    }
}

Write-Host ''
$results | Format-Table -AutoSize

$pass = ($results | Where-Object Status -eq 'PASS').Count
$fail = ($results | Where-Object Status -eq 'FAIL').Count
$skip = ($results | Where-Object Status -eq 'SKIP').Count

Write-Host ''
Write-Host "RESULT: PASS=$pass FAIL=$fail SKIP=$skip"

if ($fail -gt 0) {
    exit 1
}

exit 0
