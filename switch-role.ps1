param(
  [Parameter(Position = 0)]
  [ValidateSet('ops', 'script', 'ai', 'all', 'none', 'status')]
  [string]$Role = 'status'
)

# 角色切换脚本 —— 通过重命名 prompt.d 下的文件来启用/停用角色
# 用法: .\switch-role.ps1 ops|script|ai|all|none|status

$dir = Join-Path $env:USERPROFILE ".pi\agent\prompt.d"

if (-not (Test-Path $dir)) {
  Write-Host "错误: 找不到目录 $dir" -ForegroundColor Red
  exit 1
}

$roles = [ordered]@{
  'ops'    = 'role.ops-triage.md'
  'script' = 'role.scripting.md'
  'ai'     = 'role.ai-toolchain.md'
}

function Show-Status {
  Write-Host "`n当前角色状态 ($dir):" -ForegroundColor Cyan
  foreach ($k in $roles.Keys) {
    $f = $roles[$k]
    $on  = Test-Path (Join-Path $dir $f)
    $off = Test-Path (Join-Path $dir "$f.off")
    if ($on) {
      Write-Host ("  [{0}] {1,-10} 启用" -f '●', $k) -ForegroundColor Green
    } elseif ($off) {
      Write-Host ("  [{0}] {1,-10} 停用" -f '○', $k) -ForegroundColor DarkGray
    } else {
      Write-Host ("  [{0}] {1,-10} 缺失" -f '!', $k) -ForegroundColor Yellow
    }
  }
  Write-Host ""
}

if ($Role -eq 'status') {
  Show-Status
  exit 0
}

# 先全部停用
foreach ($f in $roles.Values) {
  $p = Join-Path $dir $f
  if (Test-Path $p) {
    Rename-Item -LiteralPath $p -NewName "$f.off" -Force
  }
}

# 再启用目标
switch ($Role) {
  'all'  { $targets = $roles.Values }
  'none' { $targets = @() }
  default { $targets = @($roles[$Role]) }
}

foreach ($f in $targets) {
  $p = Join-Path $dir "$f.off"
  if (Test-Path $p) {
    Rename-Item -LiteralPath $p -NewName $f -Force
  }
}

Write-Host "已切换角色: $Role" -ForegroundColor Green
Show-Status
Write-Host "请重启 PI-Desktop 或新开会话使配置生效。" -ForegroundColor Yellow
