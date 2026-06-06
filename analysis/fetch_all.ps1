# ================================================================
#  fetch_all.ps1  —  Raw data collector: Git + Slack + Trello + gh
#
#  REQUIRED (always):
#    -SlackToken    Bot/User token   (xoxb-... hoặc xoxp-...)
#    -SlackChannel  Channel ID       (C0xxxxxxx — lấy từ URL Slack)
#    -TrelloKey     Trello API Key   (https://trello.com/app-key)
#    -TrelloToken   Trello Token     (https://trello.com/1/authorize?...)
#    -TrelloBoardId Board ID         (slug 8 ký tự trong URL board)
#
#  OPTIONAL:
#    -OutDir        Output folder    (default: .\raw_data)
#    -WithGhPR      Switch: also fetch PR data via gh CLI
#    -Owner         GitHub owner     (required if -WithGhPR)
#    -Repo          GitHub repo      (required if -WithGhPR)
#
#  EXAMPLES:
#    # Git + Slack + Trello only
#    .\fetch_all.ps1 -SlackToken "xoxb-xxx" -SlackChannel "C0xxx" `
#                    -TrelloKey "yyy" -TrelloToken "zzz" -TrelloBoardId "aaa"
#
#    # + GitHub PRs via gh
#    .\fetch_all.ps1 -SlackToken "xoxb-xxx" -SlackChannel "C0xxx" `
#                    -TrelloKey "yyy" -TrelloToken "zzz" -TrelloBoardId "aaa" `
#                    -WithGhPR -Owner phuctanpham -Repo ctetris
# ================================================================
param(
    # Slack
    [string]$SlackToken = "",
    [string]$SlackChannel = "",

    # Trello
    [string]$TrelloKey = "",
    [string]$TrelloToken = "",
    [string]$TrelloBoardId = "",

    # Output
    [string]$OutDir = ".\raw_data"

    # Note: GitHub PR options are read from environment variables (see below)
)

# GitHub PR via gh CLI: read from environment variables instead of CLI params
# Define Owner/Repo and WithGhPR variables (env-controlled)
[string]$Owner = ""
[string]$Repo = ""
$WithGhPR = $false
## Load .env file (optional) and populate process environment variables early
function Load-DotEnv($path) {
    if (-not (Test-Path $path)) { return }
    Get-Content $path | ForEach-Object {
        $line = $_.Trim()
        if (-not $line -or $line.StartsWith('#')) { return }
        $parts = $line -split '=', 2
        if ($parts.Count -lt 2) { return }
        $k = $parts[0].Trim()
        $v = $parts[1].Trim()
        if ($v.StartsWith('"') -and $v.EndsWith('"')) { $v = $v.Substring(1,$v.Length-2) }
        if ($v.StartsWith("'") -and $v.EndsWith("'")) { $v = $v.Substring(1,$v.Length-2) }
        try { Set-Item -Path ("env:" + $k) -Value $v -ErrorAction SilentlyContinue } catch {}
    }
}

# Try to load .env from repo root (one level above this script) or script dir
 $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
Write-Host "DEBUG: PSScriptRoot = $PSScriptRoot" -ForegroundColor DarkGray
Write-Host "DEBUG: repoRoot = $repoRoot" -ForegroundColor DarkGray
$dotEnvPaths = @( (Join-Path $repoRoot ".env"), (Join-Path $PSScriptRoot ".env") )
for ($i=0; $i -lt $dotEnvPaths.Count; $i++) {
    $p = $dotEnvPaths[$i]
    Write-Host "DEBUG: dotEnvPaths[$i] = [$p]  (type=$($p.GetType().FullName))" -ForegroundColor DarkGray
    if (Test-Path $p) { Write-Host "DEBUG: loading $p" -ForegroundColor DarkGray ; Load-DotEnv $p } else { Write-Host "DEBUG: not found $p" -ForegroundColor DarkGray }
}

## Populate parameters from environment variables (now that .env has been loaded)
if (-not $SlackToken -and $env:SLACK_TOKEN)    { $SlackToken    = $env:SLACK_TOKEN }
if (-not $SlackChannel -and $env:SLACK_CHANNEL) { $SlackChannel = $env:SLACK_CHANNEL }
if (-not $TrelloKey -and $env:TRELLO_KEY)      { $TrelloKey     = $env:TRELLO_KEY }
if (-not $TrelloToken -and $env:TRELLO_TOKEN)  { $TrelloToken   = $env:TRELLO_TOKEN }
if (-not $TrelloBoardId -and $env:TRELLO_BOARD_ID) { $TrelloBoardId = $env:TRELLO_BOARD_ID }
if (-not $Owner -and $env:OWNER) { $Owner = $env:OWNER }
if (-not $Owner -and $env:GITHUB_OWNER) { $Owner = $env:GITHUB_OWNER }
if (-not $Repo -and $env:REPO) { $Repo = $env:REPO }
if (-not $Repo -and $env:GITHUB_REPO) { $Repo = $env:GITHUB_REPO }

