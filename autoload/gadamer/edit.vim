" Gadamer edit mode.

let s:mappings = {}
let s:window_options =
  \ {'position': 'abo', 'size': 20}
let s:local_options =
  \ [{'option': 'swapfile'},
  \  {'option': 'buftype', 'value': ""},]
let s:help_text = ""

let gadamer#edit = gadamer#mode#new(s:mappings, s:window_options, s:local_options, s:help_text)

function! gadamer#edit.onInvocation(annotation)
  execute 'e' a:annotation.annotation_file
endfunction

function! gadamer#edit#init() abort

endfunction
