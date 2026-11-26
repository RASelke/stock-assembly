.intel_syntax noprefix

# StockScope - coleta CSV via Python; analise, SVG e HTML em Assembly
# GNU Assembler (GAS), x86-64 Linux, sintaxe Intel.
# O Assembly le o CSV, calcula os indicadores e gera SVG/HTML.

.section .rodata
mode_r:             .asciz "r"
mode_w:             .asciz "w"
usage_msg:          .asciz "Uso interno: ./stockscope <arquivo.csv> <TICKER>\nExemplo: ./stockscope data/historico.csv PETR4.SA"
open_error_msg:     .asciz "Erro: nao foi possivel abrir o CSV."
empty_error_msg:    .asciz "Erro: o CSV nao contem registros validos."
limit_error_msg:    .asciz "Erro: limite de 2000 registros excedido."
output_error_msg:   .asciz "Erro: nao foi possivel criar os arquivos em output/."
completed_msg:      .asciz "Concluido! Grafico e dashboard gerados em output/."

fmt_s:              .asciz "%s"
fmt_money:          .asciz "R$ %ld,%02ld"
fmt_percent:        .asciz "%s%ld.%02ld%%"
fmt_html_ticker:    .asciz "<h1>%s</h1>\n"
fmt_html_period:    .asciz "<p class=\"period\">%s ate %s</p>\n"
fmt_svg_point:      .asciz "%ld,%ld "
fmt_svg_max:        .asciz "<text x=\"62\" y=\"30\" class=\"axis\">Maximo: R$ %ld,%02ld</text>\n"
fmt_svg_min:        .asciz "<text x=\"62\" y=\"385\" class=\"axis\">Minimo: R$ %ld,%02ld</text>\n"
fmt_html_volume:    .asciz "<p class=\"value\">%ld</p><p class=\"label\">Volume medio</p></article>\n"

svg_path:           .asciz "output/grafico.svg"
html_path:          .asciz "output/dashboard.html"

percent_plus:       .asciz ""
percent_minus:      .asciz "-"

svg_header: .asciz "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"1100\" height=\"430\" viewBox=\"0 0 1100 430\">\n<defs><linearGradient id=\"area\" x1=\"0\" y1=\"0\" x2=\"0\" y2=\"1\"><stop offset=\"0%\" stop-color=\"#16a34a\" stop-opacity=\".28\"/><stop offset=\"100%\" stop-color=\"#16a34a\" stop-opacity=\"0\"/></linearGradient></defs>\n<rect width=\"1100\" height=\"430\" rx=\"18\" fill=\"#101827\"/>\n<style>.axis{fill:#91a0b5;font-family:Arial,sans-serif;font-size:14px}</style>\n<g stroke=\"#344256\" stroke-dasharray=\"5 7\" opacity=\".7\">\n<line x1=\"60\" y1=\"70\" x2=\"1040\" y2=\"70\"/><line x1=\"60\" y1=\"150\" x2=\"1040\" y2=\"150\"/><line x1=\"60\" y1=\"230\" x2=\"1040\" y2=\"230\"/><line x1=\"60\" y1=\"310\" x2=\"1040\" y2=\"310\"/>\n</g>\n<text x=\"60\" y=\"410\" fill=\"#91a0b5\" font-family=\"Arial\" font-size=\"13\">Data inicial</text><text x=\"1040\" y=\"410\" text-anchor=\"end\" fill=\"#91a0b5\" font-family=\"Arial\" font-size=\"13\">Data final</text>\n"
svg_poly_start:     .asciz "<polyline fill=\"none\" stroke=\"#34d399\" stroke-width=\"3.5\" stroke-linecap=\"round\" stroke-linejoin=\"round\" points=\""
svg_poly_end:       .asciz "\"/>\n</svg>\n"