# Debug: report whether key env vars were loaded (non-sensitive logging)
if ($env:SLACK_TOKEN) { Write-Host "DEBUG: SLACK_TOKEN present" -ForegroundColor DarkGray } else { Write-Host "DEBUG: SLACK_TOKEN missing" -ForegroundColor DarkGray }
if ($env:TRELLO_KEY) { Write-Host "DEBUG: TRELLO_KEY present" -ForegroundColor DarkGray } else { Write-Host "DEBUG: TRELLO_KEY missing" -ForegroundColor DarkGray }
if ($env:TRELLO_BOARD_ID) { Write-Host "DEBUG: TRELLO_BOARD_ID present" -ForegroundColor DarkGray } else { Write-Host "DEBUG: TRELLO_BOARD_ID missing" -ForegroundColor DarkGray }

# Also try loading .env from script dir or current working directory explicitly
$extra = @( (Join-Path $PSScriptRoot ".env"), (Join-Path ((Get-Location).Path) ".env") )
Write-Host "DEBUG: extraPaths = $($extra -join ', ')" -ForegroundColor DarkGray
foreach ($p in $extra) { if (Test-Path $p) { Write-Host "DEBUG: loading $p" -ForegroundColor DarkGray ; Load-DotEnv $p } }

# Repopulate parameters in case extra .env provided values
if (-not $SlackToken -and $env:SLACK_TOKEN)    { $SlackToken    = $env:SLACK_TOKEN }
if (-not $SlackChannel -and $env:SLACK_CHANNEL) { $SlackChannel = $env:SLACK_CHANNEL }
if (-not $TrelloKey -and $env:TRELLO_KEY)      { $TrelloKey     = $env:TRELLO_KEY }
if (-not $TrelloToken -and $env:TRELLO_TOKEN)  { $TrelloToken   = $env:TRELLO_TOKEN }
if (-not $TrelloBoardId -and $env:TRELLO_BOARD_ID) { $TrelloBoardId = $env:TRELLO_BOARD_ID }
if (-not $Owner -and $env:OWNER) { $Owner = $env:OWNER }
if (-not $Owner -and $env:GITHUB_OWNER) { $Owner = $env:GITHUB_OWNER }
if (-not $Repo -and $env:REPO) { $Repo = $env:REPO }
if (-not $Repo -and $env:GITHUB_REPO) { $Repo = $env:GITHUB_REPO }

## WITH_GHPR detection will run after .env is loaded (see later)

## Map GH_TOKEN -> GITHUB_TOKEN so `gh` CLI can pick it up
if ($env:GH_TOKEN -and -not $env:GITHUB_TOKEN) { $env:GITHUB_TOKEN = $env:GH_TOKEN }

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
 

# Ensure gh (GitHub CLI) sees a token if provided in .env as GITHUB_TOKEN or GH_TOKEN
if ($env:GH_TOKEN -and -not $env:GITHUB_TOKEN) { $env:GITHUB_TOKEN = $env:GH_TOKEN }
if ($env:GITHUB_TOKEN) { Write-Host "Using GITHUB_TOKEN from environment" -ForegroundColor DarkGray }

## Determine WITH_GHPR from environment flags (now that .env has been loaded)
if ($env:WITH_GHPR -or $env:WITH_GH_PR -or $env:ENABLE_GH_PR) {
    $v = $env:WITH_GHPR; if (-not $v) { $v = $env:WITH_GH_PR }; if (-not $v) { $v = $env:ENABLE_GH_PR }
    if ($v) {
        $sv = ($v -as [string]).ToLower()
        if ($sv -in @('1','true','yes')) { $WithGhPR = $true }
    }
}

# Fallback: if a GitHub token + Owner + Repo exist, enable GH PRs automatically
if (-not $WithGhPR -and $env:GITHUB_TOKEN -and $Owner -and $Repo) {
    $WithGhPR = $true
    Write-Host "Enabling GitHub PR collection (GITHUB_TOKEN + OWNER + REPO detected)" -ForegroundColor DarkGray
}

# ── helpers ──────────────────────────────────────────────────────────────────
function Log($msg)    { Write-Host "`n[$(Get-Date -f 'HH:mm:ss')] $msg" -ForegroundColor Cyan }
function Ok($msg)     { Write-Host "  OK   $msg" -ForegroundColor Green }
function Warn($msg)   { Write-Host "  WARN $msg" -ForegroundColor Yellow }
function Step($n,$t)  { Write-Host "  [$n] $t" -ForegroundColor White }

