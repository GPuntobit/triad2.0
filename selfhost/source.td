# selfhost/source.td — nuovo algoritmo per il codice sorgente (front-end S1)
#
# Provenienza: la grammatica e la classificazione dei token derivano dal SEED IN
# CODICE MACCHINA (seed/dev/gen_seed.js: parse_program, parse_ident, skip_ws,
# scan_end, parse_expr, parse_ternary, parse_sum, parse_term, parse_power,
# parse_primary, pf_list, pf_string, pf_symbol, st_if, st_while, st_let,
# st_begin, st_function, st_func, st_break, stmt_assign, st_add_check).
# NON deriva dalla vecchia implementazione Julia (rimossa dal repository):
# il codice macchina e' la reference eseguibile del linguaggio.
#
# Architettura (nuova): il seed e' scannerless e il Julia era un lexer+parser
# classici; questo algoritmo e' "root-scan + discesa ricorsiva":
#   1. SCANNER — next_tok() classifica un token alla volta su un cursore
#      esplicito pos = ci * 64 + oi (chunk, offset). Il token si legge campo
#      per campo: next_tok(srcs, pos, campo) con 0 = tipo, 1 = a, 2 = b,
#      3 = posizione di fine. Nessun vettore di token.
#   2. ROOT-SCAN — root_pos() percorre i token dell'espressione corrente fino
#      al suo termine (parentesi/bracket/virgola/ternario, con contatori di
#      profondita' come scan_end e pt_scan del codice macchina) e restituisce
#      la posizione dell'operatore radice: l'ULTIMO operatore di precedenza
#      minima (catene left-assoc del codice macchina), con ? e -> a
#      associativita' destra (primo vince).
#   3. DISCESA — parse_expr() stampa il nodo radice e ricorsivamente i due
#      sotto-intervalli [inizio, radice) e (radice, fine): AST in PRE-ORDINE
#      con la profondita' come prefisso decimale, stampato durante il parsing.
#
# Perche' niente liste e niente ritorni multipli: sul seed ogni VALUTAZIONE di
# un letterale di lista alloca 528 byte fissi nell'heap (64 KB totali, bump
# allocator senza liberazione) — misurato: ~60 liste per esecuzione vanno,
# ~250 fanno crashare il processo (tests/probes/bad_lista_alloc.td). Ogni
# funzione torna quindi UN solo valore (Int o String); i campi multipli si
# estraggono con scansioni ripetute (puro, senza costi di memoria).
#
# Lessico (SPEC-CORE, dominio del codice macchina): numeri decimali con
# separatori _ opzionali (ignorati), identificatori [A-Za-z_][A-Za-z0-9_]* con
# un '!' finale opzionale, stringhe "..." con escape \n \t \" \\ , simboli
# :nome o :+, commenti # e #= =#, separatori spazio/tab/CR/LF/; tutti trivia
# (come skip_ws del codice macchina), operatori
# + - * % ^ == != < <= > >= && || ! = += -= *= -> ? : e delimitatori ( ) [ ] ,.
#
# Vincoli del seed rispettati (misurati su seed.exe, vedi tests/probes):
# massimo 4 parametri per funzione; valore di corpo = variabile o letterale
# (mai una chiamata o un if come ultima espressione); niente return;
# println a un solo argomento; niente += su stringhe; niente escape nei
# letterali di QUESTO file; nessun identificatore o letterale minuscolo
# contiene le sottostringhe if/let/while/end/else/elseif (il contatore di
# annidamento del seed e' cieco al contesto: le etichette dell'AST sono
# quindi maiuscole); i nomi di statement iniziano con minuscola o _.
#
# Divergenze segnalate (non inventate):
#   - "a ? b :c" (due punti attaccato al ramo): risolto — in posizione di
#     operatore un token SYM viene reinterpretato come colon piu' il resto
#     (root_pos e parse_expr), come fa il codice macchina scannerless.
#   - i simboli operatore del lessico Core (':+') sono qui accettati dallo
#     scanner (superset del dominio del codice macchina, che li rifiuta):
#     l'esecuzione sul seed resta ai punti 7/11 dei problemi aperti.
#   - il junk a destra del corpo di una funzione breve non viene saltato (il
#     codice macchina ignora il resto riga): qui produce un nodo ERR.
#   - il seed valuta solo '+=' fra gli operatori composti; '-=' e '*=' sono
#     del lessico Core e qui sono accettati dal parser (ADD/SUB/MUL-ASSIGN).
#   - massimo 4 parametri per funzione e ~60 liste per esecuzione sono LIMITI
#     DEL SEED, non della specifica (SPEC-CORE non li impone).
#   - scope DINAMICO sul seed (env_find vede i locali del chiamante) contro
#     scope lessicale del JS: i nomi locali di questo file non devono
#     collisionare con i globali letti dalle funzioni (lezione del bug p2:
#     pad() leggeva il locale p2 del chiamante invece del globale "2 ").
#   - i letterali di lista su piu' righe sono ora accettati dai due runtime:
#     il parser del riferimento JS salta i separatori dentro [ ... ].
#
# Verifica: node tests/probes/run_probes.mjs selfhost/source.td
# (stdout identico byte per byte su seed PE e interprete JS di riferimento)
# e confronto con selfhost/source.expected.out.

