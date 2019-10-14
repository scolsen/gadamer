" Gadamer window modes.
"
" The mode API is treated separately from the implementation of modes
" themselves, to keep their particulars independent of the general concept.

" Each mode specifies a set of window options, which dictate how it renders a
" window. If a mode has an empty object for window options, it will render in
" the active window.
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
  \  'local_options': [], 'help_text': "",}

let s:help_options =
  \ [{'option': 'readonly'}, {'option': 'noswapfile'},
  \  {'option': 'bufhidden', 'value': 'delete'},
  \  {'option': 'buftype', 'value': 'nofile'},]

" Set the previous buffer of a mode.
function! s:mode.setPreviousBuffer()
  let self.previous_buffer = bufnr("%")
endfunction

" Called when a mode is invoked.
"
" Implementations of mode should execute the bulk of their set-up logic here.
" For example, if a mode creates a list using the annotations passed to it, this
" function is where is should handle executing the list construction.
function! s:mode.onInvocation(annotation)
  return
endfunction

" Bind the mappings defined on a mode to their corresponding keys. This function
" handles the actual work of binding keys according to the definitions in
" `mode.mappings`
"
" It also appends help text for each key, if provided, to the current buffer.
function! s:mode.bindWindowMappings()
  if empty(self.mappings)
    return
  endif

  for [key, info] in items(self.mappings)
    if !empty(info.help)
      call append(line("$"), key . ": " . info.help)
    endif

    let l:map = 'nnoremap <buffer> <silent> ' . key . ' :call ' . info.mapping .
      \ '<CR>'
    execute l:map
  endfor

  call append(line("$"), "----------")
  call append(line("$"), "")
endfunction

" Set window local options for a mode.
" If an option does not have a value key, it is assumed to be a vi option that
" does not take an argument.
function! s:mode.setLocalOptions(options = self.local_options)
  for option in a:options
    if has_key(option, 'value')
      exe "setlocal" option.option . "=" . option.value
    else
      exe "setlocal" option.option
    endif
  endfor
endfunction

" Invoke a given mode. Assigns the given annotations to the mode, and passes
" each annotation to the mode's invocation callback.
function! s:mode.invoke(annotations)
  let self.annotations = a:annotations

  for annotation in a:annotations
    call self.onInvocation(annotation)
  endfor
endfunction

" Open a mode.
"
" Opening a mode entails invoking it, setting its options, and binding its
" defined mappings.
function! s:mode.open(annotations)
  call self.setPreviousBuffer()

  if !empty(self.window_options)
    execute self.window_options.position self.window_options.size 'new'
  endif

  if !empty(self.help_text)
    call append(line("$"), self.help_text)
  endif

  call self.bindWindowMappings()
  call self.invoke(a:annotations)
  call self.setLocalOptions()
endfunction

" Return a new 'instance' of a mode.
" A valid mode requires mappings, window options, and local buffer options.
" Returns the instantiated mode.
function! gadamer#mode#new(mappings, window_options, local_options, help_text)
  let l:mode = copy(s:mode)
  let l:mode.mappings = a:mappings
  let l:mode.window_options = a:window_options
  let l:mode.local_options = a:local_options
  let l:mode.help_text = a:help_text

  return l:mode
endfunction

