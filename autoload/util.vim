" Utility functions

function! gadamer#util#makeOptions(buftype, bufhidden, ) abort

endfunction

" a:0 = position
" a:1 = height/width
function! gadamer#util#openBuffer(mode, ...) abort
  let l:position = a:0 >= 1 ? a:1 : 'bo'
  let l:size = a:0 >= 2 ? a:2 : 20
  execute l:position l:size 'new'
  call s:setBufferOptions(mode)
endfunction

function! gadamer#util#setBufferOptions(mode) abort
  setlocal bufhidden=delete
  setlocal noswapfile
  execute 'setlocal' mode
  setlocal cursorline
  setlocal nolist
  setlocal nospell
endfunction