# --- codici token -----------------------------------------------------------
k_eof = 0
k_num = 1
k_ident = 2
k_str = 3
k_sym = 4
k_op = 5
k_kw = 6
k_err = 7

# --- codici operatore (campo a del token k_op) ------------------------------
o_plus = 1
o_minus = 2
o_star = 3
o_pct = 4
o_caret = 5
o_eq = 6
o_eqeq = 7
o_ne = 8
o_lt = 9
o_le = 10
o_gt = 11
o_ge = 12
o_andand = 13
o_oror = 14
o_bang = 15
o_pluseq = 16
o_minuseq = 17
o_stareq = 18
o_arrow = 19
o_lpar = 20
o_rpar = 21
o_lbkt = 22
o_rbkt = 23
o_comma = 24
o_qmark = 25
o_colon = 26

# --- codici keyword (le parole del codice macchina) -------------------------
w_se = 1
w_se_poi = 2
w_altr = 3
w_mentre = 4
w_con = 5
w_inizio = 6
w_fine = 7
w_funz = 8
w_esci = 9
w_stampa = 10
w_vero = 11
w_falso = 12
w_niente = 13

# tabella keyword: [lunghezza, byte..., codice] — gli stessi nomi riconosciuti
# dal codice macchina (parse_program/scan_end/pf_ident + true/false/nothing)
kw_tab = [[2, 105, 102, 1], [6, 101, 108, 115, 101, 105, 102, 2], [4, 101, 108, 115, 101, 3], [5, 119, 104, 105, 108, 101, 4], [3, 108, 101, 116, 5], [5, 98, 101, 103, 105, 110, 6], [3, 101, 110, 100, 7], [8, 102, 117, 110, 99, 116, 105, 111, 110, 8], [5, 98, 114, 101, 97, 107, 9], [7, 112, 114, 105, 110, 116, 108, 110, 10], [4, 116, 114, 117, 101, 11], [5, 102, 97, 108, 115, 101, 12], [7, 110, 111, 116, 104, 105, 110, 103, 13]]

# prefissi di profondita' precompilati (evitano allocazioni per riga)
p0 = "0 "
p1 = "1 "
p2 = "2 "
p3 = "3 "
p4 = "4 "
p5 = "5 "
p6 = "6 "
p7 = "7 "
p8 = "8 "
p9 = "9 "
sp = " "

# --- modello sorgente -------------------------------------------------------
# srcs = lista di chunk; ogni chunk = [n, byte1, ..., byteN] con n <= 63.
# pos = ci * 64 + oi: codice unico di posizione (ci = quoziente, oi = resto).

function pos_ci(p)
  r = 0
  while p >= 64
    p = p - 64
    r = r + 1
  end
  r
end

function pos_oi(p)
  while p >= 64
    p = p - 64
  end
  r = p
  r
end

function byte_at(srcs, p)
  ci = pos_ci(p)
  oi = pos_oi(p)
  ch = get(srcs, ci)
  b = get(ch, oi + 1)
  b
end

function at_eof(srcs, p)
  ci = pos_ci(p)
  r = ci >= length(srcs)
  r
end

function cur_adv(srcs, p)
  ci = pos_ci(p)
  oi = pos_oi(p)
  ch = get(srcs, ci)
  n = get(ch, 0)
  o2 = oi + 1
  c2 = ci
  if o2 >= n
    c2 = ci + 1
    o2 = 0
  end
  r = c2 * 64 + o2
  r
end

function peek_at(srcs, p, k)
  q = p
  i = 0
  b = -1
  go = 1
  while (i < k) && (go == 1)
    if at_eof(srcs, q) == true
      go = 0
    else
      q = cur_adv(srcs, q)
      i = i + 1
    end
  end
  if at_eof(srcs, q) == false
    b = byte_at(srcs, q)
  end
  b
end

# --- classi di caratteri (byte ASCII) ---------------------------------------
function is_sp(b)
  r = (b == 32) || (b == 9) || (b == 13) || (b == 10) || (b == 59)
  r
end

function is_dgt(b)
  r = (b >= 48) && (b <= 57)
  r
end

function is_alf(b)
  r = ((b >= 65) && (b <= 90)) || ((b >= 97) && (b <= 122))
  r
end

function is_nam(b)
  r = is_alf(b) || is_dgt(b) || (b == 95)
  r
end

function is_ini(b)
  r = is_alf(b) || (b == 95)
  r
end

function is_opc(b)
  r = (b == 43) || (b == 45) || (b == 42) || (b == 37) || (b == 94) || (b == 61) || (b == 33) || (b == 60) || (b == 62) || (b == 38) || (b == 124) || (b == 63)
  r
end

# --- riconoscimento keyword -------------------------------------------------
function kw_code(srcs, p, n)
  r = 0
  i = 0
  while i < length(kw_tab)
    e = get(kw_tab, i)
    if get(e, 0) == n
      ok = 1
      j = 1
      q = p
      while j <= n
        if byte_at(srcs, q) != get(e, j)
          ok = 0
        end
        q = cur_adv(srcs, q)
        j = j + 1
      end
      if ok == 1
        r = get(e, n + 1)
      end
    end
    i = i + 1
  end
  r