html_header: .asciz "<!doctype html>\n<html lang=\"pt-BR\"><head><meta charset=\"utf-8\"><meta name=\"viewport\" content=\"width=device-width,initial-scale=1\"><title>StockScope</title><style>\n:root{color-scheme:dark}*{box-sizing:border-box}body{margin:0;background:#0b1220;color:#e5edf7;font:15px/1.5 system-ui, sans-serif}.wrap{max-width:1180px;margin:0 auto;padding:34px 22px}.top{display:flex;justify-content:space-between;align-items:center;gap:20px}.brand{color:#6ee7b7;font-weight:800;letter-spacing:.16em;font-size:12px}.period,.muted,.label{color:#91a0b5}.panel,.card{background:#121d2e;border:1px solid #26364c;border-radius:16px}.panel{padding:18px;margin:22px 0}.panel img{display:block;width:100%;height:auto}.grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(190px,1fr));gap:13px}.card{padding:17px}.value{font-size:23px;font-weight:750;margin:5px 0 0}.label{font-size:12px;margin:0}.up{color:#6ee7b7}.down{color:#fda4af}h1{font-size:32px;margin:4px 0}.foot{margin-top:25px;color:#718096;font-size:12px}@media(max-width:600px){.wrap{padding:22px 14px}.top{align-items:flex-start;flex-direction:column}}\n</style></head><body><main class=\"wrap\"><div class=\"top\"><div><div class=\"brand\">STOCKSCOPE / ASSEMBLY ANALYTICS</div>"
html_after_title: .asciz "</div><div class=\"muted\">Analise historica • dados diarios</div></div><section class=\"panel\"><h2>Historico de fechamento</h2><img src=\"grafico.svg\" alt=\"Grafico historico de precos\"></section><section class=\"grid\">\n"
html_card_close: .asciz "<article class=\"card\"><p class=\"label\">Ultimo fechamento</p><p class=\"value\">"
html_card_average: .asciz "</p></article><article class=\"card\"><p class=\"label\">Preco medio</p><p class=\"value\">"
html_card_max: .asciz "</p></article><article class=\"card\"><p class=\"label\">Maior fechamento</p><p class=\"value\">"
html_card_min: .asciz "</p></article><article class=\"card\"><p class=\"label\">Menor fechamento</p><p class=\"value\">"
html_card_return: .asciz "</p></article><article class=\"card\"><p class=\"label\">Retorno total</p><p class=\"value\">"
html_card_ma7: .asciz "</p></article><article class=\"card\"><p class=\"label\">Media movel (7 pregoes)</p><p class=\"value\">"
html_card_ma21: .asciz "</p></article><article class=\"card\"><p class=\"label\">Media movel (21 pregoes)</p><p class=\"value\">"
html_card_volatility: .asciz "</p></article><article class=\"card\"><p class=\"label\">Volatilidade diaria (desvio padrao)</p><p class=\"value\">"
html_card_best: .asciz "</p></article><article class=\"card\"><p class=\"label\">Melhor variacao diaria</p><p class=\"value up\">"
html_card_worst: .asciz "</p></article><article class=\"card\"><p class=\"label\">Pior variacao diaria</p><p class=\"value down\">"
html_card_volume: .asciz "</p></article><article class=\"card\">"
html_end: .asciz "</section><p class=\"foot\">Gerado por StockScope. Os calculos estatisticos e o grafico foram produzidos pelo programa Assembly x86-64. Material educativo; nao constitui recomendacao de investimento.</p></main></body></html>\n"


.section .bss
.align 16
csv_ptr:       .skip 8
ticker_ptr:    .skip 8
linebuf:       .skip 8192
dates:         .skip 32000       # 2000 x 16 bytes
closes:        .skip 16000       # 2000 x 8 bytes
volumes:       .skip 16000
n_records:     .skip 8
min_close:     .skip 8
max_close:     .skip 8
avg_close:     .skip 8
avg_volume:    .skip 8
last_close:    .skip 8
total_return:  .skip 8
ma7_value:     .skip 8
ma21_value:    .skip 8
avg_daily:     .skip 8
best_daily:    .skip 8
worst_daily:   .skip 8
volatility:    .skip 8
io_byte:       .skip 1
num_buf:       .skip 32

.section .text
.global _start
.global main
.type _start, @function
.type main, @function

# Ponto de entrada sem a CRT/libc. O kernel entrega argc e argv na pilha.
_start:
    pop rdi                     # argc
    mov rsi, rsp                # argv
    and rsp, -16
    call main
    mov edi, eax
    mov eax, 60                 # sys_exit
    syscall

main:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8                 # alinhamento de pilha antes de chamadas libc

    cmp edi, 3
    jl .usage
    mov rax, qword ptr [rsi + 8]
    mov qword ptr [rip + csv_ptr], rax
    mov rax, qword ptr [rsi + 16]
    mov qword ptr [rip + ticker_ptr], rax

    # Abre o CSV.
    mov rdi, qword ptr [rip + csv_ptr]
    lea rsi, [rip + mode_r]
    xor eax, eax
    call fopen
    test rax, rax
    jz .open_error
    mov rbx, rax

    # Descarta o cabecalho.
    lea rdi, [rip + linebuf]
    mov esi, 8192
    mov rdx, rbx
    call fgets
    test rax, rax
    jz .empty_after_read

    xor r12d, r12d             # quantidade de registros
.read_loop:
    lea rdi, [rip + linebuf]
    mov esi, 8192
    mov rdx, rbx
    call fgets
    test rax, rax
    jz .read_done

    cmp byte ptr [rip + linebuf], 10
    je .read_loop
    cmp byte ptr [rip + linebuf], 0
    je .read_loop

    cmp r12, 2000
    jae .limit_error_close

    # Copia YYYY-MM-DD para dates[indice].
    lea rdi, [rip + dates]
    mov rax, r12
    shl rax, 4
    add rdi, rax
    lea rsi, [rip + linebuf]
    mov ecx, 10
    rep movsb
    mov byte ptr [rdi], 0

    # Procura a quinta coluna (Close): pula quatro virgulas.
    lea rdx, [rip + linebuf]
    xor ecx, ecx
.find_close:
    mov al, byte ptr [rdx]
    test al, al
    jz .bad_line
    cmp al, ','
    jne .find_close_next
    inc ecx
    cmp ecx, 4
    je .close_start
.find_close_next:
    inc rdx
    jmp .find_close
.close_start:
    inc rdx                      # primeiro caractere do Close
    mov rdi, rdx
    call parse_cents
    mov r10, r12
    mov qword ptr [closes + r10*8], rax

    # Avanca ate a coluna Volume.
.find_volume:
    mov al, byte ptr [rdx]
    test al, al
    jz .bad_line
    cmp al, ','
    je .volume_start
    inc rdx
    jmp .find_volume
.volume_start:
    inc rdx
    mov rdi, rdx
    call parse_uint
    mov r10, r12
    mov qword ptr [volumes + r10*8], rax

    inc r12
    jmp .read_loop

.bad_line:
    # Linha inesperada: ignora sem incrementar o contador.
    jmp .read_loop

.read_done:
    mov rdi, rbx
    call fclose
    mov qword ptr [rip + n_records], r12
    test r12, r12
    jz .empty_error

    # Estatisticas basicas: min, max, soma de fechamento e volume.
    mov rax, qword ptr [rip + closes]
    mov qword ptr [rip + min_close], rax
    mov qword ptr [rip + max_close], rax
    xor r14d, r14d             # soma dos fechamentos
    xor r15d, r15d             # soma do volume
    xor r13d, r13d
.stats_loop:
    cmp r13, r12
    jae .stats_done
    mov rax, qword ptr [closes + r13*8]
    cmp rax, qword ptr [rip + min_close]
    jge .not_new_min
    mov qword ptr [rip + min_close], rax
.not_new_min:
    cmp rax, qword ptr [rip + max_close]
    jle .not_new_max
    mov qword ptr [rip + max_close], rax
.not_new_max:
    add r14, rax
    mov rdx, qword ptr [volumes + r13*8]
    add r15, rdx
    inc r13
    jmp .stats_loop
.stats_done:
    mov rax, r14
    cqo
    mov rcx, r12
    idiv rcx
    mov qword ptr [rip + avg_close], rax
    mov rax, r15
    xor edx, edx
    mov rcx, r12
    div rcx
    mov qword ptr [rip + avg_volume], rax
    mov rax, r12
    dec rax
    mov rax, qword ptr [closes + rax*8]
    mov qword ptr [rip + last_close], rax

    # Retorno total em centesimos de porcentagem (basis points).
    mov rax, qword ptr [rip + last_close]
    mov rcx, qword ptr [rip + closes]
    sub rax, rcx
    imul rax, rax, 10000
    test rcx, rcx
    jz .zero_total_return
    cqo
    idiv rcx
    mov qword ptr [rip + total_return], rax
    jmp .total_return_done
