@echo off
cd /d "%~dp0"

if not exist "ip.txt" (
    echo ERROR: ip.txt not found.
    exit /b 1
)

echo Checking ip.txt...

git add -- ip.txt
git diff --cached --quiet -- ip.txt

if errorlevel 2 (
    echo ERROR: git diff failed.
    exit /b 1
)

if errorlevel 1 goto changed

echo ip.txt has no changes. Nothing to push.
exit /b 0

:changed
echo New ip.txt detected. Creating commit...

git commit -m "Update ip.txt" -- ip.txt

if errorlevel 1 (
    echo ERROR: git commit failed.
    exit /b 1
)

:push
set RETRY=0

:retry_push
set /a RETRY+=1

echo Pushing to GitHub... attempt %RETRY% of 3

git push origin main

if not errorlevel 1 (
    echo SUCCESS: ip.txt pushed to GitHub.
    exit /b 0
)

if %RETRY% GEQ 3 (
    echo ERROR: GitHub push failed after 3 attempts.
    exit /b 1
)

echo Push failed. Waiting 10 seconds before retry...
timeout /t 10 /nobreak >nul
goto retry_push