end

# --- scanner ----------------------------------------------------------------
# salta spazi/tab/CR/LF/; e i commenti # e #= =# (trivia, come skip_ws)
function skip_trivia(srcs, p)
  run = 1
  while run == 1
    run = 0
    if at_eof(srcs, p) == false
      b = byte_at(srcs, p)
      if is_sp(b) == true
        p = cur_adv(srcs, p)
        run = 1
      else
        if b == 35
          p = cur_adv(srcs, p)
          blk = 0
          if at_eof(srcs, p) == false
            if byte_at(srcs, p) == 61
              blk = 1
              p = cur_adv(srcs, p)
            end
          end
          done = 0
          while done == 0
            if at_eof(srcs, p) == true
              done = 1
            else
              b2 = byte_at(srcs, p)
              if blk == 1
                b3 = peek_at(srcs, p, 1)
                if (b2 == 61) && (b3 == 35)
                  p = cur_adv(srcs, p)
                  p = cur_adv(srcs, p)
                  done = 1
                else
                  p = cur_adv(srcs, p)
                end
              else
                if b2 == 10
                  done = 1
                else
                  p = cur_adv(srcs, p)
                end
              end
            end
          end
          run = 1
        end
      end
    end
  end
  r = p
  r
end

# next_tok(srcs, pos, campo) -> Int
#   campo 0: tipo token (k_*)
#   campo 1: a  (k_num: valore | k_ident/k_sym/k_str: pos del nome/contenuto
#              | k_op: codice o_* | k_kw: codice w_* | k_err: byte ignoto)
#   campo 2: b  (lunghezza in byte; per k_num il numero di cifre)
#   campo 3: posizione di fine token (dopo il consumo)
function next_tok(srcs, p, f)
  q = skip_trivia(srcs, p)
  kind = k_eof
  a = 0
  b = 0
  if at_eof(srcs, q) == false
    c = byte_at(srcs, q)
    if is_dgt(c) == true
      kind = k_num
      val = 0
      dgts = 0
      go = 1
      while go == 1
        go = 0
        if at_eof(srcs, q) == false
          c2 = byte_at(srcs, q)
          if is_dgt(c2) == true
            val = val * 10 + (c2 - 48)
            dgts = dgts + 1
            q = cur_adv(srcs, q)
            go = 1
          else
            if c2 == 95
              q = cur_adv(srcs, q)
              go = 1
            end
          end
        end
      end
      a = val
      b = dgts
    else
      if is_ini(c) == true
        pc = q
        cnt = 0
        go = 1
        while go == 1
          go = 0
          if at_eof(srcs, q) == false
            if is_nam(byte_at(srcs, q)) == true
              cnt = cnt + 1
              q = cur_adv(srcs, q)
              go = 1
            end
          end
        end
        if at_eof(srcs, q) == false
          if byte_at(srcs, q) == 33
            cnt = cnt + 1
            q = cur_adv(srcs, q)
          end
        end
        kc = kw_code(srcs, pc, cnt)
        if kc > 0
          kind = k_kw
          a = kc
        else
          kind = k_ident
          a = pc
          b = cnt
        end
      else
        if c == 34
          kind = k_str
          q = cur_adv(srcs, q)
          pc = q
          cnt = 0
          done = 0
          while done == 0
            if at_eof(srcs, q) == true
              done = 1
            else
              c2 = byte_at(srcs, q)
              if c2 == 34
                done = 1
              else
                if c2 == 92
                  q = cur_adv(srcs, q)
                  cnt = cnt + 1
                end
                if at_eof(srcs, q) == false
                  q = cur_adv(srcs, q)
                  cnt = cnt + 1
                end
              end
            end
          end
          if at_eof(srcs, q) == true
            kind = k_err
            a = 34
          else
            q = cur_adv(srcs, q)
            a = pc
            b = cnt
          end
        else
          if c == 58
            q = cur_adv(srcs, q)
            pc = q
            cnt = 0
            go = 1
            while go == 1
              go = 0
              if at_eof(srcs, q) == false
                if is_nam(byte_at(srcs, q)) == true
                  cnt = cnt + 1
                  q = cur_adv(srcs, q)
                  go = 1
                end
              end
            end
            if cnt == 0
              # simboli operatore del lessico Core (':+', ':-', ...): il nome
              # e' una corsa di caratteri operatore (SPEC-CORE §2)
              go = 1
              while go == 1
                go = 0
                if at_eof(srcs, q) == false
                  if is_opc(byte_at(srcs, q)) == true
                    cnt = cnt + 1
                    q = cur_adv(srcs, q)
                    go = 1
                  end
                end
              end
            end
            if cnt == 0
              kind = k_op
              a = o_colon
            else
              kind = k_sym
              a = pc
              b = cnt
            end
          else
            c2 = peek_at(srcs, q, 1)
            code = 0
            adv = 1
            if c == 43
              code = o_plus
              if c2 == 61
                code = o_pluseq
                adv = 2
              end
            else
              if c == 45
                code = o_minus
                if c2 == 61
                  code = o_minuseq
                  adv = 2
                else
                  if c2 == 62
                    code = o_arrow
                    adv = 2
                  end
                end
              else
                if c == 42
                  code = o_star
                  if c2 == 61
                    code = o_stareq
                    adv = 2
                  end
                else
                  if c == 37
                    code = o_pct
                  else
                    if c == 94
                      code = o_caret
                    else
                      if c == 61
                        code = o_eq
                        if c2 == 61
                          code = o_eqeq
                          adv = 2
                        end
                      else
                        if c == 33
                          code = o_bang
                          if c2 == 61
                            code = o_ne
                            adv = 2
                          end
                        else
                          if c == 60
                            code = o_lt
                            if c2 == 61
                              code = o_le
                              adv = 2
                            end
                          else
                            if c == 62
                              code = o_gt
                              if c2 == 61
                                code = o_ge
                                adv = 2
                              end
                            else
                              if c == 38
                                if c2 == 38
                                  code = o_andand
                                  adv = 2
                                end
                              else
                                if c == 124
                                  if c2 == 124
                                    code = o_oror
                                    adv = 2
                                  end
                                else
                                  if c == 63
                                    code = o_qmark
                                  else
                                    if c == 40
                                      code = o_lpar
                                    else
                                      if c == 41
                                        code = o_rpar
                                      else
                                        if c == 91
                                          code = o_lbkt
                                        else
                                          if c == 93
                                            code = o_rbkt
                                          else
                                            if c == 44
                                              code = o_comma
                                            end
                                          end
                                        end
                                      end
                                    end
                                  end
                                end
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
            q = cur_adv(srcs, q)
            if adv == 2
              q = cur_adv(srcs, q)
            end
            if code == 0
              kind = k_err
              a = c
            else
              kind = k_op
              a = code
            end
          end
        end
      end
    end
  end
  r = kind
  if f == 1
    r = a
  else
    if f == 2
      r = b
    else
      if f == 3
        r = q
      end
    end
  end
  r
