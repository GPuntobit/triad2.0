@echo off
cd /d "%~dp0"
# Create a modified eval.td without inline comments
echo 1 | # S1.5: Eval espressioni base semplice > eval_mod.td
echo 2 | # Valuta espressioni Int con ambiente inline (identificatori -> valori) >> eval_mod.td
echo >> eval_mod.td
echo 3 | # Valuta un token NUMBER >> eval_mod.td
echo 4 | function eval_number(token) >> eval_mod.td
echo 5 |   get(token, 1) >> eval_mod.td
echo 6 | end >> eval_mod.td
echo >> eval_mod.td
echo 7 | # Valuta un identificatore con lookup nell'ambiente >> eval_mod.td
echo 8 | function eval_identifier(token, env) >> eval_mod.td
echo 9 |   name_start = get(token, 1) >> eval_mod.td
echo 10 | # Cerca nell'ambiente: env = [key1, val1, key2, val2, ...] >> eval_mod.td
echo 11 |   pos = 0 >> eval_mod.td
echo 12 |   while pos < get(env, 0) >> eval_mod.td
echo 13 |     if get(env, pos) == name_start >> eval_mod.td
echo 14 |       return get(env, pos + 1) >> eval_mod.td
echo 15 |     end >> eval_mod.td
echo 16 |     pos = pos + 2 >> eval_mod.td
echo 17 |   end >> eval_mod.td
echo 18 |   0  # Non trovato, restituisce 0 >> eval_mod.td
echo 19 | end >> eval_mod.td
echo >> eval_mod.td
echo 20 | # Valuta espressione semplice (solo NUMBER o IDENTIFIER) >> eval_mod.td
echo 21 | function eval_expr(token, env) >> eval_mod.td
echo 22 |   type = get(token, 0) >> eval_mod.td
echo 23 |   if type == 1 >> eval_mod.td
echo 24 |     eval_number(token) >> eval_mod.td
echo 25 |   else if type == 2 >> eval_mod.td
echo 26 |     eval_identifier(token, env) >> eval_mod.td
echo 27 |   else >> eval_mod.td
echo 28 |     0 >> eval_mod.td
echo 29 |   end >> eval_mod.td
echo 30 | end >> eval_mod.td
echo >> eval_mod.td
echo 31 | # Test eval >> eval_mod.td
echo 32 | # Ambiente: 1="x", 10 >> eval_mod.td
echo 33 | env = [1, 10] >> eval_mod.td
echo >> eval_mod.td
echo 34 | # Sorgente simulato: "42" -> [1, 42, 2] >> eval_mod.td
echo 35 | token_num = [1, 42, 2] >> eval_mod.td
echo 36 | result = eval_expr(token_num, env) >> eval_mod.td
echo 37 | println("eval(42): " * string(result)) >> eval_mod.td
echo >> eval_mod.td
echo 38 | # Sorgente simulato: "x" -> [2, 0, 1] (name_start=0) >> eval_mod.td
echo 39 | token_id = [2, 0, 1] >> eval_mod.td
echo 40 | result = eval_expr(token_id, env) >> eval_mod.td
echo 41 | println("eval(x): " * string(result)) >> eval_mod.td