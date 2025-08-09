if exists('g:plugin_rc_loaded')
	finish
end
let g:plugin_rc_loaded = 1

set nocompatible

filetype on
filetype plugin on
filetype indent off

syntax on
set background=dark

let g:sonokai_enable_italic = 1

for scheme in ['onekai', 'blep', 'sonokai', 'monokai-black', 'monokai', 'molokai']
	try
		execute 'colorscheme' scheme
		break
	catch
	endtry
endfor

highlight Normal guibg=NONE ctermbg=NONE
" highlight IndentGuidesOdd  ctermfg=59 ctermbg=234
" highlight IndentGuidesEven ctermfg=59 ctermbg=0

set fileencoding=utf-8
set fileencodings=ucs-bom,utf-8,gbk,cp936,latin-1
set fileformat=unix
set fileformats=unix,dos,mac

set wrap
" set linebreak
" set textwidth=500
set scrolloff=3
set sidescrolloff=6
" let &previewheight=winheight(0)/2

set autoindent
set nocindent
set nosmartindent
set smarttab
set noexpandtab
set tabstop=2
set shiftwidth=0
set softtabstop=0

set wildmenu
set wildmode=longest,full
set wildignorecase

set showmatch
set ignorecase
set infercase
set smartcase
set incsearch
set hlsearch
set magic

set number
set relativenumber
set ruler

set cursorline
set modeline
set colorcolumn=80
" set textwidth=79
set synmaxcol=2000

set laststatus=2
set showcmd
set list
set listchars=tab:·\ ,extends:›,precedes:‹,nbsp:·,trail:·

set mouse=a
set backspace=indent,eol,start
set virtualedit=block
set clipboard=unnamedplus
set completeopt=menuone,preview,noselect,noinsert
set autoread

set directory^=$HOME/.local/share/vimswap
set swapfile
set nobackup
set nowritebackup

set lazyredraw
set noerrorbells
set novisualbell
set timeoutlen=500

set foldopen-=block
set foldmethod=indent
set foldlevelstart=20

set signcolumn=yes

set diffopt+=iwhite

set shell=/bin/sh

autocmd FileType haskell setlocal expandtab
autocmd FileType cabal setlocal expandtab
autocmd FileType purescript setlocal expandtab
autocmd FileType python setlocal noexpandtab tabstop=2 shiftwidth=2
autocmd Filetype alex syntax include @haskell syntax/haskell.vim |
	\ syntax region haskellSnip matchgroup=Snip start='^{$' end='^}$' contains=@haskell
autocmd Filetype happy syntax include @haskell syntax/haskell.vim |
	\ syntax region haskellSnip matchgroup=Snip start='^{$' end='^}$' contains=@haskell
autocmd Filetype happy syntax include @haskell syntax/haskell.vim |
	\ syntax region haskellSnip matchgroup=Snip start='{% ' end='}$' contains=@haskell
autocmd FileType pug setlocal nowrap
autocmd FileType qf setlocal nowrap |
	\ nnoremap <buffer> <Enter> <Enter><C-W><C-P>

set indentexpr=
autocmd BufEnter * set indentexpr=

for [pattern, file_type] in items({
	\ '.clangd' : 'yaml',
	\ '.envrc'  : 'bash',
	\ '*.vhdo'  : 'vhdl',
	\ '*.v'     : 'verilog',
	\ '*.vlog'  : 'verilog',
	\ '*.sv'    : 'systemverilog',
	\ '*.do'    : 'tcl'
\ })
	execute 'autocmd' 'BufNewFile,BufRead' pattern
		\ 'setlocal' 'filetype=' . file_type
endfor

let g:NERDSpaceDelims = 1
let g:NERDCustomDelimiters = {
	\ 'c' : { 'left': '//', 'leftAlt': '/*', 'rightAlt': '*/' },
	\ 'python' : { 'left': '#' },
	\ 'xdc' : { 'left': '#' },
	\ 'kerboscript' : { 'left': '//' },
	\ 'cosini' : { 'left': '#' },
\ }

" let g:deoplete#enable_at_startup = 1
" autocmd CompleteDone * if pumvisible() == 0 | pclose | endif

let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_auto_colors = 0

let g:haskell_enable_quantification = 1
let g:haskell_enable_recursivedo = 1
let g:haskell_enable_arrowsyntax = 1
let g:haskell_enable_pattern_synonyms = 1
let g:haskell_enable_typeroles = 1
let g:haskell_enable_static_pointers = 1
let g:haskell_backpack = 1
let g:haskell_indent_disable = 1
let g:haskell_disable_TH = 1

let g:haskell_conceal       = 0
let g:haskell_quasi         = 0
let g:haskell_interpolation = 0
let g:haskell_regex         = 0
let g:haskell_jmacro        = 0
let g:haskell_shqq          = 0
let g:haskell_sql           = 0
let g:haskell_json          = 0
let g:haskell_xml           = 0
let g:haskell_hsp           = 0
let g:haskell_tabular       = 0

let g:syntastic_auto_loc_list        = 0
let g:syntastic_python_python_exec = 'python3'
let g:syntastic_cpp_compiler_options = ' -std=c++20'
let g:syntastic_mode_map = {
	\ 'mode': 'active',
	\ 'passive_filetypes': [ 'c', 'cpp' ] }
let g:syntastic_python_checkers = []

let g:rainbow_active = 1

nnoremap <silent> } :<C-u>execute "keepjumps norm! " . v:count1 . "}"<CR>
nnoremap <silent> { :<C-u>execute "keepjumps norm! " . v:count1 . "{"<CR>

map <F1> <nop>
map <F9> :Vista!!<CR>
map <F10> :echo 'hi<' . synIDattr(synID(line('.'),col('.'),1),'name')
\ . '> trans<' . synIDattr(synID(line('.'),col('.'),0),'name') . '> lo<'
\ . synIDattr(synIDtrans(synID(line('.'),col('.'),1)),'name') . '>'<CR>

xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)

nmap gD :call CocActionAsync('jumpDefinition')<CR>
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

nnoremap <silent> K :call ShowDocumentation()<CR>
function! ShowDocumentation()
	if CocAction('hasProvider', 'hover')
		call CocActionAsync('doHover')
	else
		call feedkeys('K', 'in')
	endif
endfunction

cnoremap <C-A> <Home>
cnoremap w!! execute 'silent! write !sudo tee % >/dev/null' <bar> edit!

try
	luafile rc.lua
catch
endtry

