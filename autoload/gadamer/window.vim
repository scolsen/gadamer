" Gadamer window modes.

let s:window_options = {'position': 'bo', 'size': 20}
let s:mode =
  \ {'annotations': [], 'active_annotation': {}, 'previous_buffer': 0,
  \  'mappings': {}, 'window_options': copy(s:window_options),
  \  'local_options': []}

" Set the previous buffer of a mode.
function! s:mode.setPreviousBuffer()
  let self.previous_buffer = bufnr("%")
endfunction

" Called when a mode is invoked.
function! s:mode.onInvocation(annotation) 
  return
endfunction

" Define a set of window mappings for the mode.
function! s:mode.defineMappings(mappings) 
  for [key, callback] in items(a:mappings)
    let invocation = function(callback, [self.active_annotation, self.annotations]) 
    
    let self.mappings[key] = invocation
  endfor
endfunction

" Bind the mappings defined on a mode to their corresponding keys.
" This function handles the actual work of binding keys according to the
" definitions found in `mode.mappings`
function! s:mode.bindWindowMappings()
  for [key, mapping] in items(self.mappings)
    let l:map = 'nnoremap <buffer> <silent> ' . key . ' :call ' . mapping .
      \ '<CR>'
    execute l:map
  endfor
endfunction

" Set window local options for a mode.
function! s:mode.setLocalOptions()
  for option in self.local_options
    if has_key(option, 'value')
      exe "setlocal" option.option . "=" . option.value
    else
      exe "setlocal" option.option
    endif
  endfor
endfunction

" Invoke a given mode.
function! s:mode.invoke(annotations, ...)
  let self.annotations = a:annotations
  call self.setPreviousBuffer()
  
  if !empty(self.window_options)
    execute self.window_options.position self.window_options.size 'new'
  endif

  for annotation in a:annotations
    call self.onInvocation(annotation)
  endfor

  if a:0 >= 1
    call self.defineMappings(a:1)
  endif
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

let gadamer#window#modes.view.window_options = {}

let gadamer#window#modes.list.local_optsions =
  \ [{'option': 'readonly'}, {'option': 'noswapfile'},
  \  {'option': 'cursorline'},
  \  {'option': 'bufhidden', 'value': 'delete'},
  \  {'option': 'buftype', 'value': 'nofile'},]
let gadamer#window#modes.view.local_options =
  \ [{'option': 'readonly'}, {'option': 'noswapfile'},
  \  {'option': 'bufhidden', 'value': 'delete'},
  \  {'option': 'buftype', 'value': ""},]
let gadamer#window#modes.edit.local_options =
  \ [{'option': 'swapfile'},
  \  {'option': 'buftype', 'value': ""},]

function! gadamer#window#modes.view.close()
  exe "b" . self.previous_buffer
endfunction

function! gadamer#window#modes.list.updateAnnotationOnMove(modifier)
  let l:current_pos = getpos(".")
  let l:next_line = l:current_pos[1] + a:modifier
  let l:annotationLine = split(getline(next_line))[1]
  
  let self.active_annotation =
    \ filter(copy(self.annotations), 
    \ {_, val -> val.line == l:annotationLine})[0]
  
  call setpos(".", [0, l:next_line, l:current_pos[2], l:current_pos[3]])
  echo self.active_annotation
endfunction

" Determines the contents of the buffer, as well as where the window opens.
" Each invocation function takes a list of annotations.

function! gadamer#window#modes.view.onInvocation(annotation)
  execute 'e' a:annotation.annotation_file
endfunction

function! gadamer#window#modes.edit.onInvocation(annotation)
  execute 'e' a:annotation.annotation_file
endfunction

function! gadamer#window#modes.list.onInvocation(annotation)
  let l:list_item = "line " . a:annotation.line . 
    \ ' | ' . a:annotation.annotation_file
  call append(line("$"), l:list_item)
endfunction

function! gadamer#window#modes.open(mode, annotations)
  call g:gadamer#window#modes[a:mode].invoke(a:annotations)
  call g:gadamer#window#modes[a:mode].setLocalOptions()
  call g:gadamer#window#modes[a:mode].bindWindowMappings()
endfunction

function! gadamer#window#getModes() 
  return g:gadamer#window#modes
endfunction

