" Gadamer window modes.

let s:modes = {'view': {}, 'edit': {}, 'list': {}}
let s:modes.list.mappings = {'<CR>': 'gadamer#Read(split(getline("."))[1])'}

function! s:setWindowMappings(mode)
  for [key, mapping] in items(s:modes[a:mode].mappings)
    let l:map = 'nnoremap <buffer> <silent> ' . key . ' :call ' . mapping .
    \  '<CR>'
    execute l:map
  endfor
endfunction

" Determines the contents of the buffer, as well as where the window opens.
" Each invocation function takes a list of annotations.
function! s:modes.view.invoke(annotations) 
  for annotations in values(a:annotations)
    execute 'e' annotation.annoFile
  endfor
endfunction

function! s:modes.edit.invoke(annotations)
  "TODO: Make position and size configurable.
  execute 'bo' 20 'new'
  for annotation in values(a:annotations)
    execute 'e' anontation.annoFile
  endfor
endfunction

function! s:modes.list.invoke(annotations)
  "TODO: Make position and size configurable.
  execute 'bo' 20 'new'
  for annotation in values(a:annotations)
    let l:list_item = "line " . annotation.line . ' | ' . annotation.annoFile
    call append(line("$"), l:list_item)
  endfor
endfunction

function! s:modes.view.setOptions() 
  setlocal buftype=file
  setlocal bufhidden=delete
  setlocal noswapfile
  setlocal readonly
endfunction

function! s:modes.edit.setOptions() 
  setlocal buftype=file
  setlocal swapfile
endfunction

function! s:modes.list.setOptions() 
  setlocal buftype=nofile
  setlocal bufhidden=delete
  setlocal cursorline
  setlocal noswapfile
  setlocal readonly 
endfunction

function! s:modes.open(mode, annotations)
  call s:modes[a:mode].invoke(a:annotations)
  call s:modes[a:mode].setOptions()
  call s:setWindowMappings(a:mode)
endfunction

function! gadamer#window#getModes() 
  return s:modes
endfunction