.zero_total_return:
    mov qword ptr [rip + total_return], 0
.total_return_done:

    # Medias moveis dos ultimos 7 e 21 pregoes.
    mov rdi, 7
    call calc_moving_average
    mov qword ptr [rip + ma7_value], rax
    mov rdi, 21
    call calc_moving_average
    mov qword ptr [rip + ma21_value], rax

    # Retornos diarios em bps: ((fechamento atual - anterior) / anterior) * 10000.
    cmp r12, 2
    jb .no_daily_returns
    xor r14d, r14d             # soma dos retornos
    xor r15d, r15d             # soma dos quadrados
    mov r8, -9223372036854775807
    dec r8                     # menor int64
    mov r9, 9223372036854775807 # maior int64
    mov r13, 1
.daily_loop:
    cmp r13, r12
    jae .daily_done
    mov rax, qword ptr [closes + r13*8]
    mov rbx, r13
    dec rbx
    mov rbx, qword ptr [closes + rbx*8]
    test rbx, rbx
    jz .daily_zero
    sub rax, rbx
    imul rax, rax, 10000
    cqo
    idiv rbx
    jmp .daily_calculated
.daily_zero:
    xor eax, eax
.daily_calculated:
    mov rdx, r13
    dec rdx
    add r14, rax
    mov rdx, rax
    imul rdx, rax
    add r15, rdx
    cmp rax, r8
    jle .check_worst
    mov r8, rax
.check_worst:
    cmp rax, r9
    jge .daily_next
    mov r9, rax
.daily_next:
    inc r13
    jmp .daily_loop
.daily_done:
    mov qword ptr [rip + best_daily], r8
    mov qword ptr [rip + worst_daily], r9
    mov rax, r12
    dec rax                    # quantidade de retornos diarios
    mov rcx, rax
    mov rax, r14
    cqo
    idiv rcx
    mov qword ptr [rip + avg_daily], rax

    # Desvio padrao amostral: sqrt((sum(x^2)-sum(x)^2/n)/(n-1)).
    cmp rcx, 2
    jb .volatility_zero
    mov rax, r14
    imul rax, rax
    cqo
    idiv rcx
    mov rdx, r15
    sub rdx, rax
    mov rax, rdx
    cqo
    mov rbx, rcx
    dec rbx
    idiv rbx
    test rax, rax
    jns .variance_ok
    xor eax, eax
.variance_ok:
    mov rdi, rax
    call isqrt_u64
    mov qword ptr [rip + volatility], rax
    jmp .daily_stats_done
.volatility_zero:
    mov qword ptr [rip + volatility], 0
.daily_stats_done:
    jmp .generate_svg

.no_daily_returns:
    mov qword ptr [rip + best_daily], 0
    mov qword ptr [rip + worst_daily], 0
    mov qword ptr [rip + avg_daily], 0
    mov qword ptr [rip + volatility], 0

.generate_svg:
    # Cria o grafico SVG. As coordenadas sao calculadas aqui, em Assembly.
    lea rdi, [rip + svg_path]
    lea rsi, [rip + mode_w]
    xor eax, eax
    call fopen
    test rax, rax
    jz .output_error
    mov r15, rax
    lea rdi, [rip + svg_header]
    mov rsi, r15
    call fputs

    mov rax, qword ptr [rip + max_close]
    xor edx, edx
    mov ecx, 100
    div rcx
    mov r8, rdx
    mov rdi, r15
    lea rsi, [rip + fmt_svg_max]
    mov rdx, rax
    mov rcx, r8
    xor eax, eax
    call fprintf

    mov rax, qword ptr [rip + min_close]
    xor edx, edx
    mov ecx, 100
    div rcx
    mov r8, rdx
    mov rdi, r15
    lea rsi, [rip + fmt_svg_min]
    mov rdx, rax
    mov rcx, r8
    xor eax, eax
    call fprintf

    lea rdi, [rip + svg_poly_start]
    mov rsi, r15
    call fputs

    xor r13d, r13d
