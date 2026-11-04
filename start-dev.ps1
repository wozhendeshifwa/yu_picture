<#
.SYNOPSIS
  一键起本地开发环境：后端 5000 + 前端 3000，各开一个 PowerShell 窗口。

.DESCRIPTION
  前端默认走 Vite 代理（/api -> http://127.0.0.1:5000），所以只访问 3000 就够。
  关掉窗口即停进程。

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
Write-Host '前端  http://127.0.0.1:3000' -ForegroundColor Green
Write-Host '后端  http://127.0.0.1:5000/api/health' -ForegroundColor Green
Write-Host ''
Write-Host '验证整条链路：' -ForegroundColor Yellow
Write-Host '  curl http://127.0.0.1:3000/api/health'
