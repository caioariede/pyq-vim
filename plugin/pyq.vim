" -----------------------------------------------------------------------------
" functions
" -----------------------------------------------------------------------------
function! PyqFn(sel)
    let pyqbufname = '__Pyq_Result__'
    let g:pyqoldbufnumber = bufnr('%')

    " check if it's not being called in pyq window
    if bufname('%') == pyqbufname
        return
    endif

    " call external command
    let output = system("pyq2 -e " . shellescape(a:sel) . " " . bufname("%"))

    " check if buffer is already open
    let g:pyqbufnumber = bufwinnr(pyqbufname)

    if g:pyqbufnumber > -1
        " switch to opened buffer
        exec 'exec ' . g:pyqbufnumber . ' "wincmd w"'
    else
        exec 'split ' . pyqbufname

        " remove everything in the buffer
        normal! ggdG

        " save buffer name
        let g:pyqbufnumber = bufwinnr(pyqbufname)

        " makes this a temporary buffer
        setlocal buftype=nofile
        setlocal bufhidden=hide
        setlocal noswapfile

        " set filetype to python
        setlocal ft=python

        " resize window
        exec 'resize '. winheight(0)/2

        " add mappings to this buffer
        nnoremap <buffer> <Enter> :call PyqFnGoto(line('.'))<CR>
    endif

    " create a mapping between output and result lines and columns to be
    " accessed in PyqFnGoto function
    let outputl = split(output, '\v\n')
    let g:pyqmapping = []

    for line in outputl
        let linel = split(line, ':')
        let ln = linel[1]
        let col = split(linel[2], ' ')[0]
        let g:pyqmapping = add(g:pyqmapping, [ln, col])
    endfor

    " add content to buffer starting at first line
    call append(0, outputl)

    " go to first line
    normal! gg
endfunction


function! PyqFnGoto(slnum)
    " find the proper mapping for this slnum and go to the line and column
    if exists('g:pyqmapping[a:slnum-1]')
        " switch to old buffer
        exec 'exec ' . g:pyqoldbufnumber . ' "wincmd w"'

        " place cursor at position
        let res = g:pyqmapping[a:slnum-1]
        call cursor(res[0], res[1]+1)

        " align top
        normal! zt

        " go back to pyq window
        exec 'exec ' . g:pyqbufnumber .  ' "wincmd w"'
    endif
endfunction


" -----------------------------------------------------------------------------
" commands
" -----------------------------------------------------------------------------
command -nargs=1 Pyq call PyqFn(<f-args>)
