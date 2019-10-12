"  Gadamer view mode.

let s:mappings =
  \ {'q': 'g:gadamer#view.close()'}
let s:window_options = {}
let s:local_options =
  \ [{'option': 'readonly'}, {'option': 'noswapfile'},
  \  {'option': 'bufhidden', 'value': 'delete'},
  \  {'option': 'buftype', 'value': ""},]

let gadamer#view = gadamer#mode#new(s:mappings, s:window_options, s:local_options)

function! gadamer#view.close()
  exe "b" . self.previous_buffer
endfunction

function! gadamer#view.onInvocation(annotation)
  execute 'e' a:annotation.annotation_file
endfunction