end

# --- utilita' token e rendering ---------------------------------------------
function is_tok(srcs, p, kind, code)
  k = next_tok(srcs, p, 0)
  a = next_tok(srcs, p, 1)
  r = (k == kind) && (a == code)
  r
end

function pad(d)
  r = sp
  if d == 0
    r = p0
  else
    if d == 1
      r = p1
    else
      if d == 2
        r = p2
      else
        if d == 3
          r = p3
        else
          if d == 4
            r = p4
          else
            if d == 5
              r = p5
            else
              if d == 6
                r = p6
              else
                if d == 7
                  r = p7
                else
                  if d == 8
                    r = p8
                  else
                    if d == 9
                      r = p9
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
  r
end

function mk(d, label)
  s = pad(d) * label
  s
end

function mk1(d, label, v)
  s = pad(d) * label * sp * string(v)
  s
end

function mk2(d, label, a, b)
  s = pad(d) * label * sp * string(a) * sp * string(b)
  s
end

# --- root-scan --------------------------------------------------------------
# root_pos(srcs, pos, lim) -> posizione del token operatore radice
# dell'espressione che inizia in pos, oppure -1 se l'espressione e' un primario
# (letterale, identificatore, chiamata, lista, gruppo).
#
# L'espressione termina su: fine sorgente, limite lim, ',' ')' ']' a profondita'
# parentesi 0, ':' a profondita' ternario 0 (chiusura di un ramo vero), oppure
# un token operando dove ci si aspetta gia' un operando (inizio statement).
#
# Scelta della radice (come il codice macchina):
#   -> e ? hanno associativita' destra: PRIMO a parita' di precedenza vince;
#   gli altri operatori sono left-assoc (catene in parse_sum/parse_term/
#   parse_cmp/parse_and/parse_or/parse_power): ULTIMO a parita' vince;
#   vince sempre la precedenza minima (operatore piu' esterno).
#   Precedenze: -> 0, ? 1, || 2, && 3, confronti 4, + - 5, * % 6, ^ 7.
function root_pos(srcs, pos, lim)
  best = -1
  bestp = 99
  d = 0
  td = 0
  pre = 1
  prev = 0
  q = pos
  done = 0
  while done == 0
    if (lim > 0) && (q == lim)
      done = 1
    else
      kt = next_tok(srcs, q, 0)
      if kt == k_eof
        done = 1
      else
        ka = next_tok(srcs, q, 1)
        if kt == k_op
          if (ka == o_lpar) || (ka == o_lbkt)
            okgo = 1
            if (pre == 0) && (ka == o_lbkt)
              okgo = 0
            end
            if (pre == 0) && (ka == o_lpar) && (prev != k_ident)
              okgo = 0
            end
            if okgo == 1
              d = d + 1
              pre = 1
              prev = kt
              q = next_tok(srcs, q, 3)
            else
              done = 1
            end
          else
            if (ka == o_rpar) || (ka == o_rbkt)
              if d == 0
                done = 1
              else
                d = d - 1
                pre = 0
                prev = kt
                q = next_tok(srcs, q, 3)
              end
            else
              if (ka == o_comma) && (d == 0)
                done = 1
              else
                if (ka == o_colon) && (d == 0)
                  if td > 0
                    td = td - 1
                    pre = 1
                    prev = kt
                    q = next_tok(srcs, q, 3)
                  else
                    done = 1
                  end
                else
                  if ka == o_qmark
                    if (pre == 0) && (d == 0)
                      if bestp > 1
                        best = q
                        bestp = 1
                      end
                    end
                    td = td + 1
                    pre = 1
                    prev = kt
                    q = next_tok(srcs, q, 3)
                  else
                    if ka == o_arrow
                      if (pre == 0) && (d == 0)
                        if bestp > 0
                          best = q
                          bestp = 0
                        end
                      end
                      pre = 1
                      prev = kt
                      q = next_tok(srcs, q, 3)
                    else
                      pr = 9
                      if ka == o_oror
                        pr = 2
                      else
                        if ka == o_andand
                          pr = 3
                        else
                          if (ka == o_eqeq) || (ka == o_ne) || (ka == o_lt) || (ka == o_le) || (ka == o_gt) || (ka == o_ge)
                            pr = 4
                          else
                            if (ka == o_plus) || (ka == o_minus)
                              pr = 5
                            else
                              if (ka == o_star) || (ka == o_pct)
                                pr = 6
                              else
                                if ka == o_caret
                                  pr = 7
                                end
                              end
                            end
                          end
                        end
                      end
                      if pr < 9
                        if (pre == 0) && (d == 0)
                          if pr <= bestp
                            best = q
                            bestp = pr
                          end
                        end
                        pre = 1
                        prev = kt
                        q = next_tok(srcs, q, 3)
                      else
                        if d == 0
                          done = 1
                        else
                          pre = 1
                          prev = kt
                          q = next_tok(srcs, q, 3)
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        else
          if (kt == k_sym) && (pre == 0) && (d == 0) && (td > 0)
            # ':' attaccato al ramo (':c') reinterpretato come colon: chiude
            # il ramo vero di un ternario; il resto del token e' riesaminato
            # dalla discesa come operando (il codice macchina fa lo stesso)
            td = td - 1
            pre = 1
            prev = k_op
            q = cur_adv(srcs, skip_trivia(srcs, q))
          else
            if pre == 0
              done = 1
            else
              pre = 0
              prev = kt
              q = next_tok(srcs, q, 3)
            end
          end
        end
      end
    end
  end
  r = best
  r
