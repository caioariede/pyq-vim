" -----------------------------------------------------------------------------
" functions
" -----------------------------------------------------------------------------
function! PyqFn(sel)
    let pyqbufname = '__Pyq_Result__'

    if bufname('%') == pyqbufname
        return
    endif
        
    let output = system("pyq2 -e " . shellescape(a:sel) . " " . bufname("%"))

    let buffer = bufwinnr(pyqbufname)
    if buffer == -1
        exec 'split ' . pyqbufname
    else
        exec 'exec ' . buffer . ' "wincmd w"'
    endif

    normal! ggdG
    call append(0, split(output, '\v\n'))
    normal! gg
endfunction


" -----------------------------------------------------------------------------
" commands
" -----------------------------------------------------------------------------
command -nargs=1 Pyq call PyqFn(<f-args>)
