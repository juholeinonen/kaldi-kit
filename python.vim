nnoremap <buffer> H :<C-u>execute "!pydoc3 " . expand("<cword>")<CR>

set tabstop=4
set softtabstop=4
set shiftwidth=4
set textwidth=79
set expandtab
set autoindent
set fileformat=unix
set encoding=utf-8
let python_highlight_all=1
syntax on
