"  Gadamer view mode.

let s:mappings =
  \ { 'q': {'mapping': 'g:gadamer#view.close()', 'help': 'Close the annotation.'},
  \   'e': {'mapping': 'g:gadamer#view.editFile()', 'help': 'Edit this annotation.'},}

let s:window_options = {'position': 'abo', 'size': 20}
let s:local_options =
  \ [{'option': 'readonly'}, {'option': 'noswapfile'},
  \  {'option': 'bufhidden', 'value': 'delete'},
  \  {'option': 'buftype', 'value': "nofile"},]
let s:help_text =
  \ "Viewing annotation. Press q to quit."

let gadamer#view = gadamer#mode#new(s:mappings, s:window_options, s:local_options, s:help_text)

function! gadamer#view.close()
  :q
endfunction

function! gadamer#view.editFile()
  let s:immersive_editor = copy(g:gadamer#edit)
  let s:immersive_editor.window_options = {}
  call s:immersive_editor.open(self.annotations)
endfunction

function! gadamer#view.onInvocation(annotation)
  let l:context = "Viewing annotation for line "
    \ . a:annotation.line . " in file " . a:annotation.annotation_file
  let self.help_text = l:context . "\\n" . s:help_text

  execute '$'
  execute 'r' a:annotation.annotation_file
endfunction

function! gadamer#edit#init() abort

endfunction
