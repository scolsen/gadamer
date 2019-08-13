" Gadamer window modes.

let s:mode =
  \ {'annotations': [], 'activeAnnotation': {}, 'previousBuffer': 0,
  \  'mappings': {},}

function! s:mode.setPreviousBuffer()
  let self.previousBuffer = bufnr("%")
endfunction

function! s:mode.setWindowMappings()
  for [key, mapping] in items(self.mappings)
    let l:map = 'nnoremap <buffer> <silent> ' . key . ' :call ' . mapping .
      \ '<CR>'
    execute l:map
  endfor
endfunction

let gadamer#window#modes =
  \ {'view': copy(s:mode),
  \  'edit': copy(s:mode),
  \  'list': copy(s:mode),}

let gadamer#window#modes.list.mappings =
  \ {'j': 'g:gadamer#window#modes.list.updateAnnotationOnMove(1)',
  \  'k': 'g:gadamer#window#modes.list.updateAnnotationOnMove(-1)',}
let gadamer#window#modes.view.mappings =
  \ {'q': 'g:gadamer#window#modes.view.close()'}
let gadamer#window#modes.edit.mappings = {}

function! s:defineMappings(mode, mappings)
  for [key, callback] in items(a:mappings)
    let invocation = function(callback, [mode.activeAnnotation, mode.annotations]) 
    
    let g:gadamer#window#modes[a:mode].mappings[key] = invocation
  endfor
endfunction

function! gadamer#window#modes.view.close()
  exe "b" . self.previousBuffer
endfunction

function! gadamer#window#modes.list.updateAnnotationOnMove(modifier)
  let l:current_pos = getpos(".")
  let l:next_line = l:current_pos[1] + a:modifier
  let l:annotationLine = split(getline(next_line))[1]
  
  let self.activeAnnotation =
    \ filter(copy(self.annotations), 
    \ {_, val -> val.line == l:annotationLine})[0]
  
  call setpos(".", [0, l:next_line, l:current_pos[2], l:current_pos[3]])
  echo self.activeAnnotation
endfunction

" Determines the contents of the buffer, as well as where the window opens.
" Each invocation function takes a list of annotations.
function! gadamer#window#modes.view.invoke(annotations, ...) 
  let g:gadamer#window#modes.view.annotations = a:annotations
  for annotation in a:annotations
    execute 'e' annotation.annotation_file
  endfor
  
  if a:0 >= 1 
    s:defineMappings(self, a:1)
  endif
endfunction

function! gadamer#window#modes.edit.invoke(annotations, ...)
  let g:gadamer#window#modes.edit.annotations = a:annotations
  "TODO: Make position and size configurable.
  execute 'bo' 20 'new'
  for annotation in a:annotations
    execute 'e' annotation.annotation_file
  endfor
  
  if a:0 >= 1 
    s:defineMappings(self, a:1)
  endif
endfunction

function! gadamer#window#modes.list.invoke(annotations, ...)
  let g:gadamer#window#modes.list.annotations = a:annotations
  "TODO: Make position and size configurable.
  execute 'bo' 20 'new'
  for annotation in a:annotations
    let l:list_item = "line " . annotation.line . ' | ' . annotation.annotation_file
    call append(line("$"), l:list_item)
  endfor

  if a:0 >= 1 
    s:defineMappings(self, a:1)
  endif
endfunction

function! gadamer#window#modes.view.setOptions() 
  setlocal buftype=""
  setlocal bufhidden=delete
  setlocal noswapfile
  setlocal readonly
endfunction

function! gadamer#window#modes.edit.setOptions() 
  setlocal buftype=""
  setlocal swapfile
endfunction

function! gadamer#window#modes.list.setOptions() 
  setlocal buftype=nofile
  setlocal bufhidden=delete
  setlocal cursorline
  setlocal noswapfile
  setlocal readonly 
endfunction

function! gadamer#window#modes.open(mode, annotations)
  call g:gadamer#window#modes[a:mode].setPreviousBuffer()
  call g:gadamer#window#modes[a:mode].invoke(a:annotations)
  call g:gadamer#window#modes[a:mode].setOptions()
  call g:gadamer#window#modes[a:mode].setWindowMappings()
endfunction

function! gadamer#window#getModes() 
  return g:gadamer#window#modes
endfunction

