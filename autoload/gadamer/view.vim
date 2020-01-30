"  Gadamer view mode.

let s:mappings =
  \ { 'q': {'mapping': 'g:gadamer#view.close()', 'help': 'Close the annotation.'},
  \   'e': {'mapping': 'g:gadamer#view.editFile()', 'help': 'Edit this annotation.'},}

let s:window_options = {'position': 'abo', 'size': 20, 'cmd': 'new',}
let s:local_options =
  \ [{'option': 'readonly'}, {'option': 'noswapfile'},
  \  {'option': 'bufhidden', 'value': 'delete'},
  \  {'option': 'buftype', 'value': "nofile"},
  \  {'option': 'signcolumn', 'value': "yes"} ]
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

function! gadamer#view.viewAnnotation(annotation)
  let l:context = "Viewing annotation for line "
    \ . a:annotation.lines.start . "," . a:annotation.lines.end
    \ . " in file " . a:annotation.annotation_file
  let self.help_text = self.help_text + [l:context] + "----------"

  execute '$'
  execute 'r' a:annotation.annotation_file
endfunction

function! gadamer#view.viewLink(annotation)
  let l:context = "Viewing Link for "
    \ . a:annotation.lines.start . "," . a:annotation.lines.end
    \ . " in file " . a:annotation.annotation_file
  let self.help_text = self.help_text + [l:context] + "----------"

  let l:dest = a:annotation.dest.start + len(self.help_text) + 1

  execute '$'
  execute 'r' a:annotation.annotation_file
  execute 'file' a:annotation.annotation_file
  call gadamer#signs#loadLinkSign(a:annotation)
  execute l:dest 
endfunction

function! gadamer#view.onInvocation(annotation)
  if a:annotation.link ==# 'true'
    call self.viewLink(a:annotation)
  else
    call self.viewAnnotation(a:annotation)
  endif
endfunction

function! gadamer#view#init() abort

endfunction
