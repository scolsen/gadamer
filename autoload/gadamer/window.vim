" Gadamer window modes.

let gadamer#window#modes = {'view': {'annotations': [], 'activeAnnotation': {}},
            \  'edit': {'annotations': [], 'activeAnnotation': {}},
            \  'list': {'annotations': [], 'activeAnnotation': {}},}

let gadamer#window#modes.list.mappings = 
  \ {'j': 'g:gadamer#window#modes.list.updateAnnotationOnMove(1)',
  \  'k': 'g:gadamer#window#modes.list.updateAnnotationOnMove(-1)',}

function! s:defineMappings(mode, mappings)
  for [key, callback] in items(a:mappings)
    let invocation = function(callback, [mode.activeAnnotation, mode.annotations]) 
    
    "let invocation = 
    "  \ callback . '(get(gadamer#window#modes.' . a:mode .
    "  \ ', activeAnnotation), get(gadamer#window#modes.' . a:mode . ', annotations)' . ')'
    
    let g:gadamer#window#modes[a:mode].mappings[key] = invocation
  endfor
endfunction

function! s:setWindowMappings(mode)
  for [key, mapping] in items(g:gadamer#window#modes[a:mode].mappings)
    let l:map = 'nnoremap <buffer> <silent> ' . key . ' :call ' . mapping .
      \ '<CR>'
    execute l:map
  endfor
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
    execute 'e' annotation.annoFile
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
    execute 'e' annotation.annoFile
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
    let l:list_item = "line " . annotation.line . ' | ' . annotation.annoFile
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
  call g:gadamer#window#modes[a:mode].invoke(a:annotations)
  call g:gadamer#window#modes[a:mode].setOptions()
  call s:setWindowMappings(a:mode)
endfunction

function! gadamer#window#getModes() 
  return g:gadamer#window#modes
endfunction