end

# --- parser: statement (pre-ordine: etichetta prima dei figli) ---------------
# parse_stmts si ferma su EOF o sulle keyword di chiusura blocco
# (end/else/elseif): gestite dal chiamante (if/function/let/while/begin) o
# segnalate dal driver a livello di programma.
function parse_stmts(srcs, pos, d)
  more = 1
  while more == 1
    more = 0
    kt = next_tok(srcs, pos, 0)
    ka = next_tok(srcs, pos, 1)
    fin = 0
    if kt == k_eof
      fin = 1
    else
      if (kt == k_kw) && ((ka == w_fine) || (ka == w_altr) || (ka == w_se_poi))
        fin = 1
      end
    end
    if fin == 0
      pos = parse_stmt(srcs, pos, d)
      more = 1
    end
  end
  r = pos
  r
end

function parse_stmt(srcs, pos, d)
  kt = next_tok(srcs, pos, 0)
  np = pos
  if kt == k_kw
    ka = next_tok(srcs, pos, 1)
    nx = next_tok(srcs, pos, 3)
    if ka == w_stampa
      println(mk(d, "PRINTLN"))
      np = nx
      if is_tok(srcs, np, k_op, o_lpar) == true
        np = next_tok(srcs, np, 3)
      else
        println(mk(d + 1, "ERR"))
      end
      np = parse_expr(srcs, np, d + 1, 0)
      if is_tok(srcs, np, k_op, o_rpar) == true
        np = next_tok(srcs, np, 3)
      else
        println(mk(d + 1, "ERR"))
      end
    else
      if ka == w_esci
        println(mk(d, "BREAK"))
        np = nx
      else
        if ka == w_se
          println(mk(d, "IF"))
          np = parse_expr(srcs, nx, d + 1, 0)
          np = parse_stmts(srcs, np, d + 1)
          more = 1
          while more == 1
            more = 0
            if is_tok(srcs, np, k_kw, w_se_poi) == true
              println(mk(d, "ELSEIF"))
              np = next_tok(srcs, np, 3)
              np = parse_expr(srcs, np, d + 1, 0)
              np = parse_stmts(srcs, np, d + 1)
              more = 1
            else
              if is_tok(srcs, np, k_kw, w_altr) == true
                println(mk(d, "ELSE"))
                np = next_tok(srcs, np, 3)
                np = parse_stmts(srcs, np, d + 1)
              end
            end
          end
          if is_tok(srcs, np, k_kw, w_fine) == true
            np = next_tok(srcs, np, 3)
          else
            println(mk(d + 1, "ERR"))
          end
        else
          if ka == w_mentre
            println(mk(d, "WHILE"))
            np = parse_expr(srcs, nx, d + 1, 0)
            np = parse_stmts(srcs, np, d + 1)
            if is_tok(srcs, np, k_kw, w_fine) == true
              np = next_tok(srcs, np, 3)
            else
              println(mk(d + 1, "ERR"))
            end
          else
            if ka == w_con
              println(mk2(d, "LET", next_tok(srcs, nx, 1), next_tok(srcs, nx, 2)))
              np = next_tok(srcs, nx, 3)
              if is_tok(srcs, np, k_op, o_eq) == true
                np = next_tok(srcs, np, 3)
              else
                println(mk(d + 1, "ERR"))
              end
              np = parse_expr(srcs, np, d + 1, 0)
              np = parse_stmts(srcs, np, d + 1)
              if is_tok(srcs, np, k_kw, w_fine) == true
                np = next_tok(srcs, np, 3)
              else
                println(mk(d + 1, "ERR"))
              end
            else
              if ka == w_inizio
                println(mk(d, "BEGIN"))
                np = parse_stmts(srcs, nx, d + 1)
                if is_tok(srcs, np, k_kw, w_fine) == true
                  np = next_tok(srcs, np, 3)
                else
                  println(mk(d + 1, "ERR"))
                end
              else
                if ka == w_funz
                  println(mk2(d, "FUNCTION", next_tok(srcs, nx, 1), next_tok(srcs, nx, 2)))
                  np = next_tok(srcs, nx, 3)
                  if is_tok(srcs, np, k_op, o_lpar) == true
                    np = next_tok(srcs, np, 3)
                  else
                    println(mk(d + 1, "ERR"))
                  end
                  if is_tok(srcs, np, k_op, o_rpar) == true
                    np = next_tok(srcs, np, 3)
                  else
                    more = 1
                    while more == 1
                      more = 0
                      println(mk2(d + 1, "PARAM", next_tok(srcs, np, 1), next_tok(srcs, np, 2)))
                      np = next_tok(srcs, np, 3)
                      if is_tok(srcs, np, k_op, o_comma) == true
                        np = next_tok(srcs, np, 3)
                        more = 1
                      end
                    end
                    if is_tok(srcs, np, k_op, o_rpar) == true
                      np = next_tok(srcs, np, 3)
                    else
                      println(mk(d + 1, "ERR"))
                    end
                  end
                  more = 1
                  while more == 1
                    more = 0
                    if is_tok(srcs, np, k_op, o_bang) == true
                      np = next_tok(srcs, np, 3)
                      println(mk2(d + 1, "EFFECT", next_tok(srcs, np, 1), next_tok(srcs, np, 2)))
                      np = next_tok(srcs, np, 3)
                      if is_tok(srcs, np, k_op, o_comma) == true
                        np = next_tok(srcs, np, 3)
                        more = 1
                      end
                    end
                  end
                  np = parse_stmts(srcs, np, d + 1)
                  if is_tok(srcs, np, k_kw, w_fine) == true
                    np = next_tok(srcs, np, 3)
                  else
                    println(mk(d + 1, "ERR"))
                  end
                else
                  np = parse_expr(srcs, pos, d + 1, 0)
                end
              end
            end
          end
        end
      end
    end
  else
    if kt == k_ident
      nx = next_tok(srcs, pos, 3)
      if is_tok(srcs, nx, k_op, o_lpar) == true
        println(mk2(d, "FUNC", next_tok(srcs, pos, 1), next_tok(srcs, pos, 2)))
        np = next_tok(srcs, nx, 3)
        if is_tok(srcs, np, k_op, o_rpar) == true
          np = next_tok(srcs, np, 3)
        else
          more = 1
          while more == 1
            more = 0
            println(mk2(d + 1, "PARAM", next_tok(srcs, np, 1), next_tok(srcs, np, 2)))
            np = next_tok(srcs, np, 3)
            if is_tok(srcs, np, k_op, o_comma) == true
              np = next_tok(srcs, np, 3)
              more = 1
            end
          end
          if is_tok(srcs, np, k_op, o_rpar) == true
            np = next_tok(srcs, np, 3)
          else
            println(mk(d + 1, "ERR"))
          end
        end
        if is_tok(srcs, np, k_op, o_eq) == true
          np = next_tok(srcs, np, 3)
        else
          println(mk(d + 1, "ERR"))
        end
        np = parse_expr(srcs, np, d + 1, 0)
      else
        if is_tok(srcs, nx, k_op, o_eq) == true
          println(mk2(d, "ASSIGN", next_tok(srcs, pos, 1), next_tok(srcs, pos, 2)))
          np = next_tok(srcs, nx, 3)
          np = parse_expr(srcs, np, d + 1, 0)
        else
          if is_tok(srcs, nx, k_op, o_pluseq) == true
            println(mk2(d, "ADD-ASSIGN", next_tok(srcs, pos, 1), next_tok(srcs, pos, 2)))
            np = next_tok(srcs, nx, 3)
            np = parse_expr(srcs, np, d + 1, 0)
          else
            if is_tok(srcs, nx, k_op, o_minuseq) == true
              println(mk2(d, "SUB-ASSIGN", next_tok(srcs, pos, 1), next_tok(srcs, pos, 2)))
              np = next_tok(srcs, nx, 3)
              np = parse_expr(srcs, np, d + 1, 0)
            else
              if is_tok(srcs, nx, k_op, o_stareq) == true
                println(mk2(d, "MUL-ASSIGN", next_tok(srcs, pos, 1), next_tok(srcs, pos, 2)))
                np = next_tok(srcs, nx, 3)
                np = parse_expr(srcs, np, d + 1, 0)
              else
                println(mk(d, "EXPR"))
                np = parse_expr(srcs, pos, d + 1, 0)
              end
            end
          end
        end
      end
    else
      println(mk(d, "EXPR"))
      np = parse_expr(srcs, pos, d + 1, 0)
    end
  end
  r = np
  r
