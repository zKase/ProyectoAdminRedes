# ============================================================
# backup-db.ps1 -- Script de backup para PostgreSQL
# Uso: .\scripts\backup-db.ps1
# ============================================================

# Cargar variables desde .env
$envFile = Join-Path $PSScriptRoot "..\.env"
if (Test-Path $envFile) {
    Get-Content $envFile | ForEach-Object {
        if ($_ -match '^\s*([^#][^=]+)=(.*)$') {
            $name  = $matches[1].Trim()
            $value = $matches[2].Trim()
            [System.Environment]::SetEnvironmentVariable($name, $value, "Process")
        }
    }
} else {
    Write-Error "No se encontro el archivo .env en $envFile"
    exit 1
}

# Configuracion con fallbacks compatibles con PS 5+
if ($env:DB_HOST)     { $DB_HOST     = $env:DB_HOST }     else { $DB_HOST     = "localhost" }
if ($env:DB_PORT)     { $DB_PORT     = $env:DB_PORT }     else { $DB_PORT     = "5432" }
if ($env:DB_USERNAME) { $DB_USERNAME = $env:DB_USERNAME } else { $DB_USERNAME = "postgres" }
if ($env:DB_PASSWORD) { $DB_PASSWORD = $env:DB_PASSWORD } else { $DB_PASSWORD = "" }
if ($env:DB_NAME)     { $DB_NAME     = $env:DB_NAME }     else { $DB_NAME     = "proyecto_db" }

# Directorio y nombre del archivo de backup
$backupDir = Join-Path $PSScriptRoot "..\backups"
if (-not (Test-Path $backupDir)) {
    New-Item -ItemType Directory -Path $backupDir | Out-Null
    Write-Host "Carpeta de backups creada: $backupDir"
}

$timestamp  = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$backupFile = Join-Path $backupDir "${DB_NAME}_${timestamp}.sql"

# Ejecutar pg_dump
Write-Host "Iniciando backup de '$DB_NAME' en ${DB_HOST}:${DB_PORT} ..."

# Buscar pg_dump automaticamente si no esta en el PATH
$pgDump = "pg_dump"
if (-not (Get-Command pg_dump -ErrorAction SilentlyContinue)) {
    $pgDir = Get-ChildItem "C:\Program Files\PostgreSQL" -ErrorAction SilentlyContinue |
             Sort-Object Name -Descending | Select-Object -First 1
    if ($pgDir) {
        $pgDump = Join-Path $pgDir.FullName "bin\pg_dump.exe"
        Write-Host "pg_dump encontrado en: $pgDump"
    } else {
        Write-Error "No se encontro pg_dump. Asegurate de que PostgreSQL este instalado."
        exit 1
    }
}

$env:PGPASSWORD = $DB_PASSWORD

& $pgDump `
    --host=$DB_HOST `
    --port=$DB_PORT `
    --username=$DB_USERNAME `
    --format=plain `
    --no-owner `
    --no-acl `
    --file=$backupFile `
    $DB_NAME

if ($LASTEXITCODE -eq 0) {
    $sizeKB = [math]::Round((Get-Item $backupFile).Length / 1KB, 2)
    Write-Host "Backup exitoso: $backupFile ($sizeKB KB)"
} else {
    Write-Error "El backup fallo (codigo de salida: $LASTEXITCODE)"
    exit $LASTEXITCODE
}

# Limpiar password del entorno
Remove-Item Env:PGPASSWORD -ErrorAction SilentlyContinue
