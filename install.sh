#!/bin/bash
set -e

echo "🚀 Instalando configurações do Vim..."

# Instalar Ansible se necessário
if ! command -v ansible &> /dev/null; then
    echo "📦 Instalando Ansible..."
    if [ -f /etc/debian_version ]; then
        sudo apt update && sudo apt install -y ansible git
    elif [ -f /etc/redhat-release ]; then
        sudo dnf install -y ansible git
    else
        echo "❌ Sistema não suportado. Instale o Ansible manualmente."
        exit 1
    fi
fi

# Clonar repositório temporário
TEMP_DIR=$(mktemp -d)
git clone https://github.com/thyezoliveira/dotfiles.git "$TEMP_DIR"

# Executar playbook
cd "$TEMP_DIR"
ansible-playbook playbook.yml

# Limpar
rm -rf "$TEMP_DIR"
echo "Diretorio temporário $TEMP_DIR removido!"

echo "✅ Configuração concluída!"
