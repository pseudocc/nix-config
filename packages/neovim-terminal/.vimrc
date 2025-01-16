set laststatus=0
set noshowmode
set noruler
set noshowcmd
tnoremap <C-Esc> <C-\><C-n>
vnoremap c "+y
vnoremap C "*y
autocmd TermOpen term://* startinsert
autocmd TermClose term://* q
highlight Normal guibg=NONE
highlight TermCursor guifg=#$CURSOR_FG guibg=#$CURSOR_BG
highlight TermCursorNC guifg=#$INACTIVE_CURSOR_FG guibg=#$INACTIVE_CURSOR_BG