function SaveJson($obj, $file) {
    try {
        if ($null -eq $obj) {
            "null" | Set-Content "$OutDir\$file" -Encoding UTF8
        } else {
            $obj | ConvertTo-Json -Depth 20 | Set-Content "$OutDir\$file" -Encoding UTF8
        }
    } catch {
        "" | Set-Content "$OutDir\$file" -Encoding UTF8
    }
    if (Test-Path "$OutDir\$file") { $kb = [math]::Round((Get-Item "$OutDir\$file").Length / 1KB, 1) ; Ok "$file  ($kb KB)" } else { Ok "$file  (0 KB)" }
}
function SaveCsv($rows, $file) {
    try {
        if ($null -eq $rows) { "" | Set-Content "$OutDir\$file" -Encoding UTF8 } else { $rows | Export-Csv "$OutDir\$file" -NoTypeInformation -Encoding UTF8 }
    } catch { "" | Set-Content "$OutDir\$file" -Encoding UTF8 }
    if (Test-Path "$OutDir\$file") { $kb = [math]::Round((Get-Item "$OutDir\$file").Length / 1KB, 1) ; Ok "$file  ($kb KB)" } else { Ok "$file  (0 KB)" }
}
function SaveRaw($lines, $file) {
    try { $lines | Set-Content "$OutDir\$file" -Encoding UTF8 } catch { "" | Set-Content "$OutDir\$file" -Encoding UTF8 }
    if (Test-Path "$OutDir\$file") { $kb = [math]::Round((Get-Item "$OutDir\$file").Length / 1KB, 1) ; Ok "$file  ($kb KB)" } else { Ok "$file  (0 KB)" }
}

function SlackGet($endpoint, $params = @{}) {
    $resp = Invoke-RestMethod `
        -Uri     "https://slack.com/api/$endpoint" `
        -Headers @{ Authorization = "Bearer $SlackToken" } `
        -Body    $params `
        -Method  Get
    if (-not $resp.ok) { Warn "Slack /$endpoint  error=$($resp.error)"; return $null }
    return $resp
}

function TrelloGet($path, $extra = @{}) {
    $qs  = (@{ key = $TrelloKey; token = $TrelloToken } + $extra).GetEnumerator() |
           ForEach-Object { "$($_.Key)=$([uri]::EscapeDataString($_.Value))" }
    try   { return Invoke-RestMethod -Uri "https://api.trello.com/1/$path`?$($qs -join '&')" }
    catch { Warn "Trello /$path  $_"; return $null }
}

# ── init ─────────────────────────────────────────────────────────────────────
if (-not [System.IO.Path]::IsPathRooted($OutDir)) {
    $OutDir = Join-Path (Get-Location) $OutDir
}
if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir -Force | Out-Null }

if ($WithGhPR) {
    if (-not $Owner -or -not $Repo) {
        Write-Host "ERROR: -WithGhPR requires -Owner and -Repo" -ForegroundColor Red; exit 1
    }
    if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
        Write-Host "ERROR: gh CLI not found. Install from https://cli.github.com" -ForegroundColor Red; exit 1
    }
}

Write-Host ""
Write-Host "  fetch_all.ps1" -ForegroundColor Yellow
Write-Host "  Output : $OutDir"
Write-Host "  Slack  : channel $SlackChannel"
Write-Host "  Trello : board   $TrelloBoardId"
if ($WithGhPR) { Write-Host "  GitHub : $Owner/$Repo  (via gh CLI)" }
Write-Host ""

# ════════════════════════════════════════════════════════════════════════════
#  SECTION 1 — GIT  (native git commands, must run inside repo dir)
# ════════════════════════════════════════════════════════════════════════════
Log "SECTION 1/4 — GIT"

