# Credit on GitHub (Linguist)
GitHub uses `github-linguist/linguist` to decide the language of a file from its extension
and grammar. For Triad to appear as its own language you need:
1. an entry in `lib/linguist/languages.yml` (template in `languages.yml` of this folder);
2. a TextMate grammar with scope `source.triad` (the one in `../vscode/syntaxes/` is already
   valid as a basis);
3. real samples (`samples/Triad/*.triad`) in the PR;
4. a unique `language_id`, assigned by Linguist.
## Why `.triad` and not `.td`
`.td` is already the extension of **LLVM TableGen**. Linguist assigns the extension to only one
language (or use heuristics); using `.td` for Triad would make the recognition ambiguous.
`.triad` is free and unique. The kernel still accepts `.td` as a historical alias for non
break existing files.
## Meanwhile (before PR)
- In this repository `.gitattributes` forces `linguist-language=Triad` for `*.triad` and
  `*.td`; GitHub only respects this when "Triad" is known to Linguist, but is ready for later.
- For immediate recognition in a user repository you can use the field
  `linguist-language` with a known language, but it's a workaround: the correct way is PR.
## Steps for PR
1. fork of `github-linguist/linguist`;
2. add the voice (with free `language_id`) and samples;
3. add the grammar according to the Linguist instructions (vendor/grammars or grammar
   upstream pointed by the voice);
4. `bundle exec rake` / Linguist test;
5. open the PR by explaining that Triad is a self-contained language with specification and suite of
   compliance (links to `SPEC.md` and `conformance/`).