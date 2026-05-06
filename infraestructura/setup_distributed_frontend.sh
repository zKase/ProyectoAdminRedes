#!/bin/bash
# setup_distributed_frontend.sh
# Provisión de la VM de Frontend (IP Pública)

source "$(dirname "$0")/gcp_distributed.conf"

echo "Configurando VM de Frontend en IP Pública: $FRONTEND_IP..."

# Configuración de Nginx con el proxy al backend interno
NGINX_CONF="
server {
    listen 80;
    server_name _;

    location / {
        root /var/www/frontend;
        index index.html;
        try_files \$uri \$uri/ /index.html;
    }

    location /api {
        proxy_pass http://$BACKEND_INTERNAL_IP:3000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
"

CMD_FRONTEND="
sudo apt update &&
sudo apt install -y nginx git curl &&
echo '$NGINX_CONF' | sudo tee /etc/nginx/sites-available/default &&
sudo systemctl restart nginx &&
sudo mkdir -p /var/www/frontend &&
sudo chown -R \$USER:\$USER /var/www/frontend
"

ssh -n "$SSH_USER@$FRONTEND_IP" "$CMD_FRONTEND"

echo "Frontend configurado con éxito. Proxy apuntando a $BACKEND_INTERNAL_IP:3000"
