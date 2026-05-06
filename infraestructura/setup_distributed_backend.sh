#!/bin/bash
# setup_distributed_backend.sh
# Provisión de la VM de Backend (Solo IP Interna)

source "$(dirname "$0")/gcp_distributed.conf"

echo "Configurando VM de Backend en IP Interna: $BACKEND_INTERNAL_IP..."

# Comandos a ejecutar en el backend
# Nota: Se asume que el backend tiene salida a internet vía Cloud NAT para instalar paquetes.
CMD_BACKEND="
sudo apt update && 
sudo apt install -y postgresql postgresql-contrib curl build-essential git &&
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo bash - &&
sudo apt install -y nodejs &&
sudo systemctl start postgresql &&
sudo -u postgres psql -c \"ALTER USER postgres PASSWORD 'contrasegura';\" &&
sudo -u postgres psql -c \"CREATE DATABASE proyecto_db;\" &&
sudo npm install -g pm2
"

# Ejecución vía SSH (Requiere IAP si no hay IP pública, o estar en la misma red)
# Si se ejecuta desde el frontend:
ssh -n "$SSH_USER@$BACKEND_INTERNAL_IP" "$CMD_BACKEND"

echo "Backend configurado con éxito."
