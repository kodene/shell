set nocompatible

if filereadable(expand("~/.vimrc.plugins"))
    source ~/.vimrc.plugins
endif

" General Settings {{{
    syntax enable
    if has("termguicolors")
        " set t_8f=[38;2;%lu;%lu;%lum
        " set t_8b=[48;2;%lu;%lu;%lum
        set termguicolors
    else
        set t_Co=256
    endif
    set background=dark
    colorscheme two-firewatch

    set t_ut=

    set history=1000
    let python_highlight_all=1

    let mapleader=","

    if has('multibyte')
        scriptencoding utf-8
    endif

    if has('autoselectplus')
        set clipboard+=autoselectplus
    endif

    set fileformat=unix
    set autowrite " Save file when leaving a modified buffer
    set autoread  " Force RO if file is updated by someone else
    set shortmess+=filmnrxoOtT " Message abbreviations (avoids 'hit enter')
    set viewoptions=cursor,folds,slash,unix

    " http://vim.wikia.com/wiki/Always_start_on_first_line_of_git_commit_message
    " Force cursor to top for git commit
    au FileType gitcommit au! BufEnter COMMIT_EDITMSG call setpos('.', [0, 1, 1, 0])

    " Prevent swap files
    set noswapfile

    " Create backups, but consolidate them
    if !isdirectory($HOME . '/.vim/backup')
        silent call mkdir($HOME . '/.vim/backup', 'p')
    endif
    set backupdir=~/.vim/backup
    set backup

    " Create undo files, but consolidate them
    if exists('+undofile')
        if !isdirectory($HOME . '/.vim/undo')
            silent call mkdir($HOME . '/.vim/undo', 'p')
        endif
        set undodir=~/.vim/undo/
        set undofile
    endif

    set number    " Display line numbers
    " Toggle line numbers
    nmap <F11> :set invnumber<CR>

    set scrolloff=10 " Visible lines around cursor for vertical scrolling
    set cursorline " Highlight the current line
    set cursorcolumn
    set colorcolumn=80,120
    set showcmd   " Show partial commands at bottom
    set noshowmode  " Display current mode (enables for vi)
    set backspace=indent,eol,start

    set ruler
    set laststatus=2
    set wildmode=list:longest " cmdline tab completion similar to bash
    set wildmenu  " Enable ctlr-n and ctrl-p to scroll through matches

    set ignorecase " Ignore case when searching...
    set smartcase  " ...except when using capital letters
    set hlsearch  " Highlight all searched text
    set incsearch " Find matches while typing
    set cindent
    set matchtime=3

    set ttimeout
    set ttimeoutlen=50
    set vb t_vb=

    " Edit options
    set pastetoggle=<F10>
    set wrap      " Enable wrapping of line lines
    set shiftwidth=4 " Indents are 4 spaces
    set softtabstop=4 " Backspace will erase an indent
    set expandtab " Convert a tab to spaces
    set autoindent " Keep indent level on new lines
    set splitright " vsplit window is placed to the right
    set splitbelow " split window is placed below
    set viminfo='100,s10,%,n~/.viminfo

    " Diff settings
    set diffopt=filler
    set diffopt+=context:4
    set diffopt+=iwhite
    set diffopt+=vertical

    if has('folding')
        set foldenable
        set foldmethod=indent
        let g:SimplyFold_docstring_preview=1
        nnoremap <space> za
    endif

    " Perl support
    autocmd BufRead,BufNewFile *.t set filetype=perl
    " Disable auto comment insertion on next line
    autocmd FileType * setlocal formatoptions-=cro
" }}}

" Mappings {{{
    map <space> /
    " Move among wrapped lines
    map j gj
    map k gk
    " Make Q useful. Copy lines to end of previous or next line (Qj or Qk)
    map Q gq
    " Clear highlights
    nnoremap <ESC><ESC> :nohls<CR>
    " Toggle wrap mode.
    nmap <F12> :set wrap!<CR>

    " Navigate tabs
    nnoremap <F7> :tabp<CR>
    nnoremap <F8> :tabn<CR>

    " Navigate windows
    map <C-J> <C-W>j
    map <C-K> <C-W>k
    map <C-L> <C-W>l
    map <C-H> <C-W>h

    " Navigate help
    nnoremap <S-F1> :cc<CR>
    nnoremap <F2> :cnext<CR>
    nnoremap <S-F2> :cprev<CR>
    nnoremap <F3> :cnfile<CR>
    nnoremap <S-F3> :cpfile<CR>
    nnoremap <F4> :cfirst<CR>
    nnoremap <S-F4> :clast<CR>

    " Splitting
    nnoremap <leader>v <C-w>v<C-w>l
    nnoremap <leader>s <C-w>s
" }}}

" Restore Support {{{
" http://vim.wikia.com/wiki/Restore_cursor_to_file_position_in_previous_editing_session
" Restore cursor position, with support for fold level restore
" function! ResCur()
"     if line("'\"") <= line("$")
"         normal! g`"
"         return 1
"     endif
" endfunction
"
" augroup resCur
"     autocmd!
"     if has("folding")
"         autocmd BufWinEnter * if ResCur() | call UnfoldCur() | endif
"     else
"         autocmd BufWinEnter * call ResCur()
"     endif
" augroup END
"
" if has("folding")
"     function! UnfoldCur()
"         if !&foldenable
"             return
"         endif
"         let cl = line(".")
"         if cl <= 1
"             return
"         endif
"         let cf = foldlevel(cl)
"         let uf = foldlevel(cl - 1)
"         let min = (cf > uf ? uf : cf)
"         if min
"             execute "normal!" min . "zo"
"             return 1
"         endif
"     endfunction
" endif
" }}}

" Additional Functionality {{{
    " Trailing whitespace {{{
    match ErrorMsg '\s\+$'
    function! TrimWhiteSpace()
        %s/\s\+$//e
    endfunction
    nnoremap <silent> <Leader>tws :call TrimWhiteSpace()<CR>
    autocmd FileWritePre    * :call TrimWhiteSpace()
    autocmd FileAppendPre   * :call TrimWhiteSpace()
    autocmd FilterWritePre  * :call TrimWhiteSpace()
    autocmd BufWritePre     * :call TrimWhiteSpace()
    " }}}
" }}}


" vim: fdm=marker
