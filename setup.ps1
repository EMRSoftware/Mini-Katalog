# Mini Katalog - Proje Kurulum Rehberi

# Bu script, Flutter projesini çalışır hale getirir.
# PowerShell'de çalıştırın: .\setup.ps1

Write-Host "=== Mini Katalog Proje Kurulumu ===" -ForegroundColor Cyan
Write-Host ""

# 1. Flutter kontrolü
Write-Host "[1/4] Flutter SDK kontrol ediliyor..." -ForegroundColor Yellow
try {
    $flutterVersion = flutter --version 2>&1
    Write-Host "Flutter bulundu!" -ForegroundColor Green
} catch {
    Write-Host "HATA: Flutter SDK bulunamadi!" -ForegroundColor Red
    Write-Host "Flutter'i https://flutter.dev/docs/get-started/install adresinden indirin." -ForegroundColor Yellow
    Write-Host "Kurulumdan sonra bu scripti tekrar calistirin." -ForegroundColor Yellow
    exit 1
}

# 2. Gecici proje olustur ve platform dosyalarini al
Write-Host ""
Write-Host "[2/4] Platform dosyalari olusturuluyor..." -ForegroundColor Yellow

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectDir = $scriptDir
$tempDir = Join-Path $env:TEMP "mini_katalog_temp"

# Gecici Flutter projesi olustur
if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force }
flutter create --project-name mini_katalog $tempDir 2>&1 | Out-Null

# Platform dosyalarini kopyala
$platformDirs = @("android", "ios", "web", "windows", "linux", "macos", "test")
foreach ($dir in $platformDirs) {
    $sourcePath = Join-Path $tempDir $dir
    $destPath = Join-Path $projectDir $dir
    if ((Test-Path $sourcePath) -and !(Test-Path $destPath)) {
        Copy-Item $sourcePath $destPath -Recurse
        Write-Host "  + $dir klasoru kopyalandi" -ForegroundColor DarkGray
    }
}

# .metadata ve diger dosyalari kopyala
$otherFiles = @(".metadata", ".gitignore", "mini_katalog.iml")
foreach ($file in $otherFiles) {
    $sourcePath = Join-Path $tempDir $file
    $destPath = Join-Path $projectDir $file
    if ((Test-Path $sourcePath) -and !(Test-Path $destPath)) {
        Copy-Item $sourcePath $destPath
    }
}

# Gecici klasoru temizle
Remove-Item $tempDir -Recurse -Force

# 3. Android internet izni ekle
Write-Host ""
Write-Host "[3/4] Android internet izni ekleniyor..." -ForegroundColor Yellow
$manifestPath = Join-Path $projectDir "android\app\src\main\AndroidManifest.xml"
if (Test-Path $manifestPath) {
    $manifestContent = Get-Content $manifestPath -Raw
    if ($manifestContent -notmatch "android.permission.INTERNET") {
        $manifestContent = $manifestContent -replace '(<manifest[^>]*>)', ('$1' + "`n    <uses-permission android:name=""android.permission.INTERNET""/>")
        Set-Content $manifestPath $manifestContent
        Write-Host "  Internet izni eklendi" -ForegroundColor DarkGray
    }
}

# 4. Bagimliliklari yukle
Write-Host ""
Write-Host "[4/4] Bagimliliklar yukleniyor..." -ForegroundColor Yellow
Set-Location $projectDir
flutter pub get

Write-Host ""
Write-Host "=== Kurulum Tamamlandi! ===" -ForegroundColor Green
Write-Host ""
Write-Host "Uygulamayi calistirmak icin:" -ForegroundColor Cyan
Write-Host "  cd $projectDir" -ForegroundColor White
Write-Host "  flutter run" -ForegroundColor White
Write-Host ""
