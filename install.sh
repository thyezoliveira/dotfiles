#!/bin/bash
#--- Configuração de Robustez ---
# -e: Encerra se um comando falhar
# -u: Erro se uma variável não definida for usada
# -o pipefail: Garante que erros em pipes sejam capturados
set -euo pipefail

echo "--- [SRE] Iniciando Provisionamento de Ambiente de Elite ---"

# 1. Dependências de Sistema e Zsh
echo ">> Instalando pacotes base e Zsh..."
sudo apt update
sudo apt install -y vim git curl fontconfig python3 python3-pip nodejs npm zsh unzip

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
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"
cd "$FONT_DIR"
if [ ! -f "UbuntuMono.zip" ]; then
    curl -fLO https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/UbuntuMono.zip
    unzip -o UbuntuMono.zip
    fc-cache -fv
fi
cd -

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
sudo chsh -s "$(which zsh)" "$USER"

echo "--- [CONCLUÍDO] ---"
echo "Ação Necessária: Reinicie o terminal ou execute 'zsh' para entrar no novo ambiente."