end

# --- parser: espressioni (pre-ordine con radice scelta dal root-scan) -------
function parse_expr(srcs, pos, d, lim)
  kt = next_tok(srcs, pos, 0)
  ka = next_tok(srcs, pos, 1)
  unf = 0
  lbl = "NEG"
  if (kt == k_op) && (ka == o_minus)
    unf = 1
  else
    if (kt == k_op) && (ka == o_bang)
      unf = 1
      lbl = "NOT"
    end
  end
  np = pos
  if unf == 1
    println(mk(d, lbl))
    np = next_tok(srcs, pos, 3)
    np = parse_expr(srcs, np, d + 1, lim)
  else
    rp = root_pos(srcs, pos, lim)
    if rp < 0
      np = parse_prim(srcs, pos, d)
    else
      ka = next_tok(srcs, rp, 1)
      if ka == o_arrow
        println(mk2(d, "LAMBDA", next_tok(srcs, pos, 1), next_tok(srcs, pos, 2)))
        np = next_tok(srcs, rp, 3)
        np = parse_expr(srcs, np, d + 1, lim)
      else
        if ka == o_qmark
          println(mk(d, "TERN"))
          np = parse_expr(srcs, pos, d + 1, rp)
          np = next_tok(srcs, rp, 3)
          np = parse_expr(srcs, np, d + 1, 0)
          if is_tok(srcs, np, k_op, o_colon) == true
            np = next_tok(srcs, np, 3)
          else
            if next_tok(srcs, np, 0) == k_sym
              # ':' attaccato al ramo (':c'): il token SYM ricomincia come
              # colon piu' il resto, che la discesa riesamina
              np = cur_adv(srcs, skip_trivia(srcs, np))
            else
              println(mk(d + 1, "ERR"))
            end
          end
          np = parse_expr(srcs, np, d + 1, lim)
        else
          lbl = "ADD"
          if ka == o_minus
            lbl = "SUB"
          else
            if ka == o_star
              lbl = "MUL"
            else
              if ka == o_pct
                lbl = "MOD"
              else
                if ka == o_caret
                  lbl = "POW"
                else
                  if ka == o_eqeq
                    lbl = "EQ"
                  else
                    if ka == o_ne
                      lbl = "NE"
                    else
                      if ka == o_lt
                        lbl = "LT"
                      else
                        if ka == o_le
                          lbl = "LE"
                        else
                          if ka == o_gt
                            lbl = "GT"
                          else
                            if ka == o_ge
                              lbl = "GE"
                            else
                              if ka == o_andand
                                lbl = "AND"
                              else
                                if ka == o_oror
                                  lbl = "OR"
                                end
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
          println(mk(d, lbl))
          np = parse_expr(srcs, pos, d + 1, rp)
          np = next_tok(srcs, rp, 3)
          np = parse_expr(srcs, np, d + 1, lim)
        end
      end
    end
  end
  r = np
  r
