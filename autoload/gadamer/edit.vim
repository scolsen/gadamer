" Gadamer edit mode.

let s:mappings = {}
let s:window_options =
  \ {'position': 'bo', 'size': 20}
let s:local_options =
  \ [{'option': 'swapfile'},
  \  {'option': 'buftype', 'value': ""},]

let gadamer#edit = gadamer#mode#new(s:mappings, s:window_options, s:local_options)

function! gadamer#edit.onInvocation(annotation)
  execute 'e' a:annotation.annotation_file
endfunction

