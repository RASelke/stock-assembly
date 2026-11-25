# StockScope — Python + Assembly x86-64

Projeto acadêmico para analisar o histórico de preços de uma ação.

A divisão é simples:

- **Python (`coletor.py`)**: busca cotações históricas e grava `data/historico.csv`. Não calcula indicadores nem gera gráficos.
- **Assembly (`main.asm`)**: lê o CSV, calcula os indicadores e gera `output/grafico.svg` e `output/dashboard.html`.
- **Shell (`executar.sh`)**: executa a coleta, compila o Assembly e roda o programa com um único comando.

O fonte `main.asm` utiliza GNU Assembler (GAS) com `.intel_syntax noprefix` — ou seja, sintaxe Intel em Linux x86-64. A extensão `.asm` foi escolhida para ficar familiar ao padrão usado na faculdade; o `gcc -x assembler` informa explicitamente ao compilador que esse arquivo é Assembly GAS.

## 1. Requisitos no Ubuntu

```bash
sudo apt update
sudo apt install build-essential gcc python3 python3-venv
```

Crie o ambiente e instale a única dependência Python:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

## 2. Executar tudo com um comando

Exemplo com Petrobras:

```bash
./executar.sh PETR4.SA
```

Outros exemplos:

```bash
./executar.sh VALE3.SA
./executar.sh AAPL
./executar.sh PETR4.SA 6mo 1d
```

Argumentos opcionais: período (padrão `1y`) e intervalo (padrão `1d`).

## 3. Testar sem internet

O CSV de demonstração contém valores sintéticos, não cotações reais:

```bash
./executar.sh --demo
```

## 4. Resultado

Após a execução, o Assembly cria:

- `output/grafico.svg` — gráfico histórico de preços.
- `output/dashboard.html` — página HTML com gráfico e indicadores.

Abra o dashboard:

```bash
xdg-open output/dashboard.html
```

## 5. Indicadores calculados em Assembly

- último preço de fechamento;
- preço médio, máximo e mínimo;
- retorno total do período;
- médias móveis de 7 e 21 pregões;
- retorno diário médio;
- melhor e pior variação diária;
- volatilidade diária (desvio-padrão amostral dos retornos);
- volume médio.

Os preços são processados como inteiros em centavos. Os retornos são representados em centésimos de porcentagem (basis points), evitando operações de ponto flutuante nos cálculos centrais.

## Observações

- O programa aceita até 2.000 registros.
- O CSV esperado possui as colunas `date,open,high,low,close,volume`.
- O histórico é obtido por `yfinance`, biblioteca comunitária que acessa dados disponibilizados pelo Yahoo Finance. A disponibilidade pode mudar e os dados podem ter atraso.
- O projeto é educativo e não constitui recomendação de investimento.