end

function parse_prim(srcs, pos, d)
  kt = next_tok(srcs, pos, 0)
  ka = next_tok(srcs, pos, 1)
  kb = next_tok(srcs, pos, 2)
  np = next_tok(srcs, pos, 3)
  if kt == k_num
    println(mk1(d, "NUM", ka))
  else
    if kt == k_str
      println(mk2(d, "STR", ka, kb))
    else
      if kt == k_sym
        println(mk2(d, "SYM", ka, kb))
      else
        if kt == k_kw
          if ka == w_vero
            println(mk(d, "TRUE"))
          else
            if ka == w_falso
              println(mk(d, "FALSE"))
            else
              if ka == w_niente
                println(mk(d, "NOTHING"))
              else
                println(mk(d, "ERR"))
              end
            end
          end
        else
          if kt == k_ident
            if is_tok(srcs, np, k_op, o_lpar) == true
              println(mk2(d, "CALL", ka, kb))
              np = next_tok(srcs, np, 3)
              if is_tok(srcs, np, k_op, o_rpar) == true
                np = next_tok(srcs, np, 3)
              else
                more = 1
                while more == 1
                  more = 0
                  np = parse_expr(srcs, np, d + 1, 0)
                  if is_tok(srcs, np, k_op, o_comma) == true
                    np = next_tok(srcs, np, 3)
                    more = 1
                  end
                end
                if is_tok(srcs, np, k_op, o_rpar) == true
                  np = next_tok(srcs, np, 3)
                else
                  println(mk(d + 1, "ERR"))
                end
              end
            else
              println(mk2(d, "IDENT", ka, kb))
            end
          else
            if (kt == k_op) && (ka == o_lbkt)
              println(mk(d, "LIST"))
              if is_tok(srcs, np, k_op, o_rbkt) == true
                np = next_tok(srcs, np, 3)
              else
                more = 1
                while more == 1
                  more = 0
                  np = parse_expr(srcs, np, d + 1, 0)
                  if is_tok(srcs, np, k_op, o_comma) == true
                    np = next_tok(srcs, np, 3)
                    more = 1
                  end
                end
                if is_tok(srcs, np, k_op, o_rbkt) == true
                  np = next_tok(srcs, np, 3)
                else
                  println(mk(d + 1, "ERR"))
                end
              end
            else
              if (kt == k_op) && (ka == o_lpar)
                np = parse_expr(srcs, np, d, 0)
                if is_tok(srcs, np, k_op, o_rpar) == true
                  np = next_tok(srcs, np, 3)
                else
                  println(mk(d + 1, "ERR"))
                end
              else
                println(mk1(d, "ERR", ka))
              end
            end
          end
        end
      end
    end
  end
  r = np
  r
