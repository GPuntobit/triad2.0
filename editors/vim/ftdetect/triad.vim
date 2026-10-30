" Vim/Neovim: Filetype detection for Triad.
" .triad is the canonical extension; .td is accepted as a historical alias
" (note: .td is also used by LLVM TableGen).
augroup triad_filetype
  autocmd!
  autocmd BufRead,BufNewFile *.triad,*.td setfiletype triad
augroup END