if (-not (Test-Path ".git")) {
    Warn "Not a git repo — skipping git section. cd into the repo first."
} else {
    git fetch --all --tags --quiet
    Ok "fetch done"

    # 1a. Commit list
    Step "1a" "Commits list (all branches)..."
    git log --all `
        --pretty=format:"%H,%an,%ae,%ad,%s" `
        --date=short | Set-Content "$OutDir\git_commits_list.csv" -Encoding UTF8
    Ok "git_commits_list.csv"

    # 1b. Commits + file paths  (key for module mapping)
    Step "1b" "Commits with files changed..."
    git log --all `
        --pretty=format:"COMMIT|%H|%an|%ae|%ad|%s" `
        --date=short `
        --name-status | Set-Content "$OutDir\git_commits_files.txt" -Encoding UTF8

    $rows = [System.Collections.Generic.List[string]]::new()
    $rows.Add("sha,author,email,date,message,status,file")
    $sha = $author = $email = $date = $msg = ""
    foreach ($line in (Get-Content "$OutDir\git_commits_files.txt")) {
        if ($line -match "^COMMIT\|(.+?)\|(.+?)\|(.+?)\|(.+?)\|(.*)$") {
            $sha=$Matches[1]; $author=$Matches[2]; $email=$Matches[3]
            $date=$Matches[4]; $msg=($Matches[5] -replace ',', ' ')
        } elseif ($line -match "^([AMDRTCU])\d*\s+(\S+)(?:\s+(\S+))?$") {
            $status = $Matches[1]
            if ($Matches[3] -and $Matches[3].Length -gt 0) { $file = $Matches[3] } else { $file = $Matches[2] }
            $file = $file -replace ',', ' '
            $rows.Add("$sha,`"$author`",$email,$date,`"$msg`",$status,$file")
        }
    }
    SaveRaw $rows "git_commits_files.csv"

    # 1c. Diff stats (insertions/deletions per file — MD proxy)
    Step "1c" "Diff stats per commit..."
    git log --all `
        --pretty=format:"COMMIT|%H|%an|%ad" `
        --date=short `
        --numstat | Set-Content "$OutDir\git_diff_stats.txt" -Encoding UTF8

    $drows = [System.Collections.Generic.List[string]]::new()
    $drows.Add("sha,author,date,ins,del,file")
    $sha = $author = $date = ""
    foreach ($line in (Get-Content "$OutDir\git_diff_stats.txt")) {
        if ($line -match "^COMMIT\|(.+?)\|(.+?)\|(.+)$") {
            $sha=$Matches[1]; $author=$Matches[2]; $date=$Matches[3]
        } elseif ($line -match "^(\d+|-)\s+(\d+|-)\s+(.+)$") {
            $drows.Add("$sha,`"$author`",$date,$($Matches[1]),$($Matches[2]),$($Matches[3] -replace ',',' ')")
        }
    }
    SaveRaw $drows "git_diff_stats.csv"

    # 1d. Merges
    Step "1d" "Merge commits..."
    git log --all --merges `
        --pretty=format:"%H,%an,%ae,%ad,%s,%P" `
        --date=short | Set-Content "$OutDir\git_merges.csv" -Encoding UTF8
    Ok "git_merges.csv"

    # 1e. Branches
    Step "1e" "Branches..."
    git branch -a --format="%(refname:short)|%(objectname:short)|%(authorname)|%(authordate:short)|%(subject)" |
        Set-Content "$OutDir\git_branches.txt" -Encoding UTF8

    $brows = [System.Collections.Generic.List[string]]::new()
    $brows.Add("branch,tip_sha,commits_total,commits_ahead_main")
    foreach ($b in (git branch -a --format="%(refname:short)")) {
        $b = $b.Trim()
        if ($b -match "HEAD") { continue }
        $total = (git rev-list --count $b 2>$null)
        $ahead = (git rev-list --count "$b" --not main 2>$null)
        $tip   = (git rev-parse --short $b 2>$null)
        $brows.Add("$b,$tip,$total,$ahead")
    }
    SaveRaw $brows "git_branches.csv"

    # 1f. Author summary
    Step "1f" "Shortlog..."
    git shortlog --all -sne | Set-Content "$OutDir\git_shortlog.txt" -Encoding UTF8
    git log --all --pretty=format:"%ad|%ae|%an" --date=format:"%Y-%m-%d" |
        Set-Content "$OutDir\git_author_daily.csv" -Encoding UTF8
    Ok "git_shortlog.txt + git_author_daily.csv"
}

# ════════════════════════════════════════════════════════════════════════════
#  SECTION 2 — SLACK
# ════════════════════════════════════════════════════════════════════════════
Log "SECTION 2/4 — SLACK"

# 2a. Channel info
Step "2a" "Channel info..."
$ch = SlackGet "conversations.info" @{ channel=$SlackChannel; include_num_members="true" }
if ($ch) { SaveJson $ch.channel "slack_channel.json" }

# 2b. User list
Step "2b" "Users (paginated)..."
$allUsers = [System.Collections.Generic.List[object]]::new()
$cur = ""
do {
    $p = @{ limit=200 }; if ($cur) { $p.cursor=$cur }
    $r = SlackGet "users.list" $p
    if (-not $r) { break }
    $allUsers.AddRange($r.members)
    $cur = $null
    if ($r -and $r.PSObject.Properties['response_metadata']) {
        try { $cur = $r.response_metadata.next_cursor } catch { $cur = $null }
    }
    if ($cur) { Start-Sleep -Milliseconds 500 }
} while ($cur)
SaveJson $allUsers "slack_users.json"
SaveCsv ($allUsers | ForEach-Object {
    $real_name = ""; $display_name = ""; $email = ""
    try {
        if ($_.profile) {
            $real_name = $_.profile.real_name -as [string]
            $display_name = $_.profile.display_name -as [string]
            $email = $_.profile.email -as [string]
        }
    } catch { $real_name = $real_name; $display_name = $display_name; $email = $email }
    [PSCustomObject]@{
        id=$_.id; name=$_.name; real_name=$real_name; display_name=$display_name; email=$email; is_bot=$_.is_bot; deleted=$_.deleted
    }
}) "slack_users.csv"

