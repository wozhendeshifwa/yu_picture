<#
.SYNOPSIS
  一键起本地开发环境：后端 5000 + 前端 3000，各开一个 PowerShell 窗口。

.DESCRIPTION
  前端默认走 Vite 代理（/api -> http://127.0.0.1:5000），所以只访问 3000 就够。
  后端连库走 SSH 隧道（127.0.0.1:13306），隧道由 deploy/tools/tunnel-rds.ps1 手动起；
  本脚本只检测、不替你偷偷起 ssh——隧道断没断要一眼看得见。
  凭据从 backend/.env.local 读取（该文件不进仓库）。

.EXAMPLE
  .\start-dev.ps1
#>
[CmdletBinding()]
param()

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$backend = Join-Path $root 'backend'
$frontend = Join-Path $root 'frontend'

if (-not (Test-Path (Join-Path $backend 'mvnw.cmd'))) {
    throw "找不到 backend/mvnw.cmd，仓库结构不对？"
}

if (-not (Test-Path (Join-Path $frontend 'node_modules'))) {
    throw "前端依赖还没装。先执行：pnpm --dir frontend install"
}

$envFile = Join-Path $backend '.env.local'
if (Test-Path $envFile) {
    Get-Content $envFile | ForEach-Object {
        $line = $_.Trim()
        if (-not $line -or $line.StartsWith('#')) { return }
        $eq = $line.IndexOf('=')
        if ($eq -lt 1) { return }
        $key = $line.Substring(0, $eq).Trim()
        $value = $line.Substring($eq + 1).Trim()
        Set-Item -Path "env:$key" -Value $value
    }
    Write-Host '已加载 backend/.env.local' -ForegroundColor DarkGray
} else {
    Write-Host '未找到 backend/.env.local：后端会照常启动，但 /api/health/db 会报 down。' -ForegroundColor Yellow
    Write-Host '  需要连库时：copy backend\.env.local.example backend\.env.local 并填密码。' -ForegroundColor DarkGray
}

$tunnelOpen = Test-NetConnection -ComputerName 127.0.0.1 -Port 13306 -InformationLevel Quiet -WarningAction SilentlyContinue
if (-not $tunnelOpen) {
    Write-Host '数据库隧道未开（127.0.0.1:13306）。后端照常启动，/api/health/db 会报 down。' -ForegroundColor Yellow
    Write-Host '  要连库先起隧道：.\deploy\tools\tunnel-rds.ps1 -RdsHost rm-bp11x8oy4ozq8mjf9jo.mysql.rds.aliyuncs.com' -ForegroundColor DarkGray
}

Write-Host '启动后端（5000）...' -ForegroundColor Cyan
Start-Process -FilePath 'powershell' -ArgumentList @(
    '-NoExit', '-NoLogo', '-Command', "Set-Location '$backend'; .\mvnw.cmd spring-boot:run"
)

Start-Sleep -Seconds 3

Write-Host '启动前端（3000）...' -ForegroundColor Cyan
Start-Process -FilePath 'powershell' -ArgumentList @(
    '-NoExit', '-NoLogo', '-Command', "Set-Location '$frontend'; pnpm dev"
)

Write-Host ''
Write-Host '前端      http://127.0.0.1:3000' -ForegroundColor Green
Write-Host '后端存活  http://127.0.0.1:5000/api/health' -ForegroundColor Green
Write-Host '数据库通道 http://127.0.0.1:5000/api/health/db' -ForegroundColor Green
Write-Host ''
Write-Host '验证整条链路：' -ForegroundColor Yellow
Write-Host '  curl http://127.0.0.1:3000/api/health'
Write-Host '  curl http://127.0.0.1:5000/api/health/db'
