#!/usr/bin/env python3
"""Coleta historico OHLCV com yfinance e salva somente um arquivo CSV."""

import argparse
import csv
import math
import re
import sys
from pathlib import Path

import yfinance as yf

TICKER_RE = re.compile(r"^[A-Za-z0-9.^=_-]{1,24}$")


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Busca cotacoes historicas e grava um CSV para o StockScope."
    )
    parser.add_argument("ticker", help="Ex.: PETR4.SA, VALE3.SA ou AAPL")
    parser.add_argument("--period", default="1y", help="Periodo (padrao: 1y)")
    parser.add_argument("--interval", default="1d", help="Intervalo (padrao: 1d)")
    parser.add_argument("--output", default="data/historico.csv")
    args = parser.parse_args()

    ticker = args.ticker.strip().upper()
    if not TICKER_RE.fullmatch(ticker):
        print("Ticker invalido.", file=sys.stderr)
        return 2

    print(f"Buscando {ticker}: periodo={args.period}, intervalo={args.interval}...")
    try:
        # repair=False evita dependencias opcionais desnecessarias (ex.: sklearn).
        history = yf.Ticker(ticker).history(
            period=args.period,
            interval=args.interval,
            auto_adjust=True,
            actions=False,
            repair=False,
            timeout=25,
        )
    except Exception as exc:
        print(f"Falha ao obter cotacoes: {exc}", file=sys.stderr)
        return 1

    if history is None or history.empty:
        print("Nenhuma cotacao retornada. Confira o ticker e tente novamente.", file=sys.stderr)
        return 1

    output = Path(args.output)
    output.parent.mkdir(parents=True, exist_ok=True)
    count = 0

    try:
        with output.open("w", newline="", encoding="utf-8") as csv_file:
            writer = csv.writer(csv_file, lineterminator="\n")
            writer.writerow(("date", "open", "high", "low", "close", "volume"))

            for timestamp, row in history.iterrows():
                prices = [row.get("Open"), row.get("High"), row.get("Low"), row.get("Close")]
                if any(value is None or not math.isfinite(float(value)) for value in prices):
                    continue

                raw_volume = row.get("Volume", 0)
                volume = 0 if raw_volume is None or not math.isfinite(float(raw_volume)) else int(raw_volume)
                writer.writerow([
                    timestamp.strftime("%Y-%m-%d"),
                    *(f"{float(value):.2f}" for value in prices),
                    volume,
                ])
                count += 1
    except OSError as exc:
        print(f"Nao foi possivel gravar {output}: {exc}", file=sys.stderr)
        return 1

    if count == 0:
        print("Nenhuma linha valida foi encontrada.", file=sys.stderr)
        return 1

    print(f"CSV criado: {output} ({count} registros).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
