" enable filetype guessing
filetype on
filetype plugin on

colorscheme solarized
if has('gui_running')
    set background=dark
else
    set background=dark
endif

" do syntax coloring from start
syntax enable
autocmd BufEnter * :syntax sync fromstart

let mapleader=","       " set <leader> to ,
let maplocalleader="\\" " set <localleader> to \

set viminfo+=!          " support for yanking
set mouse=a             " enable mouse

set nocompatible        " no vi compatibility

set novisualbell        " no visual beeping
set noerrorbells        " no noise

set tabstop=4           " 1 tab = 4 spaces
set shiftwidth=4
set softtabstop=4
set expandtab           " tab --> spaces
set autoindent          " indent when starting new line
set smartindent         " smart indent when starting new line
" don't mess up the hashes, e.g. in perl comments
inoremap # X#

set number              " show line numbers
set ruler               " show line,col numbers
set showmatch           " highlight matching braces
set nowrap              " don't wrap lines
set incsearch           " show matches from search immediately
set hlsearch            " actually do show any matches at all

set foldenable          " do fold
set foldmethod=marker   " fold with markers

set wildmenu            " show completion menu in :e with <C-d>

" disable file browser help
let g:explDetailedHelp=0


""""""""" Fixing file recognition and indentation
autocmd FileType ruby setlocal expandtab shiftwidth=2 tabstop=2 softtabstop=2
autocmd FileType sass setlocal expandtab shiftwidth=2 tabstop=2 softtabstop=2
autocmd FileType haml setlocal expandtab shiftwidth=2 tabstop=2 softtabstop=2
autocmd FileType plaintex set filetype=tex
autocmd FileType tex map <f5> :!make<cr><cr>
autocmd FileType uzbl map <f5> :!uzbl-tabbed<cr><cr>
autocmd BufEnter *.zsh* set filetype=zsh
autocmd FileType gitcommit call setpos('.', [0, 1, 1, 0])


""""""""" GUI only """""""""""""""""""""""
set guioptions-=T       " disable toolbar
set gcr=a:blinkon0      " disable blinking


""""""""" Show superfluos spaces """""""""
:highlight ExtraWhitespace ctermbg=darkred guibg=darkred
:autocmd Syntax * syn match ExtraWhitespace /\s\+$\| \+\ze\t/ containedin=ALL


""""""""" F1 = ESC """""""""""""""""""""""
imap <F1> <ESC>
nmap <F1> <ESC>
vmap <F1> <ESC>


""""""""" F2 for paste toggle """"""""""""
nnoremap <F2> :set invpaste paste?<CR>
imap <F2> <C-O><F2>i
set pastetoggle=<F2>


""""""""" F3 for shiftwidth toggle """""""
nnoremap <expr> <F3> (&sw =~ "4$") ? ":set shiftwidth=2<cr>:set tabstop=2<cr>:set softtabstop=2<cr>" : ":set shiftwidth=4<cr>:set tabstop=4<cr>:set softtabstop=4<cr>"
inoremap <expr> <F3> (&sw =~ "4$") ? "<c-o>:set shiftwidth=2<cr><c-o>:set tabstop=2<cr><c-o>:set softtabstop=2<cr>" : "<c-o>:set shiftwidth=4<cr><c-o>:set tabstop=4<cr><c-o>:set softtabstop=4<cr>"


"""""""""" autocompletion """""""""""""""""
" don't auto-insert first item, show menu even with only one entry
set completeopt=longest,menuone
" make completion a bit nicer
inoremap <expr> <space> pumvisible() ? "\<lt>c-y> " : "\<lt>space>"
inoremap <expr> . pumvisible() ? "\<lt>c-y>." : "."
inoremap <expr> : pumvisible() ? "\<lt>c-y>:" : ":"
inoremap <expr> , pumvisible() ? "\<lt>c-y>," : ","
inoremap <expr> ( pumvisible() ? "\<lt>c-y>(" : "("
inoremap <expr> [ pumvisible() ? "\<lt>c-y>[" : "["
"inoremap <expr> <tab> pumvisible() ? "\<lt>c-y>" : "\<lt>tab>"
" starts autocompletion or does nothing
function InsertCompleteWrapper()
    let col = col('.') - 1
    if !col || getline('.')[col - 1] !~ '\k'
        return ""
    else
        return "\<c-n>\<down>"
    endif
endfunction
" make <c-SPACE> the autocomplete key
inoremap <expr> <Nul> pumvisible() ? "\<c-e>" : "\<c-g>u<c-r>=InsertCompleteWrapper()<cr>"


""""""""" snippets """""""""""""""""""""""
" set snippets dir to local path
let g:snippets_dir = "~/.vim/snippets"


""""""""" tn = :tabnew """""""""""""""""""
nmap tn :tabnew<CR>


