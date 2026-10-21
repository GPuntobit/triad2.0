" Vim/Neovim: rilevamento del filetype per Triad.
" .triad è l'estensione canonica; .td è accettata come alias storico
" (attenzione: .td è usata anche da LLVM TableGen).
augroup triad_filetype
  autocmd!
  autocmd BufRead,BufNewFile *.triad,*.td setfiletype triad
augroup END
