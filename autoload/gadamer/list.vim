" Gadamer list mode.

" Stores a reference to the first line that contains a selectable annotation
" item.
let s:good_line = v:none

let s:mappings =
  \ { '<CR>': {'mapping': 'g:gadamer#list.openAnnotation()', 'help': 'Open an annotation.'},
  \   'q': {'mapping': 'g:gadamer#list.close()', 'help': 'Close the list window.'},}

let s:local_options =
  \ [{'option': 'readonly'}, {'option': 'noswapfile'},
  \  {'option': 'cursorline'},
  \  {'option': 'bufhidden', 'value': 'delete'},
  \  {'option': 'buftype', 'value': 'nofile'},]
let s:window_options =
  \ {'position': 'bo', 'size': 20, 'cmd': 'new'}

let s:help_text =
  \ "Annotations available for this file.
  \ Press enter to open an annotation, or press q to quit."

let gadamer#list = gadamer#mode#new(s:mappings, s:window_options, s:local_options, s:help_text)

" TODO: Describe this function.
function! gadamer#list.openAnnotation()
  " The first two lines of the list window is do not list annotations.
  " The first line is empty. The second is help text.
  if line(".") <= s:good_line
    echo "No annotation selected."
    return
  endif

  let l:annotation_line = split(getline(line(".")))[1]
  let [start, end] = split(l:annotation_line, ',')
  let self.active_annotation =
    \ filter(copy(self.annotations),
    \ {_, val -> val.lines.start == start && val.lines.end == end})[0]

  call g:gadamer#view.open([self.active_annotation])
endfunction

function! s:setAnnotationLine(annotation)
return "lines " . a:annotation.lines.start .
    \ ',' . a:annotation.lines.end .
    \ ' | ' . a:annotation.annotation_file
endfunction

function! s:setLinkLine(annotation)
 return "lines " . a:annotation.lines.start .
    \ ',' . a:annotation.lines.end .
    \ ' → ' . a:annotation.annotation_file .
    \ ' ' . a:annotation.dest.start . ',' . a:annotation.dest.end
endfunction

function! gadamer#list.onInvocation(annotation)
  " Set good_line to the first selectable line number.
  " Prevents index out of bounds calls on selection.
  if s:good_line == v:none
    let s:good_line = line("$")
  endif

  if a:annotation.link ==# 'true'
    let l:list_item = s:setLinkLine(a:annotation)
  else
    let l:list_item = s:setAnnotationLine(a:annotation)
  endif

  call append(line("$"), l:list_item)
endfunction

" Just a synonym for :q
function! gadamer#list.close()
  :q
endfunction

function! gadamer#list#init() abort

endfunction