# 2c. Channel history — ALL messages (paginated)
Step "2c" "Channel history (paginated)..."
$allMsgs = [System.Collections.Generic.List[object]]::new()
$cur = ""
$page = 0
do {
    $page++
    $p = @{ channel=$SlackChannel; limit=200 }; if ($cur) { $p.cursor=$cur }
    $r = SlackGet "conversations.history" $p
    if (-not $r) { break }
    $allMsgs.AddRange($r.messages)
    $cur = $null
    if ($r -and $r.PSObject.Properties['response_metadata']) {
        try { $cur = $r.response_metadata.next_cursor } catch { $cur = $null }
    }
    Write-Host "     page $page — $($allMsgs.Count) messages" -ForegroundColor DarkGray
    if ($cur) { Start-Sleep -Milliseconds 600 }
} while ($cur)
SaveJson $allMsgs "slack_messages.json"
$slackRows = [System.Collections.Generic.List[object]]::new()
foreach ($m in $allMsgs) {
    $dt = if ($m.ts) { [DateTimeOffset]::FromUnixTimeSeconds([long]($m.ts.Split('.')[0])).ToString("yyyy-MM-dd HH:mm:ss") } else {""}
    $attachments = ""; $reactions = ""; $text = ""
    try { if ($m.PSObject -and $m.PSObject.Properties['attachments']) { $attachments = ($m.attachments | ForEach-Object { $_.fallback }) -join " || " } } catch { $attachments = "" }
    try { if ($m.PSObject -and $m.PSObject.Properties['reactions']) { $reactions = ($m.reactions | ForEach-Object { ($_.name + ':' + $_.count) }) -join "|" } } catch { $reactions = "" }
    try { if ($m.PSObject -and $m.PSObject.Properties['text']) { $text = ($m.text -replace "`n"," ") } } catch { $text = "" }
    $user = ""; $bot_id = ""; $subtype = ""; $thread_ts = ""; $reply_count = 0
    try {
        if ($m.PSObject -and $m.PSObject.Properties['user']) { $user = $m.user }
        if ($m.PSObject -and $m.PSObject.Properties['bot_id']) { $bot_id = $m.bot_id }
        if ($m.PSObject -and $m.PSObject.Properties['subtype']) { $subtype = $m.subtype }
        if ($m.PSObject -and $m.PSObject.Properties['thread_ts']) { $thread_ts = $m.thread_ts }
        if ($m.PSObject -and $m.PSObject.Properties['reply_count']) { $reply_count = $m.reply_count }
    } catch {}
    $has_files = $false
    try { if ($m.PSObject -and $m.PSObject.Properties['files']) { $has_files = [bool]$m.files } } catch {}
    $row = [PSCustomObject]@{
        ts=$m.ts; datetime=$dt; user=$user; bot_id=$bot_id; subtype=$subtype
        thread_ts=$thread_ts; reply_count=$reply_count
        text=$text
        attachments=$attachments
        has_files=$has_files
        reactions=$reactions
    }
    $slackRows.Add($row)
}
SaveCsv $slackRows "slack_messages.csv"

# 2d. Thread replies
Step "2d" "Thread replies..."
$threadMsgs = $allMsgs | Where-Object { if ($_.PSObject -and $_.PSObject.Properties['reply_count']) { $_.reply_count -gt 0 } else { $false } }
$allReplies = [System.Collections.Generic.List[object]]::new()
$ti = 0
foreach ($tm in $threadMsgs) {
    $ti++
    Write-Progress -Activity "Thread replies" -Status "$ti/$($threadMsgs.Count)" `
        -PercentComplete ([int]($ti*100/[Math]::Max($threadMsgs.Count,1)))
    $cur = ""
    do {
        $p = @{ channel=$SlackChannel; ts=$tm.ts; limit=200 }; if ($cur) { $p.cursor=$cur }
        $r = SlackGet "conversations.replies" $p
        if (-not $r) { break }
        $r.messages | Select-Object -Skip 1 | ForEach-Object {
            $_ | Add-Member -NotePropertyName "parent_ts" -NotePropertyValue $tm.ts -Force
            $allReplies.Add($_)
        }
        $cur = $null
        if ($r -and $r.PSObject.Properties['response_metadata']) {
            try { $cur = $r.response_metadata.next_cursor } catch { $cur = $null }
        }
        if ($cur) { Start-Sleep -Milliseconds 400 }
    } while ($cur)
    Start-Sleep -Milliseconds 300
}
Write-Progress -Activity "Thread replies" -Completed
SaveJson $allReplies "slack_replies.json"
$replyRows = [System.Collections.Generic.List[object]]::new()
foreach ($rm in $allReplies) {
    $dt = if ($rm.ts) { [DateTimeOffset]::FromUnixTimeSeconds([long]($rm.ts.Split('.')[0])).ToString("yyyy-MM-dd HH:mm:ss") } else {""}
    $parent_ts = ""; $user = ""; $bot_id = ""; $text = ""
    try { if ($rm.PSObject -and $rm.PSObject.Properties['parent_ts']) { $parent_ts = $rm.parent_ts } } catch {}
    try { if ($rm.PSObject -and $rm.PSObject.Properties['user']) { $user = $rm.user } } catch {}
    try { if ($rm.PSObject -and $rm.PSObject.Properties['bot_id']) { $bot_id = $rm.bot_id } } catch {}
    try { if ($rm.PSObject -and $rm.PSObject.Properties['text']) { $text = ($rm.text -replace "`n"," ") } } catch {}
    $row = [PSCustomObject]@{ parent_ts=$parent_ts; ts=$rm.ts; datetime=$dt; user=$user; bot_id=$bot_id; text=$text }
    $replyRows.Add($row)
}
SaveCsv $replyRows "slack_replies.csv"