.svg_points_loop:
    cmp r13, r12
    jae .svg_points_done
    # x = 60 + i*980/(n-1); para um unico ponto, centraliza.
    cmp r12, 1
    je .svg_single_x
    mov rax, r13
    imul rax, rax, 980
    mov rcx, r12
    dec rcx
    xor edx, edx
    div rcx
    add rax, 60
    mov rbx, rax
    jmp .svg_calc_y
.svg_single_x:
    mov rbx, 550
.svg_calc_y:
    # y = 350 - ((preco-min)*280)/(max-min).
    mov rax, qword ptr [closes + r13*8]
    sub rax, qword ptr [rip + min_close]
    mov rcx, qword ptr [rip + max_close]
    sub rcx, qword ptr [rip + min_close]
    test rcx, rcx
    jz .svg_flat_line
    imul rax, rax, 280
    xor edx, edx
    div rcx
    mov r14, 350
    sub r14, rax
    jmp .svg_emit_point
.svg_flat_line:
    mov r14, 210
.svg_emit_point:
    mov rdi, r15
    lea rsi, [rip + fmt_svg_point]
    mov rdx, rbx
    mov rcx, r14
    xor eax, eax
    call fprintf
    inc r13
    jmp .svg_points_loop
.svg_points_done:
    lea rdi, [rip + svg_poly_end]
    mov rsi, r15
    call fputs
    mov rdi, r15
    call fclose

    # Gera dashboard HTML (somente apresentacao; sem recalcular indicadores).
    lea rdi, [rip + html_path]
    lea rsi, [rip + mode_w]
    xor eax, eax
    call fopen
    test rax, rax
    jz .output_error
    mov r15, rax
    lea rdi, [rip + html_header]
    mov rsi, r15
    call fputs
    mov rdi, r15
    lea rsi, [rip + fmt_html_ticker]
    mov rdx, qword ptr [rip + ticker_ptr]
    xor eax, eax
    call fprintf
    mov rdi, r15
    lea rsi, [rip + fmt_html_period]
    lea rdx, [rip + dates]
    mov rax, qword ptr [rip + n_records]
    dec rax
    shl rax, 4
    lea rcx, [rip + dates]
    add rcx, rax
    xor eax, eax
    call fprintf
    lea rdi, [rip + html_after_title]
    mov rsi, r15
    call fputs

    # Card: fechamento
    lea rdi, [rip + html_card_close]
    mov rsi, r15
    call fputs
    mov rdi, r15
    mov rsi, qword ptr [rip + last_close]
    call write_money
    lea rdi, [rip + html_card_average]
    mov rsi, r15
    call fputs
    mov rdi, r15
    mov rsi, qword ptr [rip + avg_close]
    call write_money
    lea rdi, [rip + html_card_max]
    mov rsi, r15
    call fputs
    mov rdi, r15
    mov rsi, qword ptr [rip + max_close]
    call write_money
    lea rdi, [rip + html_card_min]
    mov rsi, r15
    call fputs
    mov rdi, r15
    mov rsi, qword ptr [rip + min_close]
    call write_money
    lea rdi, [rip + html_card_return]
    mov rsi, r15
    call fputs
    mov rdi, r15
    mov rsi, qword ptr [rip + total_return]
    call write_percent
    lea rdi, [rip + html_card_ma7]
    mov rsi, r15
    call fputs
    mov rdi, r15
    mov rsi, qword ptr [rip + ma7_value]
    call write_money
    lea rdi, [rip + html_card_ma21]
    mov rsi, r15
    call fputs
    mov rdi, r15
    mov rsi, qword ptr [rip + ma21_value]
    call write_money
    lea rdi, [rip + html_card_volatility]
    mov rsi, r15
    call fputs
    mov rdi, r15
    mov rsi, qword ptr [rip + volatility]
    call write_percent
    lea rdi, [rip + html_card_best]
    mov rsi, r15
    call fputs
    mov rdi, r15
    mov rsi, qword ptr [rip + best_daily]
    call write_percent
    lea rdi, [rip + html_card_worst]
    mov rsi, r15
    call fputs
    mov rdi, r15
    mov rsi, qword ptr [rip + worst_daily]
    call write_percent
    lea rdi, [rip + html_card_volume]
    mov rsi, r15
    call fputs
    mov rdi, r15
    lea rsi, [rip + fmt_html_volume]
    mov rdx, qword ptr [rip + avg_volume]
    xor eax, eax
    call fprintf
    lea rdi, [rip + html_end]
    mov rsi, r15
    call fputs
    mov rdi, r15
    call fclose

    lea rdi, [rip + completed_msg]
    call puts
    xor eax, eax
    jmp .exit

