# Example 프로젝트 빌드
Write-Output "Building example project..."
Set-Location -Path (Join-Path (Split-Path -Path $MyInvocation.MyCommand.Definition -Parent) "example") # example 디렉토리로 이동
flutter clean
flutter pub get
flutter build apk
if ($LASTEXITCODE -ne 0) { Write-Output 'Example project build failed'; exit $LASTEXITCODE }

Write-Output "Example project build completed successfully."