# 2e. Bot profiles
Step "2e" "Bot profiles..."
$botIds = (($allMsgs + $allReplies) | ForEach-Object { if ($_.PSObject -and $_.PSObject.Properties['bot_id']) { $_.bot_id } }) | Where-Object { $_ } | Sort-Object -Unique
$bots = [System.Collections.Generic.List[object]]::new()
foreach ($bid in $botIds) {
    $r = SlackGet "bots.info" @{ bot=$bid }
    if ($r -and $r.bot) { $bots.Add($r.bot) }
    Start-Sleep -Milliseconds 300
}
if ($bots.Count) { SaveJson $bots "slack_bots.json" }

# 2f. File attachments metadata
Step "2f" "File metadata..."
 $fileRows = [System.Collections.Generic.List[object]]::new()
foreach ($m in ($allMsgs + $allReplies)) {
    try {
        if ($m.PSObject -and $m.PSObject.Properties['files']) {
            foreach ($f in $m.files) {
                $fileRows.Add([PSCustomObject]@{
                    msg_ts=$m.ts; file_id=$f.id; name=$f.name
                    mimetype=$f.mimetype; size_bytes=$f.size; created=$f.created; url=$f.url_private
                })
            }
        }
    } catch {}
}
if ($fileRows.Count) { SaveCsv $fileRows "slack_files.csv" }

# ════════════════════════════════════════════════════════════════════════════
#  SECTION 3 — TRELLO
# ════════════════════════════════════════════════════════════════════════════
Log "SECTION 3/4 — TRELLO"

# 3a. Board info
Step "3a" "Board info..."
$board = TrelloGet "boards/$TrelloBoardId" @{
    fields="name,desc,closed,dateLastActivity,url,shortUrl,labelNames,prefs"
}
if ($board) { SaveJson $board "trello_board.json" }

# 3b. Lists
Step "3b" "Lists..."
$lists = TrelloGet "boards/$TrelloBoardId/lists" @{ fields="all"; filter="all" }
$listMap = @{}
if ($lists) {
    SaveJson $lists "trello_lists.json"
    $lists | ForEach-Object { $listMap[$_.id] = $_.name }
    SaveCsv ($lists | ForEach-Object {[PSCustomObject]@{
        id=$_.id; name=$_.name; closed=$_.closed; pos=$_.pos
    }}) "trello_lists.csv"
}

# 3c. Members
Step "3c" "Members..."
$members = TrelloGet "boards/$TrelloBoardId/members" @{ fields="all" }
if ($members) {
    SaveJson $members "trello_members.json"
    SaveCsv ($members | ForEach-Object {[PSCustomObject]@{
        id=$_.id; username=$_.username; fullName=$_.fullName; memberType=$_.memberType
    }}) "trello_members.csv"
}

# 3d. Cards — all fields
Step "3d" "Cards..."
$cards = TrelloGet "boards/$TrelloBoardId/cards" @{
    fields="all"; filter="all"
    actions="commentCard,updateCard,createCard,copyCard,moveCardToBoard"
    attachments="true"; checklists="all"; members="true"; pluginData="false"
}
if ($cards) {
    SaveJson $cards "trello_cards_full.json"
    SaveCsv ($cards | ForEach-Object {[PSCustomObject]@{
        id=$_.id; shortLink=$_.shortLink; name=$_.name
        idList=$_.idList; listName=$listMap[$_.idList]
        closed=$_.closed; dueComplete=$_.dueComplete
        due=$_.due; start=$_.start; dateLastActivity=$_.dateLastActivity
        desc=($_.desc -replace "`n"," ")
        idMembers=($_.idMembers -join "|")
        labels=(($_.labels | ForEach-Object {$_.name}) -join "|")
        checkItems=$_.badges.checkItems; checkItemsDone=$_.badges.checkItemsChecked
        comments=$_.badges.comments; attachments=$_.badges.attachments
        url=$_.shortUrl
    }}) "trello_cards.csv"
}

