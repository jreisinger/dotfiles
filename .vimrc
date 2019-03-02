"https://raw.githubusercontent.com/thoughtstream/Damian-Conway-s-Vim-Setup/master/.vimrc

"====[ Plugins and templates ]=================================================

" activate pathogen.vim
call pathogen#infect()

" NERDTree
nnoremap <F4> :NERDTreeToggle<CR>
nnoremap <t> :NERDTreeMapOpenInTab<CR>
set encoding=utf-8 " MacBook fix

" open BufExplorer
nnoremap <F5> :BufExplorer<CR>

" make templates work
autocmd BufNewFile * silent! 0r ~/.vim/templates/%:e.template

"====[ Basics ]===============================================================

syntax on                       " syntax highlighting
filetype on                     " try to detect filetypes
filetype plugin indent on       " enable loading indent file for filetype
filetype plugin on              " enable templates

set ic  " ignore case during search
"set cursorline

" Spaces instead of tabs (looks the same in all editors) ...
set expandtab       " insert space(s) when tab key is pressed
set tabstop=4       " number of spaces inserted
set shiftwidth=4    " number of spaces for indentation
" more: http://vim.wikia.com/wiki/Converting_tabs_to_spaces

" statusline
set statusline=%F%m%r%h%w[%L][%{&ff}]%y[%p%%][%04l,%04v]
"              | | | | |  |   |      |  |     |    |
"              | | | | |  |   |      |  |     |    + current
"              | | | | |  |   |      |  |     |       column
"              | | | | |  |   |      |  |     +-- current line
"              | | | | |  |   |      |  +-- current % into file
"              | | | | |  |   |      +-- current syntax in
"              | | | | |  |   |          square brackets
"              | | | | |  |   +-- current fileformat
"              | | | | |  +-- number of lines
"              | | | | +-- preview flag in square brackets
"              | | | +-- help flag in square brackets
"              | | +-- readonly flag in square brackets
"              | +-- rodified flag in square brackets
"              +-- full path to file in the buffer
set laststatus=2

set textwidth=79
set nu          " show line numbers
"set relativenumber
"colors delek    " colorscheme
set showmatch   " show matching brackets

" don't bell or blink
set noerrorbells
set vb t_vb=

" paste/nopaste (inluding don't show/show numbers)
nnoremap <F2> :set nu! invpaste paste?<CR>
set pastetoggle=<F2>
set showmode

" folding
set nofoldenable " disable by default
set foldmethod=manual
inoremap <F9> <C-O>za
nnoremap <F9> za
onoremap <F9> <C-C>za
vnoremap <F9> zf
autocmd BufWinLeave *.* mkview          "save folds
autocmd BufWinEnter *.* silent loadview "load folds

" Enable spell checking
"set spell

"====[ Toggle visibility of naughty characters ]==============================

" Make naughty characters visible...
" (uBB is right double angle, uB7 is middle dot)
set lcs=tab:»·,trail:␣,nbsp:˷
"highlight InvisibleSpaces ctermfg=Black ctermbg=Black
"call matchadd('InvisibleSpaces', '\S\@<=\s\+\%#\ze\s*$', -10)

augroup VisibleNaughtiness
    autocmd!
    autocmd BufEnter  *       set list
    autocmd BufEnter  *.txt   set nolist
    autocmd BufEnter  *.vp*   set nolist
    autocmd BufEnter  *.go    set nolist
    autocmd BufEnter  *       if !&modifiable
    autocmd BufEnter  *           set nolist
    autocmd BufEnter  *       endif
augroup END

"====[ Python stuff ]==========================================================

" Python completion (Ctrl-O-X). Needs: vim >= 7.0, vim-nox.
" Problematic on cygwin.
set ofu=syntaxcomplete#Complete

"====[ Golang stuff ]==========================================================
"imap errh if err != nil {<CR>fmt.Fprintf(os.Stderr, "%v\n", err)<CR>os.Exit(1)<CR>}

"====[ Perl stuff ]============================================================

" syntax color complex things like @{${"foo"}}
let perl_extended_vars = 1

"
" START Tidy Perl file
"

" Tidy selected lines (or entire file) with _t:
"nnoremap <silent> _t :%!perltidy -q<Enter>
"vnoremap <silent> _t :!perltidy -q<Enter>

"define :Tidy command to run perltidy on visual selection || entire buffer"
command -range=% -nargs=* Tidy <line1>,<line2>!perltidy

"run :Tidy on entire buffer and return cursor to (approximate) original position"
fun DoTidy()
    let l = line(".")
    let c = col(".")
    :Tidy
    call cursor(l, c)
endfun

"shortcut for normal mode to run on entire buffer then return to current line"
au Filetype perl nmap _t :call DoTidy()<CR>

"shortcut for visual mode to run on the the current visual selection"
au Filetype perl vmap _t :Tidy<CR>

"
" STOP Tidy Perl file
"

" insert Perl variable dumping stuff
imap <F8> use Data::Dumper;<CR>print Dumper 

" insert Perl script boiler plate
imap <F3> #!/usr/bin/perl<CR>use strict;<CR>use warnings;<CR>

" Check syntax: \l
command PerlLint !perl -c %
nnoremap <leader>l :PerlLint<CR>
" Fix errors: :w => :make => :copen => :cn | :cp
set makeprg=perl\ -c\ -MVi::QuickFix\ %
set errorformat+=%m\ at\ %f\ line\ %l\.
set errorformat+=%m\ at\ %f\ line\ %l

"=====[ Show help files in a new tab, plus add a shortcut for helpg ]==========

let g:help_in_tabs = 1

nmap <silent> H  :let g:help_in_tabs = !g:help_in_tabs<CR>

"Only apply to .txt files...
augroup HelpInTabs
    autocmd!
    autocmd BufEnter  *.txt   call HelpInNewTab()
augroup END

"Only apply to help files...
function! HelpInNewTab ()
    if &buftype == 'help' && g:help_in_tabs
        "Convert the help window to a tab...
        execute "normal \<C-W>T"
    endif
endfunction

"Simulate a regular cmap, but only if the expansion starts at column 1...
function! CommandExpandAtCol1 (from, to)
    if strlen(getcmdline()) || getcmdtype() != ':'
        return a:from
    else
        return a:to
    endif
endfunction

"Expand hh -> helpg...
cmap <expr> hh CommandExpandAtCol1('hh','helpg ')

"====[ Move through search results of ]========================================
"
" :helpgrep PATTERN
" :vimgrep /PATTERN/ FILES...
nmap <silent> <RIGHT>           :cnext<CR>
nmap <silent> <RIGHT><RIGHT>    :cnfile<CR><C-G>
nmap <silent> <LEFT>            :cprev<CR>
nmap <silent> <LEFT><LEFT>      :cpfile<CR><C-G>
