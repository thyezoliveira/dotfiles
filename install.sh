#!/bin/bash
#--- Configuração de Robustez ---
# -e: Encerra se um comando falhar
# -u: Erro se uma variável não definida for usada
# -o pipefail: Garante que erros em pipes sejam capturados
set -euo pipefail

# Detecção de Sistema Operacional
OS="$(uname)"
case "${OS}" in
    Linux*)     MACHINE=Linux;;
    Darwin*)    MACHINE=Mac;;
    *)          echo "Sistema não suportado: ${OS}"; exit 1;;
esac

echo "--- [SRE] Iniciando Provisionamento de Ambiente de Elite ($MACHINE) ---"

# 1. Dependências de Sistema e Zsh
echo ">> Instalando pacotes base e Zsh..."
if [ "$MACHINE" == "Linux" ]; then
    sudo apt update
    sudo apt install -y vim git curl fontconfig python3 python3-pip nodejs npm zsh unzip
elif [ "$MACHINE" == "Mac" ]; then
    # Verifica se Homebrew está instalado
    if ! command -v brew &> /dev/null; then
        echo ">> Homebrew não encontrado. Instalando..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        # Adiciona Homebrew ao PATH temporariamente se for a primeira instalação
        eval "$(/opt/homebrew/bin/brew shellenv)" || eval "$(/usr/local/bin/brew shellenv)"
    fi
    brew update || true
    brew install vim git curl python3 node zsh unzip
fi

# 2. Instalação do 'uv' (Python Manager de alta performance)
echo ">> Instalando uv..."
curl -LsSf https://astral.sh/uv/install.sh | sh
export PATH="$HOME/.cargo/bin:$PATH"

# 3. Oh My Zsh (Instalação Não-Interativa)
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo ">> Instalando Oh My Zsh..."
    # KEEP_ZSHRC=yes evita que ele sobrescreva seu config atual prematuramente
    # CHSH=no impede que ele interrompa o script pedindo senha
    RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# 4. Vim-Plug (Plugin Manager)
echo ">> Configurando Vim-Plug..."
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# 5. Ubuntu Mono Nerd Font
echo ">> Instalando Nerd Fonts..."
if [ "$MACHINE" == "Linux" ]; then
    FONT_DIR="$HOME/.local/share/fonts"
    mkdir -p "$FONT_DIR"
    cd "$FONT_DIR"
    if [ ! -f "UbuntuMono.zip" ]; then
        curl -fLO https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/UbuntuMono.zip
        unzip -o UbuntuMono.zip
        fc-cache -fv
    fi
    cd -
elif [ "$MACHINE" == "Mac" ]; then
    FONT_DIR="$HOME/Library/Fonts"
    mkdir -p "$FONT_DIR"
    cd "$FONT_DIR"
    if [ ! -f "UbuntuMono.zip" ]; then
        curl -fLO https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/UbuntuMono.zip
        unzip -o UbuntuMono.zip
    fi
    cd -
fi

# 6. Configuração do .vimrc
cat <<EOF > ~/.vimrc
set number
set relativenumber
set encoding=UTF-8
set mouse=a
set tabstop=4
set shiftwidth=4
set expandtab

call plug#begin('~/.vim/plugged')
    Plug 'vim-airline/vim-airline'
    Plug 'vim-airline/vim-airline-themes'
    Plug 'preservim/nerdtree'
    Plug 'neoclide/coc.nvim', {'branch': 'release'}
    Plug 'sheerun/vim-polyglot'
call plug#end()

let g:airline_theme='agnoster'
let g:airline_powerline_fonts = 1
nnoremap <C-n> :NERDTreeToggle<CR>
EOF

# 7. Automação de Plugins Vim & LSPs
echo ">> Instalando plugins do Vim e LSPs..."
vim +PlugInstall +qall

# Instalação de extensões CoC para Python, JS e React
mkdir -p ~/.config/coc/extensions
cd ~/.config/coc/extensions
if [ ! -f package.json ]; then echo '{"dependencies":{}}' > package.json; fi
npm install coc-pyright coc-tsserver coc-json coc-html coc-css --global-style --ignore-scripts --no-bin-links --no-package-lock
cd -

# 8. Troca de Shell para Zsh
echo ">> Definindo Zsh como shell padrão..."
ZSH_PATH="$(which zsh)"
if [ "$SHELL" != "$ZSH_PATH" ]; then
    echo ">> Mudando shell para $ZSH_PATH..."
    if [ "$MACHINE" == "Linux" ]; then
        sudo chsh -s "$ZSH_PATH" "$USER"
    elif [ "$MACHINE" == "Mac" ]; then
        if ! grep -q "$ZSH_PATH" /etc/shells; then
            echo "$ZSH_PATH" | sudo tee -a /etc/shells
        fi
        sudo chsh -s "$ZSH_PATH" "$USER"
    fi
fi

echo "--- [CONCLUÍDO] ---"
echo "Ação Necessária: Reinicie o terminal ou execute 'zsh' para entrar no novo ambiente."
