# Riconoscimento su GitHub (Linguist)

GitHub usa `github-linguist/linguist` per decidere il linguaggio di un file dall'estensione
e dalla grammatica. Perché Triad compaia come linguaggio proprio servono:

1. una voce in `lib/linguist/languages.yml` (modello in `languages.yml` di questa cartella);
2. una grammatica TextMate con scope `source.triad` (quella in `../vscode/syntaxes/` è già
   valida come base);
3. campioni reali (`samples/Triad/*.triad`) nella PR;
4. un `language_id` univoco, assegnato da Linguist.

## Perché `.triad` e non `.td`

`.td` è già l'estensione di **LLVM TableGen**. Linguist assegna l'estensione a un solo
linguaggio (o usa heuristics); usare `.td` per Triad renderebbe il riconoscimento ambiguo.
`.triad` è libera e univoca. Il kernel accetta comunque `.td` come alias storico per non
rompere i file esistenti.

## Nel frattempo (prima della PR)

- In questo repository `.gitattributes` forza `linguist-language=Triad` per `*.triad` e
  `*.td`; GitHub lo rispetta solo quando "Triad" è noto a Linguist, ma è pronto per dopo.
- Per un riconoscimento immediato in un repository utente si può usare il campo
  `linguist-language` con un linguaggio noto, ma è un workaround: la strada corretta è la PR.

## Passi per la PR

1. fork di `github-linguist/linguist`;
2. aggiungere la voce (con `language_id` libero) e i campioni;
3. aggiungere la grammatica secondo le istruzioni di Linguist (vendor/grammars o grammar
   upstream puntata dalla voce);
4. `bundle exec rake` / test di Linguist;
5. aprire la PR spiegando che Triad è un linguaggio autonomo con specifica e suite di
   conformità (link a `SPEC.md` e `conformance/`).
