"https://raw.githubusercontent.com/thoughtstream/Damian-Conway-s-Vim-Setup/master/.vimrc

"====[ Plugins and templates ]=================================================

" activate pathogen.vim -> not needed since vim8: https://vi.stackexchange.com/questions/9522/what-is-the-vim8-package-feature-and-how-should-i-use-it
"call pathogen#infect()

" NERDTree
nnoremap <F4> :NERDTreeToggle<CR>
nnoremap <t> :NERDTreeMapOpenInTab<CR>
set encoding=utf-8 " MacBook fix

" open BufExplorer
nnoremap <F5> :BufExplorer<CR>

" make templates work
autocmd BufNewFile * silent! 0r ~/.vim/templates/%:e.template

"====[ Basics ]================================================================

syntax on                       " syntax highlighting
filetype on                     " try to detect filetypes
filetype plugin indent on       " enable loading indent file for filetype
filetype plugin on              " enable templates

" Spaces instead of tabs (looks the same in all editors) ...
set expandtab       " insert space(s) when tab key is pressed
set tabstop=4       " number of spaces inserted
set shiftwidth=4    " number of spaces for indentation
" more: http://vim.wikia.com/wiki/Converting_tabs_to_spaces

" Space settings per language
" (https://github.com/zdr1976/dotfiles/blob/master/vim/vimrc#L170)
autocmd Filetype gitcommit setlocal spell textwidth=72
autocmd FileType python setlocal tabstop=4 softtabstop=4 shiftwidth=4 expandtab
autocmd BufNewFile,BufRead go setlocal noexpandtab tabstop=8 shiftwidth=8 softtabstop=8
"autocmd BufRead,BufNewFile */playbooks/*.yml set filetype=ansible
autocmd FileType yaml setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab
autocmd FileType json setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab
autocmd FileType html,htmldjango setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab
autocmd BufNewFile,BufRead *.kubeconfig setlocal filetype=yaml
autocmd FileType c,go,python autocmd BufWritePre <buffer> :%s/\s\+$//e

" Stop vim from messing up my indentation on comments
" https://unix.stackexchange.com/questions/106526/stop-vim-from-messing-up-my-indentation-on-comments
set cinkeys-=0#
set indentkeys-=0#

set textwidth=79
set colorcolumn=80

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

" where to store swap files (*.swp)
" (https://stackoverflow.com/questions/1636297/how-to-change-the-folder-path-for-swp-files-in-vim)
:set directory=$HOME/.vim//

"====[ Search ]================================================================

set ignorecase  " case-insensitive search
set smartcase   " overide ignorecase when search includes uppercase letters

" Use arrow keys to navigate after a :vimgrep or :helpgrep
nmap <silent> <RIGHT>         :cnext<CR>
nmap <silent> <RIGHT><RIGHT>  :cnfile<CR><C-G>
nmap <silent> <LEFT>          :cprev<CR>
nmap <silent> <LEFT><LEFT>    :cpfile<CR><C-G>

"====[ Toggle visibility of naughty characters ]===============================

" Make naughty characters visible...
" (uBB is right double angle, uB7 is middle dot)
set lcs=tab:»·,trail:␣,nbsp:˷
"highlight InvisibleSpaces ctermfg=Black ctermbg=Black
"call matchadd('InvisibleSpaces', '\S\@<=\s\+\%#\ze\s*$', -10)

augroup VisibleNaughtiness
    autocmd!
    autocmd BufEnter  *         set list
    autocmd BufEnter  *.txt     set nolist
    autocmd BufEnter  *.vp*     set nolist
    autocmd BufEnter  *.go      set nolist
    autocmd BufEnter  Makefile  set nolist
    autocmd BufEnter  *         if !&modifiable
    autocmd BufEnter  *             set nolist
    autocmd BufEnter  *         endif
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
