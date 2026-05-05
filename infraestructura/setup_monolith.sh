#!/bin/bash
# setup_monolith.sh
# Despliegue dinámico de todo el stack en una sola VM

source "$(dirname "$0")/nodos.conf"

# Diccionario de servicios (Nombre -> Paquete APT)
declare -A SERVICES=(
    ["proxy"]="nginx"
    ["backend"]="nodejs"
    ["database"]="postgresql"
)

# Diccionario de configuraciones (Lógica genérica sin switch/case)
declare -A CONFIGS=(
    ["proxy"]="echo 'server { listen 80; location / { proxy_pass http://127.0.0.1:3000; proxy_set_header Host \$host; } }' > /etc/nginx/sites-available/default && systemctl restart nginx"
    ["backend"]="curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && apt install -y nodejs build-essential git"
    ["database"]="apt install -y postgresql postgresql-contrib && systemctl start postgresql"
)

echo "Iniciando provisión de Monolito en $TARGET_IP..."

# Actualización inicial
ssh -n "$SSH_USER@$TARGET_IP" "sudo apt update"

# Iteración genérica sobre los servicios definidos
for KEY in "${!SERVICES[@]}"; do
    PKG="${SERVICES[$KEY]}"
    echo "Instalando y configurando $KEY ($PKG)..."
    
    # Construcción dinámica del comando: Instalación + Configuración
    CMD="apt install -y $PKG && ${CONFIGS[$KEY]}"
    
    ssh -n "$SSH_USER@$TARGET_IP" "sudo bash -c '$CMD'"
    echo "Servicio $KEY desplegado."
done

echo "Despliegue de servicios completado con éxito."