.empty_after_read:
    mov rdi, rbx
    call fclose
.empty_error:
    lea rdi, [rip + empty_error_msg]
    call puts
    mov eax, 1
    jmp .exit
.limit_error_close:
    mov rdi, rbx
    call fclose
    lea rdi, [rip + limit_error_msg]
    call puts
    mov eax, 1
    jmp .exit
.usage:
    lea rdi, [rip + usage_msg]
    call puts
    mov eax, 1
    jmp .exit
.open_error:
    lea rdi, [rip + open_error_msg]
    call puts
    mov eax, 1
    jmp .exit
.output_error:
    lea rdi, [rip + output_error_msg]
    call puts
    mov eax, 1
.exit:
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.size main, .-main

# parse_cents(rdi=ponteiro para valor decimal) -> rax=valor em centavos.
.type parse_cents, @function
parse_cents:
    xor r8d, r8d                # parte inteira
    xor r9d, r9d                # parte fracionaria
    mov r10d, 1                 # sinal
    cmp byte ptr [rdi], '-'
    jne .pc_integer
    mov r10d, -1
    inc rdi
.pc_integer:
    movzx ecx, byte ptr [rdi]
    cmp cl, '0'
    jb .pc_decimal
    cmp cl, '9'
    ja .pc_decimal
    imul r8, r8, 10
    sub ecx, '0'
    add r8, rcx
    inc rdi
    jmp .pc_integer
.pc_decimal:
    cmp byte ptr [rdi], '.'
    jne .pc_finish
    inc rdi
    movzx ecx, byte ptr [rdi]
    cmp cl, '0'
    jb .pc_finish
    cmp cl, '9'
    ja .pc_finish
    sub ecx, '0'
    imul r9, r9, 10
    add r9, rcx
    inc rdi
    movzx ecx, byte ptr [rdi]
    cmp cl, '0'
    jb .pc_one_decimal
    cmp cl, '9'
    ja .pc_one_decimal
    sub ecx, '0'
    imul r9, r9, 10
    add r9, rcx
    jmp .pc_finish
.pc_one_decimal:
    imul r9, r9, 10
.pc_finish:
    imul r8, r8, 100
    add r8, r9
    imul r8, r10
    mov rax, r8
    ret
.size parse_cents, .-parse_cents

# parse_uint(rdi=ponteiro) -> rax=inteiro sem sinal.
.type parse_uint, @function
parse_uint:
    xor eax, eax
.pu_loop:
    movzx ecx, byte ptr [rdi]
    cmp cl, '0'
    jb .pu_done
    cmp cl, '9'
    ja .pu_done
    imul rax, rax, 10
    sub ecx, '0'
    add rax, rcx
    inc rdi
    jmp .pu_loop
.pu_done:
    ret
.size parse_uint, .-parse_uint

# calc_moving_average(rdi=janela) -> rax=media em centavos.
.type calc_moving_average, @function
calc_moving_average:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov r12, rdi
    mov rax, qword ptr [rip + n_records]
    cmp rax, r12
    jae .cma_window_ok
    mov r12, rax
.cma_window_ok:
    mov rbx, r12                # quantidade efetiva de registros
    mov rdx, qword ptr [rip + n_records]
    sub rdx, r12                # indice inicial
    xor r8d, r8d                # soma
.cma_loop:
    test rbx, rbx
    jz .cma_done
    add r8, qword ptr [closes + rdx*8]
    inc rdx
    dec rbx
    jmp .cma_loop
.cma_done:
    mov rax, r8
    cqo
    mov rcx, r12
    test rcx, rcx
    jz .cma_zero
    idiv rcx
    jmp .cma_exit
