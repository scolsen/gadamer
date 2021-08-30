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
  call self.setHelp([s:help_text])
  :q
endfunction

function! gadamer#view.editFile()
  let s:immersive_editor = copy(g:gadamer#edit)
  let s:immersive_editor.window_options = {}
  call s:immersive_editor.open(self.annotations)
endfunction

function! gadamer#view.viewAnnotation(annotation)
  execute '$'
  execute 'r' a:annotation.annotation_file
endfunction

function! gadamer#view.viewLink(annotation)
  let l:dest = a:annotation.dest.start + len(self.help_text) + 1
  let l:relative = deepcopy(a:annotation)
  let l:relative.dest = {'start': l:dest, 'end': l:dest + a:annotation.dest.end}
  let l:relative.lines = {'start': l:dest, 'end': l:dest + a:annotation.dest.end}

  execute '$'
  execute 'r' a:annotation.annotation_file
  " append a suffix, otherwise vim will complain about conflicting buffer names
  " when the file links to itself.
  execute 'file' a:annotation.annotation_file . ":gadamer-link"
  call gadamer#signs#loadSign(l:relative, g:gadamer#signs#BACKLINK)
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
