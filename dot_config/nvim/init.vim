set nocompatible

let plug_dir = has('nvim') ? stdpath('data') . '/site' : '~/.config/vim'
let plug_init = empty(glob(plug_dir . '/autoload/plug.vim'))
if plug_init
	let plug_url = 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
	silent execute '!curl -fLo '.plug_dir.'/autoload/plug.vim --create-dirs '.plug_url
	autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin(plug_dir.'/plugged')
	Plug 'AndrewRadev/linediff.vim'
	Plug 'jeetsukumaran/vim-indentwise'
	Plug 'junegunn/vim-easy-align'
	Plug 'luochen1990/rainbow'
	Plug 'mbbill/undotree'
	Plug 'preservim/nerdcommenter'
	Plug 'rhlobo/vim-super-retab'
	Plug 'salsifis/vim-transpose'
	Plug 'tpope/vim-abolish'
	Plug 'tpope/vim-fugitive'
	Plug 'tpope/vim-repeat'
	Plug 'tpope/vim-sleuth'
	Plug 'tpope/vim-surround'
	Plug 'tpope/vim-unimpaired'
	Plug 'vim-scripts/Improved-AnsiEsc'
	Plug 'mingmingrr/vim-paragraph-motion'

	Plug 'sainnhe/sonokai'
	Plug 'morhetz/gruvbox'
	Plug 'louispan/vim-monokai-black'

	Plug 'sheerun/vim-polyglot'
	Plug 'KSP-KOS/EditorTools'
	Plug 'andy-morris/alex.vim'
	Plug 'andy-morris/happy.vim'
	Plug 'cybardev/cython.vim'
	Plug 'dmix/elvish.vim'
	Plug 'justin2004/vim-apl'
	Plug 'meatballs/vim-xonsh'
	Plug 'direnv/direnv.vim'

	if has('nvim')
		Plug 'nvim-treesitter/nvim-treesitter'
		Plug 'lukas-reineke/indent-blankline.nvim'
		Plug 'neoclide/coc.nvim', {'branch': 'release'}
	endif
call plug#end()

syntax on
filetype plugin on
filetype indent off
set background=dark

let g:sonokai_enable_italic = 1
for scheme in ['onekai', 'blep', 'sonokai', 'monokai-black', 'monokai', 'molokai']
	try | execute 'colorscheme' scheme | break | catch | endtry
endfor
highlight Normal guibg=NONE ctermbg=NONE
highlight NormalNC guibg=NONE ctermbg=NONE
" highlight IndentGuidesOdd  ctermfg=59 ctermbg=234
" highlight IndentGuidesEven ctermfg=59 ctermbg=0

set fileencoding=utf-8
set fileencodings=ucs-bom,utf-8,gbk,cp936,latin-1
set fileformat=unix
set fileformats=unix,dos,mac

set nowrap
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
set foldopen-=search
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

let g:haskell_conceal = 0
let g:haskell_quasi = 0
let g:haskell_interpolation = 0
let g:haskell_regex = 0
let g:haskell_jmacro = 0
let g:haskell_shqq = 0
let g:haskell_sql = 0
let g:haskell_json = 0
let g:haskell_xml = 0
let g:haskell_hsp = 0
let g:haskell_tabular = 0

let g:syntastic_auto_loc_list        = 0
let g:syntastic_python_python_exec = 'python3'
let g:syntastic_cpp_compiler_options = ' -std=c++20'
let g:syntastic_mode_map = {
	\ 'mode': 'active',
	\ 'passive_filetypes': [ 'c', 'cpp' ] }
let g:syntastic_python_checkers = []

let g:rainbow_active = 1

let g:paragraphmotion_keepjumps = 1
let g:paragraphmotion_skipfolds = 1

map <F1> <nop>
map <F9> :Vista!!<CR>
map <F10> :echo 'hi<' . synIDattr(synID(line('.'),col('.'),1),'name')
\ . '> trans<' . synIDattr(synID(line('.'),col('.'),0),'name') . '> lo<'
\ . synIDattr(synIDtrans(synID(line('.'),col('.'),1)),'name') . '>'<CR>

xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)

nmap gD :call CocActionAsync('jumpDefinition', 'drop')<CR>
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

if has('nvim')
lua << EOF
	local highlight = {
		"Whitespace",
		"CursorColumn",
	}
	require("ibl").setup {
		indent = {
			highlight = highlight,
			char = "",
		},
		whitespace = {
			highlight = highlight,
			remove_blankline_trail = false,
		},
		scope = { enabled = false },
	}
EOF
endif