.cma_zero:
    xor eax, eax
.cma_exit:
    pop r12
    pop rbx
    pop rbp
    ret
.size calc_moving_average, .-calc_moving_average

# isqrt_u64(rdi=n) -> rax=floor(sqrt(n)); Newton-Raphson inteiro.
.type isqrt_u64, @function
isqrt_u64:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    mov r12, rdi
    cmp r12, 2
    jb .sqrt_small
    mov rbx, r12
.sqrt_loop:
    mov rax, r12
    xor edx, edx
    div rbx
    add rax, rbx
    shr rax, 1
    cmp rax, rbx
    jae .sqrt_done
    mov rbx, rax
    jmp .sqrt_loop
.sqrt_done:
    mov rax, rbx
    jmp .sqrt_exit
.sqrt_small:
    mov rax, r12
.sqrt_exit:
    pop r12
    pop rbx
    pop rbp
    ret
.size isqrt_u64, .-isqrt_u64

# write_money(rdi=FILE*, rsi=centavos): escreve R$ 12,34.
.type write_money, @function
write_money:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    mov r12, rdi
    mov r13, rsi
    mov rax, r13
    xor edx, edx
    mov ecx, 100
    div rcx
    mov r8, rdx
    mov rdi, r12
    lea rsi, [rip + fmt_money]
    mov rdx, rax
    mov rcx, r8
    xor eax, eax
    call fprintf
    pop r13
    pop r12
    pop rbp
    ret
.size write_money, .-write_money

# write_percent(rdi=FILE*, rsi=bps): escreve percentual com duas casas.
.type write_percent, @function
write_percent:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    mov r12, rdi
    mov r13, rsi
    lea r10, [rip + percent_plus]
    test r13, r13
    jns .wp_abs_ready
    neg r13
    lea r10, [rip + percent_minus]
.wp_abs_ready:
    mov rax, r13
    xor edx, edx
    mov ecx, 100
    div rcx
    mov r8, rdx
    mov rdi, r12
    lea rsi, [rip + fmt_percent]
    mov rdx, r10
    mov rcx, rax
    xor eax, eax
    call fprintf
    pop r13
    pop r12
    pop rbp
    ret
.size write_percent, .-write_percent

# Rotinas de E/S sem libc. Os descritores retornados por fopen recebem +3,
# assim zero continua sendo o valor de erro esperado pelo restante do programa.
.type fopen, @function
fopen:
    cmp byte ptr [rsi], 'w'
    je .fo_write
    xor esi, esi                # O_RDONLY
    xor edx, edx
    jmp .fo_open
.fo_write:
    mov esi, 577                # O_WRONLY | O_CREAT | O_TRUNC
    mov edx, 420                # 0644
.fo_open:
    mov eax, 2                  # sys_open
    syscall
    test rax, rax
    js .fo_error
    add rax, 3
    ret
.fo_error:
    xor eax, eax
    ret
.size fopen, .-fopen

.type fclose, @function
fclose:
    sub rdi, 3
    mov eax, 3                  # sys_close
    syscall
    ret
.size fclose, .-fclose

# fgets(rdi=buffer, rsi=tamanho, rdx=descritor) -> buffer ou zero no EOF.
.type fgets, @function
fgets:
    push rbx
    push r12
    push r13
    mov r12, rdi
    mov r13, rsi
    mov rbx, rdx
    sub rbx, 3
    xor r9d, r9d
    cmp r13, 1
    jbe .fg_eof
.fg_loop:
    lea rsi, [rip + io_byte]
    mov rdi, rbx
    mov edx, 1
    xor eax, eax                # sys_read
    syscall
    test rax, rax
    jle .fg_done
    mov al, byte ptr [rip + io_byte]
    mov byte ptr [r12 + r9], al
    inc r9
    cmp al, 10
    je .fg_done
    mov rax, r13
    dec rax
    cmp r9, rax
    jb .fg_loop
.fg_done:
    test r9, r9
    jz .fg_eof
    mov byte ptr [r12 + r9], 0
    mov rax, r12
    jmp .fg_exit
.fg_eof:
    xor eax, eax
.fg_exit:
    pop r13
    pop r12
    pop rbx
    ret
