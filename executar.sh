#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

if [[ $# -lt 1 ]]; then
  echo "Uso: ./executar.sh <TICKER> [PERIODO] [INTERVALO]" >&2
  echo "Exemplo: ./executar.sh PETR4.SA 1y 1d" >&2
  echo "Teste offline: ./executar.sh --demo" >&2
  exit 2
fi

mkdir -p output data

# Usa o ambiente virtual local, se existir; caso contrario, usa o Python do sistema.
if [[ -x "$ROOT/.venv/bin/python" ]]; then
  PYTHON="$ROOT/.venv/bin/python"
else
  PYTHON="${PYTHON:-python3}"
fi

if [[ "$1" == "--demo" ]]; then
  CSV="$ROOT/data/exemplo.csv"
  TICKER="EXEMPLO"
else
  TICKER="$1"
  PERIODO="${2:-1y}"
  INTERVALO="${3:-1d}"

  if ! "$PYTHON" -c 'import yfinance' >/dev/null 2>&1; then
    echo "Dependencia yfinance nao encontrada." >&2
    echo "Crie/ative um ambiente virtual e execute: pip install -r requirements.txt" >&2
    exit 1
  fi

  "$PYTHON" coletor.py "$TICKER" --period "$PERIODO" --interval "$INTERVALO" --output data/historico.csv
  CSV="$ROOT/data/historico.csv"
fi

echo "Compilando Assembly..."
gcc -x assembler -Wall -Wextra -O0 -g -no-pie -o stockscope main.asm

echo "Processando CSV em Assembly..."
./stockscope "$CSV" "$TICKER"

echo
echo "Arquivos gerados:"
echo "  output/grafico.svg"
echo "  output/dashboard.html"
echo
echo "Para abrir o painel: xdg-open output/dashboard.html"