# 3e. Board actions (audit log, paginated)
Step "3e" "Actions audit log..."
$allActions = [System.Collections.Generic.List[object]]::new()
$before = ""
do {
    $p = @{ filter="all"; limit=1000; fields="all" }
    if ($before) { $p.before = $before }
    $batch = TrelloGet "boards/$TrelloBoardId/actions" $p
    if (-not $batch -or $batch.Count -eq 0) { break }
    $allActions.AddRange($batch)
    $before = $batch[-1].id
    Write-Host "     $($allActions.Count) actions..." -ForegroundColor DarkGray
    if ($batch.Count -lt 1000) { break }
    Start-Sleep -Milliseconds 500
} while ($true)
if ($allActions -and $allActions.Count -gt 0) {
    SaveJson $allActions "trello_actions.json"
    $actionRows = [System.Collections.Generic.List[object]]::new()
    foreach ($act in $allActions) {
        $memberName = ""; $memberUser = ""; $card_id = ""; $card_name = ""; $list_from = ""; $list_to = ""; $text = ""
        try { if ($act.memberCreator) { $memberName = $act.memberCreator.fullName; $memberUser = $act.memberCreator.username } } catch {}
        try { if ($act.data -and $act.data.card) { $card_id = $act.data.card.id; $card_name = $act.data.card.name } } catch {}
        try { if ($act.data -and $act.data.listBefore) { $list_from = $act.data.listBefore.name } } catch {}
        try { if ($act.data -and $act.data.listAfter) { $list_to = $act.data.listAfter.name } } catch {}
        try { if ($act.data -and $act.data.text) { $text = ($act.data.text -replace "`n"," ") } } catch {}
        $actionRows.Add([PSCustomObject]@{
            id=$act.id; type=$act.type; date=$act.date
            memberName=$memberName; memberUser=$memberUser; card_id=$card_id; card_name=$card_name
            list_from=$list_from; list_to=$list_to; text=$text
        })
    }
    SaveCsv $actionRows "trello_actions.csv"
} else { Warn "no trello actions (skipping)" }

# 3f. Checklists
Step "3f" "Checklists..."
$cls = TrelloGet "boards/$TrelloBoardId/checklists" @{ fields="all"; checkItem_fields="all" }
if ($cls -and $cls.Count) {
    SaveJson $cls "trello_checklists.json"
    $clrows = foreach ($cl in $cls) {
        foreach ($item in $cl.checkItems) {[PSCustomObject]@{
            checklist_id=$cl.id; checklist_name=$cl.name; card_id=$cl.idCard
            item_id=$item.id; item_name=$item.name; state=$item.state; pos=$item.pos
        }}
    }
    if ($clrows) { SaveCsv $clrows "trello_checklist_items.csv" }
}

# 3g. Labels
Step "3g" "Labels..."
$labels = TrelloGet "boards/$TrelloBoardId/labels" @{ fields="all" }
if ($labels) {
    SaveJson $labels "trello_labels.json"
    SaveCsv ($labels | ForEach-Object {[PSCustomObject]@{
        id=$_.id; name=$_.name; color=$_.color
    }}) "trello_labels.csv"
}

