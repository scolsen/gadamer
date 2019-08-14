" Gadamer list mode.

let s:mappings =
  \ {'j': 'g:gadamer#list.updateAnnotationOnMove(1)',
  \  'k': 'g:gadamer#list.updateAnnotationOnMove(-1)',}
let s:local_options =
  \ [{'option': 'readonly'}, {'option': 'noswapfile'},
  \  {'option': 'cursorline'},
  \  {'option': 'bufhidden', 'value': 'delete'},
  \  {'option': 'buftype', 'value': 'nofile'},]
let s:window_options = 
  \ {'position': 'bo', 'size': 20}

let gadamer#list = gadamer#mode#new(s:mappings, s:window_options, s:local_options)

function! gadamer#list.updateAnnotationOnMove(modifier)
  let l:current_pos = getpos(".")
  let l:next_line = l:current_pos[1] + a:modifier
  let l:annotationLine = split(getline(next_line))[1]
  
  let self.active_annotation =
    \ filter(copy(self.annotations), 
    \ {_, val -> val.line == l:annotationLine})[0]
  
  call setpos(".", [0, l:next_line, l:current_pos[2], l:current_pos[3]])
  echo self.active_annotation
endfunction

function! gadamer#list.onInvocation(annotation)
  let l:list_item = "line " . a:annotation.line . 
    \ ' | ' . a:annotation.annotation_file
  call append(line("$"), l:list_item)
endfunction


