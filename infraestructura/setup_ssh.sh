#!/bin/bash
# setup_ssh.sh
# Despliegue de llaves y endurecimiento de SSH dinámico y Agnóstico a la nube

# Cargamos las variables globales
source "$(dirname "$0")/nodos.conf"

KEY_PATH="$HOME/.ssh/id_ed25519"

echo "Iniciando configuración dinámica de SSH..."

# Generación de la llave SSH si no existe
if [[ ! -f "$KEY_PATH" ]]; then
    echo "Generando nueva llave SSH Ed25519..."
    ssh-keygen -t ed25519 -f "$KEY_PATH" -C "admin_redes@plataforma" -N "" -q
else
    echo "La llave SSH ya existe. Omitiendo generación."
fi

# 1. Diccionario asociativo IP -> Rol cargado desde nodos.conf
declare -A NODE_ROLES=(
    [$IP_PROXY]="proxy"
    [$IP_BACKEND]="backend"
    [$IP_DATABASE]="database"
)

# Iteración genérica sobre los nodos
for IP in "${!NODE_ROLES[@]}"; do
    ROLE="${NODE_ROLES[$IP]}"
    echo "========================================="
    echo "Configurando acceso para el nodo: $ROLE ($IP)"
    
    # 1. Distribuir la llave pública
    ssh-copy-id -i "${KEY_PATH}.pub" "$SSH_USER@$IP"
    
    # 2. Comando remoto para endurecimiento base. 
    # Usamos sed remotamente para cambiar PasswordAuthentication y PermitRootLogin.
    # Esto endurece el sistema sin interferir con mecanismos cloud como GCP OS Login.
    HARDENING_CMD="sed -i -E 's/^#?PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config && "
    HARDENING_CMD+="sed -i -E 's/^#?PermitRootLogin (yes|prohibit-password)/PermitRootLogin no/' /etc/ssh/sshd_config && "
    HARDENING_CMD+="systemctl restart ssh"

    echo "Aplicando endurecimiento de SSH (Hardening) de forma remota..."
    ssh -n "$SSH_USER@$IP" "sudo bash -c \"$HARDENING_CMD\""
    
    echo "Nodo $ROLE configurado y seguro."
done

echo "Proceso de bastionado SSH completado."