""""""""" ü = :shell """""""""""""""""""""
nmap ü :shell<cr>


""""""""" buffer magic """""""""""""""""""
nmap bn :bn!<cr>
nmap bp :bp!<cr>
nmap bd :bd<cr>


""""""""" Y,ä = y/p in clipboard """""""""
nmap Y "+y
vmap Y "+y
nmap ä "+gP
vmap ä "+gP


""""""""" gp = select pasted text """"""""
nnoremap gp `[v`]


""""""""" surroundings """""""""""""""""""
" needs surround extension: http://www.vim.org/scripts/script.php?script_id=1697
let g:surround_100 = "do \r end"              " d
let g:surround_68 = "do\n\t\r\nend"           " D
let g:surround_119 = "%w{\r}"                 " w
let g:surround_113 = "%q{\r}"                 " q
let g:surround_120 = "%x{\r}"                 " x
let g:surround_114 = "%r{\r}"                 " r
let g:surround_47 = "/\r/"                    " /
let g:surround_35 = "#{\r}"                   " #
let g:surround_37 = "<% \r %>"                " %
let g:surround_53 = "<%\n\t\r\n%>"            " 5
let g:surround_96  = "`\r'"                   " `


""""""""" switch to other ext """"""""""""
" needs FSwitch extension: http://www.vim.org/scripts/script.php?script_id=2590
nmap <F4> :FSHere<cr>
autocmd FileType lua let b:fswitchdst = 'lua'
autocmd FileType lua let b:fswitchlocs = 'reg:/src/test/,reg:/test/src/'


""""""""" Eclipse-like autoindent whole file """""""""""""""""
nmap <c-f> ggVG==


""""""""" XML Beautifier """""""""""""""""
" needs xmllint installed
function! DoPrettyXML()
    " save the filetype so we can restore it later
    let l:origft = &ft
    set ft=
    " delete the xml header if it exists. This will
    " permit us to surround the document with fake tags
    " without creating invalid xml.
    1s/<?xml .*?>//e
    " insert fake tags around the entire document.
    " This will permit us to pretty-format excerpts of
    " XML that may contain multiple top-level elements.
    0put ='<PrettyXML>'
    $put ='</PrettyXML>'
    silent %!xmllint --format -
    " xmllint will insert an <?xml?> header. it's easy enough to delete
    " if you don't want it.
    " delete the fake tags
    2d
    $d
    " restore the 'normal' indentation, which is one extra level
    " too deep due to the extra tags we wrapped around the document.
    silent %<
    " back to home
    1
    " restore the filetype
    exe "set ft=" . l:origft
endfunction
command! XMLFormat call DoPrettyXML()

""""""""" Fix HTML umlauts """""""""""""""
function! DoReplaceUmlauts()
    if search ("ä") | :1,$s/ä/\&auml;/g | endif
    if search ("Ä") | :1,$s/Ä/\&Auml;/g | endif
    if search ("ö") | :1,$s/ö/\&ouml;/g | endif
    if search ("Ö") | :1,$s/Ö/\&Ouml;/g | endif
    if search ("ü") | :1,$s/ü/\&uuml;/g | endif
    if search ("Ü") | :1,$s/Ü/\&Uuml;/g | endif
    if search ("ß") | :1,$s/ß/\&szlig;/g | endif
endfunction
command! ReplaceUmlauts call DoReplaceUmlauts()


""""""""" Fix Numpad """""""""""""""""""""
imap <ESC>Ol ,
imap <ESC>Op 0
imap <ESC>Oq 1
imap <ESC>Or 2
imap <ESC>Os 3
imap <ESC>Ot 4
imap <ESC>Ou 5
imap <ESC>Ov 6
imap <ESC>Ow 7
imap <ESC>Ox 8
imap <ESC>Oy 9

" tab navigation like firefox
:nmap <C-S-tab> :tabprevious<CR>
:nmap <C-tab> :tabnext<CR>
:map <C-S-tab> :tabprevious<CR>
:map <C-tab> :tabnext<CR>
:imap <C-S-tab> <Esc>:tabprevious<CR>i
:imap <C-tab> <Esc>:tabnext<CR>i
:nmap <C-t> :tabnew<CR>
:imap <C-t> <Esc>:tabnew<CR>
