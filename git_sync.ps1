Set-Location $PSScriptRoot

$branch = "main"

Write-Host "正在同步远程仓库..."

git pull --rebase origin $branch

Write-Host "正在检查 ip.txt..."

git add ip.txt

git diff --cached --quiet

if ($LASTEXITCODE -ne 0) {

    $commit_msg = "Update ip.txt on $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"

    git commit -m $commit_msg

    git push origin $branch

    Write-Host "✅ ip.txt 已推送到 GitHub"

} else {

    Write-Host "ℹ️ ip.txt 没有变化，无需推送"

}