.size fgets, .-fgets

# write_buffer(rdi=descritor codificado, rsi=buffer, rdx=tamanho).
.type write_buffer, @function
write_buffer:
    sub rdi, 3
.wb_loop:
    test rdx, rdx
    jz .wb_done
    mov eax, 1                  # sys_write
    syscall
    test rax, rax
    jle .wb_done
    add rsi, rax
    sub rdx, rax
    jmp .wb_loop
.wb_done:
    ret
.size write_buffer, .-write_buffer

.type fputs, @function
fputs:
    mov r8, rdi
    xor edx, edx
.fp_len:
    cmp byte ptr [r8 + rdx], 0
    je .fp_write
    inc rdx
    jmp .fp_len
.fp_write:
    mov rdi, rsi
    mov rsi, r8
    call write_buffer
    ret
.size fputs, .-fputs

.type write_char, @function
write_char:
    mov byte ptr [rip + io_byte], sil
    lea rsi, [rip + io_byte]
    mov edx, 1
    call write_buffer
    ret
.size write_char, .-write_char

# write_uint(rdi=descritor codificado, rsi=valor, rdx=largura minima).
.type write_uint, @function
write_uint:
    lea r8, [rip + num_buf + 31]
    xor ecx, ecx
    mov rax, rsi
    mov r9, rdx
    test rax, rax
    jnz .wu_digits
    dec r8
    mov byte ptr [r8], '0'
    inc ecx
    jmp .wu_pad
.wu_digits:
    mov r10, 10
.wu_digit_loop:
    xor edx, edx
    div r10
    add dl, '0'
    dec r8
    mov byte ptr [r8], dl
    inc ecx
    test rax, rax
    jnz .wu_digit_loop
.wu_pad:
    cmp rcx, r9
    jae .wu_write
    dec r8
    mov byte ptr [r8], '0'
    inc ecx
    jmp .wu_pad
.wu_write:
    mov rsi, r8
    mov rdx, rcx
    call write_buffer
    ret
.size write_uint, .-write_uint

# fprintf limitado aos formatos usados neste programa: %s, %ld, %02ld e %%.
.type fprintf, @function
fprintf:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov r12, rdi                 # descritor
    mov r13, rsi                 # formato
    mov rbx, rdx                 # primeiro argumento variadico
    mov r15, rcx                 # segundo argumento variadico
    xor r14d, r14d
.pf_loop:
    mov al, byte ptr [r13]
    test al, al
    jz .pf_done
    inc r13
    cmp al, '%'
    je .pf_percent
    mov rdi, r12
    mov sil, al
    call write_char
    jmp .pf_loop
.pf_percent:
    mov dl, byte ptr [r13]
    inc r13
    cmp dl, '%'
    je .pf_literal_percent
    xor r8d, r8d
    cmp dl, '0'
    jne .pf_conversion
    mov r8d, 2
    inc r13                     # pula o "2" de %02ld
    mov dl, byte ptr [r13]
    inc r13
.pf_conversion:
    cmp dl, 's'
    je .pf_select_arg
    cmp dl, 'l'
    jne .pf_loop
    mov dl, byte ptr [r13]
    inc r13
.pf_select_arg:
    cmp r14d, 0
    jne .pf_arg2
    mov rsi, rbx
    jmp .pf_arg_ready
.pf_arg2:
    mov rsi, r15
.pf_arg_ready:
    inc r14d
    cmp dl, 's'
    je .pf_string
    cmp dl, 'd'
    jne .pf_loop
    mov rdi, r12
    mov rdx, r8
    call write_uint
    jmp .pf_loop
.pf_string:
    mov rdi, rsi
    mov rsi, r12
    call fputs
    jmp .pf_loop
.pf_literal_percent:
    mov rdi, r12
    mov sil, '%'
    call write_char
    jmp .pf_loop
.pf_done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
.size fprintf, .-fprintf

.type puts, @function
puts:
    mov r8, rdi
    mov rdi, r8
    mov esi, 4                  # stdout (1) codificado
    call fputs
    mov edi, 4
    mov sil, 10
    call write_char
    ret
.size puts, .-puts

.section .note.GNU-stack,"",@progbits
