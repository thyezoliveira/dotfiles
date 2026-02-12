## Instalação rápida
```bash
curl -fsSL https://raw.githubusercontent.com/seu-usuario/dotfiles/main/install.sh | bash
```

ou com wget:
```bash
wget -qO- https://raw.githubusercontent.com/seu-usuario/dotfiles/main/install.sh | bash
```
```

## Estrutura recomendada do repositório
```
seu-repo/
├── README.md
├── install.sh          # script de instalação
├── playbook.yml        # playbook ansible
├── vimrc              # seu .vimrc
