" Definition of a Gadamer window mode.
" The mode API is treated separately from the implementation of modes
" themselves, to keep their particulars independent of the general concept.

" Each mode specifies a set of window options, which dictate how it renders a
" window. If a mode has an empty object for window options, it will use the
" render in the active window.
let s:window_options = {'position': 'bo', 'size': 20}

" A mode is comprised of a set of annotations and an active annotation, it's
" data--which specific implementations use as they will; knowledge of the
" previous buffer to enable jumping between contexts; a set of key mappings
" specific to the mode's buffer/window; a set of `window_options` that specify
" how the mode should be opened in a window; and a set of local options that
" specify buffer local options for instances of the mode.
let s:mode =
  \ {'annotations': [], 'active_annotation': {}, 'previous_buffer': 0,
  \  'mappings': {}, 'window_options': copy(s:window_options),
  \  'local_options': []}

" Set the previous buffer of a mode.
function! s:mode.setPreviousBuffer()
  let self.previous_buffer = bufnr("%")
endfunction

" Called when a mode is invoked.
" Implementations of mode should execute the bulk of their content set-up logic
" here. For example, if a mode each annotation passed to it to a list, this
" function is where is should handle executing the list construction.
function! s:mode.onInvocation(annotation) 
  return
endfunction

" Define a set of window mappings for the mode.
" Currently unused. This enables us to define mappings for a given mode after its
" initial construction.
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
" If an option does not have a value key, it is assumed to be a vi option that
" does not take an argument.
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
" Assigns the given annotations to the mode, and passes each annotation to the
" mode's invocation callback. 
" Additionally, this function also assigns the mode's previous buffer and opens
" a new window if window options are set.
function! s:mode.invoke(annotations)
  let self.annotations = a:annotations
  call self.setPreviousBuffer()
  
  if !empty(self.window_options)
    execute self.window_options.position self.window_options.size 'new'
  endif

  for annotation in a:annotations
    call self.onInvocation(annotation)
  endfor
endfunction

" Open a mode.
" Opening a mode entails invoking it, setting its options, and binding its
" defined mappings.
function! s:mode.open(annotations)
  call self.invoke(a:annotations)
  call self.setLocalOptions()
  call self.bindWindowMappings()
endfunction

" Return a new 'instance' of a mode.
" A valid mode requires mappings, window options, and local buffer options.
" Returns the instantiated mode.
function! gadamer#mode#new(mappings, window_options, local_options)
  let l:mode = copy(s:mode)
  let l:mode.mappings = a:mappings
  let l:mode.window_options = a:window_options
  let l:mode.local_options = a:local_options 

  return l:mode
endfunction

