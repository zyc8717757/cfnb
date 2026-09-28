Set-Location $PSScriptRoot

$branch = "main"

Write-Host "正在检查 ip.txt..."

if (-not (Test-Path "ip.txt")) {
    Write-Host "❌ 找不到 ip.txt"
    exit 1
}

git add ip.txt

git diff --cached --quiet

if ($LASTEXITCODE -ne 0) {

    $commit_msg = "Update ip.txt on $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"

    git commit -m $commit_msg

    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Git commit 失败"
        exit 1
    }

    git push origin $branch

    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ ip.txt 已推送到 GitHub"
    } else {
        Write-Host "❌ GitHub 推送失败"
        exit 1
    }

} else {

    Write-Host "ℹ️ ip.txt 没有变化，无需推送"

}