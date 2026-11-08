$ErrorActionPreference = 'Stop'

$RepoUrl = 'https://github.com/atef2026tefa-creator/ATEF-TEFA.git'
$BaseBranch = 'fix/general-security-hardening'
$WorkDir = Join-Path $env:USERPROFILE 'ATEF-TEFA-reference-merge'
$ZipPath = Join-Path $PSScriptRoot 'cost-app-pro-fixed.zip'
$ExtractDir = Join-Path $WorkDir 'reference-extracted'
$RepoDir = Join-Path $WorkDir 'repo'
$NewBranch = 'integrate/reference-zip'

if (-not (Test-Path $ZipPath)) {
    throw "لم أجد الملف بجانب السكربت: $ZipPath"
}
if (Test-Path $WorkDir) {
    throw "المجلد موجود بالفعل: $WorkDir . غيّر اسمه أو احذفه بعد التأكد من عدم وجود عمل مهم بداخله."
}

New-Item -ItemType Directory -Path $WorkDir | Out-Null

git clone $RepoUrl $RepoDir
Set-Location $RepoDir
git fetch origin $BaseBranch
git checkout -b $NewBranch "origin/$BaseBranch"

New-Item -ItemType Directory -Path $ExtractDir | Out-Null
Expand-Archive -LiteralPath $ZipPath -DestinationPath $ExtractDir
$SourceRoot = Join-Path $ExtractDir 'cost-app-fixed'
if (-not (Test-Path $SourceRoot)) { throw 'بنية ZIP غير متوقعة: لم أجد مجلد cost-app-fixed.' }

# Preserve the reviewed backend security fixes from the security-hardening branch.
$Preserve = @(
  'backend/src/routes/auth.js',
  'backend/src/server.js',
  'backend/src/services/authService.js'
)

Get-ChildItem -LiteralPath $SourceRoot -Force | ForEach-Object {
    Copy-Item -LiteralPath $_.FullName -Destination $RepoDir -Recurse -Force
}
foreach ($RelativePath in $Preserve) {
    $Destination = Join-Path $RepoDir ($RelativePath -replace '/', '\\')
    if (Test-Path $Destination) {
        git checkout -- $RelativePath
    }
}

git status --short
Write-Host ''
Write-Host 'راجع الملفات أعلاه. سيتم إنشاء commit ورفع فرع مستقل، ولن يتم تعديل main.' -ForegroundColor Yellow
$Answer = Read-Host 'اكتب YES لإكمال commit ورفع الفرع إلى GitHub'
if ($Answer -ne 'YES') { Write-Host 'تم إيقاف العملية قبل commit/push. الملفات موجودة محليًا للمراجعة.'; exit 0 }

git add -A
git commit -m 'Integrate fixed reference application into ATEF-TEFA'
git push -u origin $NewBranch
Write-Host "تم رفع الفرع: $NewBranch" -ForegroundColor Green
Write-Host "افتح: https://github.com/atef2026tefa-creator/ATEF-TEFA/compare/main...$NewBranch?expand=1"
