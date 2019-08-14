" Gadamer edit mode.

let s:mappings = {}
let s:local_options =
  \ [{'option': 'readonly'}, {'option': 'noswapfile'},
  \  {'option': 'bufhidden', 'value': 'delete'},
  \  {'option': 'buftype', 'value': ""},]
let s:window_options =
  \ {'position': 'bo', 'size': 20}

let gadamer#edit = gadamer#mode#new(s:mappings, s:window_options, s:local_options)

function! gadamer#edit.onInvocation(annotation)
  execute 'e' a:annotation.annotation_file
endfunction

