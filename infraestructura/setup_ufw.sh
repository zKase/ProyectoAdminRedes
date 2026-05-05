#!/bin/bash
# setup_ufw.sh
# Firewall dinámico para entorno consolidado (Monolito)

source "$(dirname "$0")/nodos.conf"

# Puertos que deben estar expuestos al mundo
declare -A PUBLIC_SERVICES=(
    ["ssh"]="22"
    ["http"]="80"
    ["https"]="443"
)

echo "Iniciando configuración de Firewall UFW para Monolito..."

# Script de ejecución remota
# Se auto-detecta la interfaz principal para ser agnóstico a la infraestructura (Local vs Cloud)
REMOTE_SCRIPT="
    ACTIVE_IF=\$(ip route | awk '/default/ {print \$5}' | head -n1)
    echo \"Interfaz activa detectada: \$ACTIVE_IF\"

    ufw --force reset
    ufw default deny incoming
    ufw default allow outgoing
"

# Inyectar reglas basadas en el diccionario de servicios públicos
for SVC in "${!PUBLIC_SERVICES[@]}"; do
    PORT="${PUBLIC_SERVICES[$SVC]}"
    REMOTE_SCRIPT+="ufw allow in on \$ACTIVE_IF to any port $PORT proto tcp; "
done

REMOTE_SCRIPT+="ufw --force enable"

# Ejecución del bloque de comandos en la VM única
ssh -n "$SSH_USER@$TARGET_IP" "sudo bash -c '$REMOTE_SCRIPT'"

echo "Firewall configurado en $TARGET_IP. Los puertos internos (3000, 5432) están protegidos."