# ════════════════════════════════════════════════════════════════════════════
#  SECTION 4 — GITHUB PRs via gh CLI  (optional)
# ════════════════════════════════════════════════════════════════════════════
if ($WithGhPR) {
    Log "SECTION 4/4 — GITHUB PRs (gh CLI)"
    $base = "repos/$Owner/$Repo"

    # 4a. PR list — full metadata
    Step "4a" "PR list..."
    $prFields = "number,title,author,state,createdAt,mergedAt,closedAt," +
                "baseRefName,headRefName,body,labels,assignees,reviewDecision,reviews,comments"
    $prsRaw = gh pr list --state all --limit 500 --repo "$Owner/$Repo" --json $prFields 2>&1
    if ($LASTEXITCODE -eq 0) {
        $prsRaw | Set-Content "$OutDir\gh_prs.json" -Encoding UTF8
        Ok "gh_prs.json"
        $prs = $prsRaw | ConvertFrom-Json
    } else { Warn "gh pr list failed"; $prs = @() }

    # 4b. PR files per PR
    Step "4b" "PR files changed..."
    $prFileRows = [System.Collections.Generic.List[object]]::new()
    $pi = 0
    foreach ($pr in $prs) {
        $pi++
        Write-Progress -Activity "PR files" -Status "PR#$($pr.number)  ($pi/$($prs.Count))" `
            -PercentComplete ([int]($pi*100/[Math]::Max($prs.Count,1)))
        $raw = gh api "$base/pulls/$($pr.number)/files" --paginate 2>&1
        if ($LASTEXITCODE -ne 0) { continue }
        try {
            ($raw | ConvertFrom-Json) | ForEach-Object {
                $prFileRows.Add([PSCustomObject]@{
                    pr=$pr.number; filename=$_.filename
                    status=$_.status; additions=$_.additions; deletions=$_.deletions
                })
            }
        } catch {}
        if ($pi % 20 -eq 0) { Start-Sleep -Milliseconds 500 }
    }
    Write-Progress -Activity "PR files" -Completed
    SaveCsv $prFileRows "gh_pr_files.csv"

    # 4c. PR commits per PR
    Step "4c" "PR commits..."
    $prCommitRows = [System.Collections.Generic.List[object]]::new()
    $pi = 0
    foreach ($pr in $prs) {
        $pi++
        Write-Progress -Activity "PR commits" -Status "PR#$($pr.number)  ($pi/$($prs.Count))" `
            -PercentComplete ([int]($pi*100/[Math]::Max($prs.Count,1)))
        $raw = gh api "$base/pulls/$($pr.number)/commits" --paginate 2>&1
        if ($LASTEXITCODE -ne 0) { continue }
        try {
            ($raw | ConvertFrom-Json) | ForEach-Object {
                $prCommitRows.Add([PSCustomObject]@{
                    pr=$pr.number; sha=$_.sha
                    author=$_.commit.author.name; email=$_.commit.author.email
                    date=$_.commit.author.date
                    message=($_.commit.message -replace "`n"," ")
                })
            }
        } catch {}
        if ($pi % 20 -eq 0) { Start-Sleep -Milliseconds 500 }
    }
    Write-Progress -Activity "PR commits" -Completed
    SaveCsv $prCommitRows "gh_pr_commits.csv"

    # 4d. Contributor stats
    Step "4d" "Contributor stats..."
    $statsRaw = gh api "$base/stats/contributors" 2>&1
    if ($LASTEXITCODE -eq 0) {
        $statsRaw | Set-Content "$OutDir\gh_contributor_stats.json" -Encoding UTF8
        Ok "gh_contributor_stats.json"
    }

    # 4e. Issues
    Step "4e" "Issues..."
    $issFields = "number,title,author,assignees,labels,state,createdAt,closedAt,body,comments"
    $issRaw = gh issue list --state all --limit 500 --repo "$Owner/$Repo" --json $issFields 2>&1
    if ($LASTEXITCODE -eq 0) { $issRaw | Set-Content "$OutDir\gh_issues.json" -Encoding UTF8; Ok "gh_issues.json" }

} else {
    Write-Host "`n  [4/4] GitHub PRs skipped (use -WithGhPR -Owner xxx -Repo yyy to enable)" `
        -ForegroundColor DarkGray
}

# ════════════════════════════════════════════════════════════════════════════
#  SUMMARY
# ════════════════════════════════════════════════════════════════════════════
Write-Host ""
Log "DONE — $OutDir"
Write-Host ""
$files = Get-ChildItem $OutDir | Sort-Object Name
$totalKb = ($files | Measure-Object Length -Sum).Sum / 1KB
foreach ($f in $files) {
    $kb = [math]::Round($f.Length/1KB, 1)
    $prefix = switch -Wildcard ($f.Name) {
        "git_*"     { "GIT    " }
        "slack_*"   { "SLACK  " }
        "trello_*"  { "TRELLO " }
        "gh_*"      { "GH     " }
        default     { "       " }
    }
    Write-Host ("  $prefix {0,-42} {1,7} KB" -f $f.Name, $kb)
}
Write-Host ("  {0,-50} {1,7} KB  total" -f "", [math]::Round($totalKb,1)) -ForegroundColor Yellow

Write-Host ""
Write-Host "Key files cho analysis:" -ForegroundColor Cyan
Write-Host "  git_commits_files.csv    GC by file path  → module mapping"
Write-Host "  git_diff_stats.csv       insertions/deletions  → MD proxy"
Write-Host "  git_merges.csv           merge commits  → MC base"
Write-Host "  slack_users.csv          UID → real name"
Write-Host "  slack_messages.csv       SM  (all messages + bot attachments)"
Write-Host "  slack_replies.csv        SM  reply chains  (đủ thread count)"
Write-Host "  trello_cards.csv         TT  + listName column"
Write-Host "  trello_actions.csv       audit log: ai làm gì, lúc nào  → MD timeline"
if ($WithGhPR) {
    Write-Host "  gh_pr_files.csv          PR → module directory  (MC / GC cross-check)"
    Write-Host "  gh_pr_commits.csv        tất cả commits trong PR  (kiennt branch work)"
}
