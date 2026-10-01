#!/bin/bash
# Inicia o ambiente local da TOOLA. Dois cliques neste arquivo bastam.
# Nao altera nada do site: so liga os servidores.
#
#   9292  o tema como esta (shopify theme dev)
#   8777  o mesmo tema com o video no hero (proxy local, nada vai a Shopify)
#   8888  o index.html original, de referencia
#   8899  o painel com os links

cd "$(dirname "$0")" || exit 1
RAIZ="$(pwd)"
PAINEL="http://127.0.0.1:8899/painel.html"

printf '\033]0;TOOLA - ambiente local\007'
echo "================================================"
echo "  TOOLA - ambiente local"
echo "================================================"
echo

FILHOS=()
limpar() {
  echo
  echo "Encerrando..."
  for p in "${FILHOS[@]}"; do kill "$p" >/dev/null 2>&1; done
  for porta in 9292 8777 8888 8899; do
    lsof -ti tcp:$porta 2>/dev/null | xargs kill -9 >/dev/null 2>&1
  done
  echo "Tudo encerrado. Pode fechar esta janela."
  echo
  read -r -p "Enter para fechar..."
  exit 0
}
trap limpar INT TERM

# ---- dependencias -------------------------------------------
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" >/dev/null 2>&1
export PATH="$HOME/.local/bin:$PATH"

if ! command -v node >/dev/null 2>&1; then
  echo "ERRO: Node nao encontrado. Instale com:  nvm install --lts"
  read -r -p "Enter para fechar..."; exit 1
fi
echo "Node .............. $(node -v)"

if ! command -v shopify >/dev/null 2>&1; then
  echo "Shopify CLI nao encontrado. Instalando (uma vez so)..."
  npm install -g @shopify/cli@latest || {
    echo "Falhou. Rode: npm install -g @shopify/cli@latest"
    read -r -p "Enter para fechar..."; exit 1; }
fi
echo "Shopify CLI ....... $(shopify version 2>/dev/null)"

if [ ! -f "theme/shopify.theme.toml" ]; then
  echo "ERRO: theme/shopify.theme.toml nao encontrado."
  read -r -p "Enter para fechar..."; exit 1
fi
echo "Tema alvo ......... Dawn - Toola desenvolvimento"
echo

# ---- libera portas ocupadas ---------------------------------
for porta in 9292 8777 8888 8899; do
  if lsof -ti tcp:$porta >/dev/null 2>&1; then
    lsof -ti tcp:$porta | xargs kill -9 >/dev/null 2>&1
  fi
done
sleep 1

# ---- servidores de apoio ------------------------------------
( cd "$RAIZ" && python3 -m http.server 8888 >/dev/null 2>&1 ) &
FILHOS+=($!)

( cd "$RAIZ/local" && python3 -m http.server 8899 >/dev/null 2>&1 ) &
FILHOS+=($!)

if [ -f "$RAIZ/local/video-teste.mp4" ]; then
  ( python3 "$RAIZ/local/proxy-video.py" >/dev/null 2>&1 ) &
  FILHOS+=($!)
  COM_VIDEO="sim"
else
  COM_VIDEO="sem arquivo de video em local/"
fi

echo "  Tema .............. http://127.0.0.1:9292"
echo "  Com video ......... http://127.0.0.1:8777   ($COM_VIDEO)"
echo "  Original .......... http://127.0.0.1:8888/index.html"
echo "  PAINEL ............ $PAINEL"
echo
echo "O Chrome abre o painel sozinho quando o tema ficar pronto."
echo "No painel voce troca entre as versoes sem usar o terminal."
echo
echo "  Para desligar ..... Control + C nesta janela"
echo
echo "------------------------------------------------"
echo

# ---- abre o painel quando o tema responder ------------------
(
  for _ in $(seq 1 90); do
    sleep 2
    if curl -s -o /dev/null -m 3 "http://127.0.0.1:9292" 2>/dev/null; then
      open -a "Google Chrome" "$PAINEL" 2>/dev/null || open "$PAINEL"
      exit 0
    fi
  done
) &
FILHOS+=($!)

cd "$RAIZ/theme" || exit 1
shopify theme dev -e dev --port 9292

limpar