end

# --- sorgente di test (439 byte in 8 chunk) ---------------------------------
# Il programma Triad-Core campione copre tutto il dominio del codice macchina:
# commenti # e #= =#, assegnazioni = += -=, operatori + - * % ^, unari - !,
# confronti, && ||, ternario, parentesi, liste, stringhe con escape, simboli,
# lambda, funzione breve e a blocco con parametri ed effetti, let, begin,
# if/elseif/else, while con break, println, letterali true/false e separatori.
c1 = [63, 35, 61, 32, 100, 101, 109, 111, 32, 115, 111, 114, 103, 101, 110, 116, 101, 32, 61, 35, 10, 120, 32, 61, 32, 49, 32, 43, 32, 50, 32, 42, 32, 51, 10, 121, 32, 61, 32, 40, 120, 32, 45, 32, 52, 41, 32, 37, 32, 53, 10, 122, 32, 61, 32, 45, 120, 32, 94, 32, 50, 10, 98, 32]
c2 = [63, 61, 32, 120, 32, 62, 32, 49, 32, 38, 38, 32, 121, 32, 60, 32, 50, 32, 124, 124, 32, 33, 102, 97, 108, 115, 101, 10, 115, 32, 61, 32, 34, 97, 98, 34, 10, 101, 32, 61, 32, 34, 97, 92, 34, 98, 34, 10, 109, 32, 61, 32, 58, 110, 111, 109, 101, 10, 108, 32, 61, 32, 91, 49]
c3 = [63, 44, 32, 50, 44, 32, 51, 93, 10, 110, 32, 61, 32, 49, 95, 48, 48, 48, 10, 116, 32, 61, 32, 98, 32, 63, 32, 49, 48, 32, 58, 32, 50, 48, 10, 102, 32, 61, 32, 113, 32, 45, 62, 32, 113, 32, 43, 32, 49, 10, 105, 110, 99, 40, 107, 41, 32, 61, 32, 107, 32, 43, 32, 49]
c4 = [63, 10, 102, 117, 110, 99, 116, 105, 111, 110, 32, 103, 40, 97, 44, 32, 99, 41, 32, 33, 105, 111, 10, 32, 32, 114, 32, 61, 32, 97, 32, 42, 32, 99, 10, 32, 32, 114, 10, 101, 110, 100, 10, 108, 101, 116, 32, 119, 32, 61, 32, 51, 10, 32, 32, 119, 32, 43, 61, 32, 49, 10, 101, 110]
c5 = [63, 100, 10, 98, 101, 103, 105, 110, 10, 32, 32, 120, 32, 61, 32, 103, 40, 120, 44, 32, 50, 41, 32, 59, 10, 101, 110, 100, 10, 105, 102, 32, 120, 32, 60, 32, 49, 48, 10, 32, 32, 120, 32, 61, 32, 49, 48, 10, 101, 108, 115, 101, 105, 102, 32, 120, 32, 61, 61, 32, 49, 48, 10, 32]
c6 = [63, 32, 120, 32, 61, 32, 49, 49, 10, 101, 108, 115, 101, 10, 32, 32, 120, 32, 61, 32, 48, 10, 101, 110, 100, 10, 119, 104, 105, 108, 101, 32, 120, 32, 62, 32, 48, 10, 32, 32, 120, 32, 45, 61, 32, 49, 10, 32, 32, 98, 114, 101, 97, 107, 10, 101, 110, 100, 10, 112, 114, 105, 110, 116]
c7 = [6, 108, 110, 40, 120, 41, 10]
# c8 copre i due casi un tempo divergenti: colon attaccato al ramo del
# ternario ('? 5 :7') e simbolo operatore (':+'); la terza riga e' un
# ternario annidato con due colon attaccati
c8 = [55, 117, 32, 61, 32, 48, 32, 61, 61, 32, 48, 32, 63, 32, 53, 32, 58, 55, 10, 115, 32, 61, 32, 58, 43, 10, 118, 32, 61, 32, 49, 32, 61, 61, 32, 49, 32, 63, 32, 50, 32, 61, 61, 32, 50, 32, 63, 32, 51, 32, 58, 52, 32, 58, 53, 10]
srcs = [c1, c2, c3, c4, c5, c6, c7, c8]

# --- driver -----------------------------------------------------------------
println(mk(0, "PROGRAM"))
pos = parse_stmts(srcs, 0, 1)
if next_tok(srcs, pos, 0) == k_eof
  println(mk(0, "EOF"))
else
  println(mk(0, "ERR"))
end
