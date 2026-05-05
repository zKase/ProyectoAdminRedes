#!/bin/bash
# infraestructura/setup_local.sh
# Provisión de Monolito ejecutada LOCALMENTE dentro de la VM.

# 1. Diccionario de servicios (Nombre -> Paquete APT)
declare -A SERVICES=(
    ["proxy"]="nginx"
    ["backend"]="nodejs"
    ["database"]="postgresql"
)

# 2. Diccionario de configuraciones (Lógica genérica)
declare -A CONFIGS=(
    ["proxy"]="echo 'server { listen 80; location / { proxy_pass http://127.0.0.1:3000; proxy_set_header Host \$host; } }' > /etc/nginx/sites-available/default && systemctl restart nginx"
    ["backend"]="curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && apt install -y nodejs build-essential git"
    ["database"]="apt install -y postgresql postgresql-contrib && systemctl start postgresql"
)

echo "🚀 Iniciando provisión LOCAL (Todo-en-uno) en esta VM..."

sudo apt update

# Instalación dinámica de servicios
for KEY in "${!SERVICES[@]}"; do
    PKG="${SERVICES[$KEY]}"
    echo "Instalando y configurando $KEY ($PKG)..."
    # Ejecutamos el comando directamente con sudo
    CMD="apt install -y $PKG && ${CONFIGS[$KEY]}"
    sudo bash -c "$CMD"
done

# 3. Configuración de Firewall Local (UFW) con auto-detección
echo "🔒 Configurando Firewall local..."
ACTIVE_IF=$(ip route | awk '/default/ {print $5}' | head -n1)

sudo ufw --force reset
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow in on $ACTIVE_IF to any port 22 proto tcp
sudo ufw allow in on $ACTIVE_IF to any port 80 proto tcp
sudo ufw allow in on $ACTIVE_IF to any port 443 proto tcp
sudo ufw --force enable

echo "✅ Provisión local completada con éxito. Servicios Nginx, Node.js y Postgres listos."
