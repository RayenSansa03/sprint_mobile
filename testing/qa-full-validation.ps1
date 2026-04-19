param(
    [string]$GatewayBaseUrl = "http://localhost:8081",
    [string]$ChatbotBaseUrl = "http://localhost:5005",
    [string]$AdminEmail = "admin@agrismart.gn",
    [string]$AdminPassword = "admin123"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Continue"

function Get-Token($loginResponse) {
    if ($null -eq $loginResponse) { return $null }
    if ($loginResponse.PSObject.Properties.Name -contains 'accessToken' -and $loginResponse.accessToken) { return [string]$loginResponse.accessToken }
    if ($loginResponse.PSObject.Properties.Name -contains 'access_token' -and $loginResponse.access_token) { return [string]$loginResponse.access_token }
    if ($loginResponse.PSObject.Properties.Name -contains 'token' -and $loginResponse.token) { return [string]$loginResponse.token }
    return $null
}

function Try-Call {
    param(
        [scriptblock]$Action,
        [string]$Label
    )
    try {
        $result = & $Action
        [PSCustomObject]@{ ok = $true; label = $Label; data = $result; error = $null }
    } catch {
        $status = $null
        $raw = $null
        if ($_.Exception.Response) {
            try { $status = [int]$_.Exception.Response.StatusCode } catch {}
            try {
                $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
                $raw = $reader.ReadToEnd()
            } catch {}
        }
        if (-not $raw -and $_.ErrorDetails) { $raw = $_.ErrorDetails.Message }
        [PSCustomObject]@{ ok = $false; label = $Label; data = $null; error = $_.Exception.Message; status = $status; raw = $raw }
    }
}

function Preview-Reply($value, $maxLen = 220) {
    if ($null -eq $value) { return "" }
    $text = [string]$value
    if ($text.Length -le $maxLen) { return $text }
    return $text.Substring(0, $maxLen) + "..."
}

$report = [ordered]@{}

$login = Try-Call -Label "gateway-login" -Action {
    $body = @{ email = $AdminEmail; password = $AdminPassword } | ConvertTo-Json
    Invoke-RestMethod -Uri "$GatewayBaseUrl/api/auth/login" -Method Post -ContentType "application/json" -Body $body -TimeoutSec 10
}

$token = $null
if ($login.ok) { $token = Get-Token $login.data }
$report.login = [ordered]@{
    ok = $login.ok
    token_present = [bool]$token
    fields = if ($login.ok) { @($login.data.PSObject.Properties.Name) } else { @() }
    error = if (-not $login.ok) { $login.raw } else { $null }
}

if (-not $token) {
    $report | ConvertTo-Json -Depth 12
    exit 1
}

$headers = @{ Authorization = "Bearer $token" }

$report.security = [ordered]@{}
$report.security.no_token_chatbot_auth = Try-Call -Label "no-token-chatbot-auth" -Action {
    Invoke-RestMethod -Uri "$ChatbotBaseUrl/api/chatbot/auth-test" -Method Get -TimeoutSec 8
}
$report.security.gateway_chatbot_auth = Try-Call -Label "gateway-chatbot-auth" -Action {
    Invoke-RestMethod -Uri "$GatewayBaseUrl/chatbot/auth-test" -Method Get -Headers $headers -TimeoutSec 8
}
$report.security.direct_chatbot_auth = Try-Call -Label "direct-chatbot-auth" -Action {
    Invoke-RestMethod -Uri "$ChatbotBaseUrl/api/chatbot/auth-test" -Method Get -Headers $headers -TimeoutSec 8
}
$report.security.backend_profile = Try-Call -Label "backend-profile" -Action {
    Invoke-RestMethod -Uri "$GatewayBaseUrl/api/users/profile" -Method Get -Headers $headers -TimeoutSec 10
}

$chatTests = @(
    @{ key = "rag_tomates"; message = "Quand planter les tomates ?"; profile = "agriculteur"; sid = "qa-rag-1" },
    @{ key = "rag_maladie_feuilles"; message = "Comment traiter une maladie des feuilles ?"; profile = "agriculteur"; sid = "qa-rag-2" },
    @{ key = "profile_agriculteur"; message = "Je suis quel type d'utilisateur ?"; profile = "agriculteur"; sid = "qa-profile-a" },
    @{ key = "profile_admin"; message = "Je suis quel type d'utilisateur ?"; profile = "admin"; sid = "qa-profile-ad" },
    @{ key = "profile_cooperative"; message = "Je suis quel type d'utilisateur ?"; profile = "cooperative"; sid = "qa-profile-c" },
    @{ key = "profile_ong"; message = "Je suis quel type d'utilisateur ?"; profile = "ong"; sid = "qa-profile-o" },
    @{ key = "tool_market"; message = "Donne-moi les prix du marché"; profile = "agriculteur"; sid = "qa-tool-1" }
)

$chatResults = [ordered]@{}
foreach ($t in $chatTests) {
    $res = Try-Call -Label $t.key -Action {
        $body = @{
            message = $t.message
            profile = $t.profile
            lang = "fr"
            session_id = $t.sid
            debug = $true
        } | ConvertTo-Json
        Invoke-RestMethod -Uri "$ChatbotBaseUrl/api/chatbot/message" -Method Post -Headers $headers -ContentType "application/json" -Body $body -TimeoutSec 20
    }

    if ($res.ok) {
        $chatResults[$t.key] = [ordered]@{
            ok = $true
            profile = $res.data.profile
            intent = $res.data.intent
            provider = $res.data.provider
            confidence = $res.data.confidence
            reply_preview = Preview-Reply $res.data.reply
            sources_count = @($res.data.sources).Count
            debug_present = [bool]$res.data.debug
            debug_retrieved_docs_count = if ($res.data.debug) { @($res.data.debug.retrieved_docs).Count } else { 0 }
        }
    } else {
        $chatResults[$t.key] = [ordered]@{
            ok = $false
            status = $res.status
            error = $res.raw
        }
    }
}
$report.chatbot = $chatResults

$mem1 = Try-Call -Label "memory-step-1" -Action {
    $body = @{
        message = "Je vends du maïs."
        profile = "agriculteur"
        lang = "fr"
        session_id = "qa-memory-1"
        debug = $true
    } | ConvertTo-Json
    Invoke-RestMethod -Uri "$ChatbotBaseUrl/api/chatbot/message" -Method Post -Headers $headers -ContentType "application/json" -Body $body -TimeoutSec 20
}
$mem2 = Try-Call -Label "memory-step-2" -Action {
    $body = @{
        message = "Donne-moi maintenant des conseils pour améliorer mes ventes."
        profile = "agriculteur"
        lang = "fr"
        session_id = "qa-memory-1"
        debug = $true
    } | ConvertTo-Json
    Invoke-RestMethod -Uri "$ChatbotBaseUrl/api/chatbot/message" -Method Post -Headers $headers -ContentType "application/json" -Body $body -TimeoutSec 20
}

$report.memory = [ordered]@{
    step1_ok = $mem1.ok
    step2_ok = $mem2.ok
    step1_preview = if ($mem1.ok) { Preview-Reply $mem1.data.reply 160 } else { $mem1.raw }
    step2_preview = if ($mem2.ok) { Preview-Reply $mem2.data.reply 200 } else { $mem2.raw }
    step2_mentions_context_hint = if ($mem2.ok) { ([string]$mem2.data.reply).ToLower().Contains("vendre") -or ([string]$mem2.data.reply).ToLower().Contains("vente") } else { $false }
}

$tts = Try-Call -Label "tts" -Action {
    $body = @{ text = "Bonjour test audio AgriSmart"; lang = "fr" } | ConvertTo-Json
    Invoke-WebRequest -Uri "$ChatbotBaseUrl/api/chatbot/tts" -Method Post -Headers $headers -ContentType "application/json" -Body $body -OutFile ".\testing\qa_tts_test.mp3" -PassThru -TimeoutSec 30 -UseBasicParsing
}
$report.tts = [ordered]@{
    ok = $tts.ok
    status = if ($tts.ok) { [int]$tts.data.StatusCode } else { $tts.status }
    content_type = if ($tts.ok) { [string]$tts.data.Headers["Content-Type"] } else { $null }
    output_file = if ($tts.ok) { "testing/qa_tts_test.mp3" } else { $null }
    error = if (-not $tts.ok) { $tts.raw } else { $null }
}

$report | ConvertTo-Json -Depth 12
