" Gadamer API functions.  
" Sign definitions.

let s:file_win = winnr()

" Window modes
" Note that we could set a gadamer#window#modes variable and use it directly,
" however, just as any other variable, it requires scope specification " at point of use. 
" Thus, to use it in a function, we'd have to append 'g:'
" since variable names in functions are locally scoped by default.
" Simply exposing a getter function that returns the defined modes is
" slightly more ergonomic.
let s:modes = gadamer#window#getModes()

" Configuration options
let s:global_prefix = "g:gadamer_"
let s:config = {'signchar': '*', 'height': 12, 'directory': '.annotations'}
let s:config.list_window = {'position': 'bo', 'size': 20}

" Set the value of the script-local signs
" to that of user configured globals
" if they exist.
function! s:getConfig() 
  for key in keys(s:config)
    let gvar = s:global_prefix . key
    if exists(gvar)
      let val = split(execute("echo " . gvar), '\n')[0]
      echo val
      exe "let " . "s:config." . key . "=" . '"' . val . '"'
    endif
  endfor
endfunction

function! s:openAnnotation(line)
  let l:annotation_file =
    \ s:config.directory . "/" . expand("%:t:r") . a:line . ".md"
  let s:current_annotation = gadamer#annotations#new(a:line, l:annotation_file)
  call s:current_annotations.add(s:current_annotation)

  call s:modes.open('edit', [s:current_annotation])
  
  " Save this annotation to the configuration file when the buffer is exited.
  au QuitPre <buffer> call s:saveAnnotation(s:current_annotation)
endfunction

function! s:saveAnnotation(annotation) abort
  let l:annotation_line = "echo \"" . s:current_annotations.source_file .
    \ " " . a:annotation.line . 
    \ " " . a:annotation.annotation_file . "\""
  redi! >> .gadamer-config
    silent! exe l:annotation_line
  redi! END
endfunction

" Load signs from a saved .gadamer-config
" Then place marks for each.
function! s:loadAnnotations()
  let l:saved_annotations = readfile(".gadamer-config")[1:]
  
  for annotation_line in l:saved_annotations
    let fields = split(annotation_line)
    let [filename, line, annotation_file] = split(annotation_line)
    if filename == s:current_annotations.source_file
      let l:annotation = gadamer#annotations#new(line, annotation_file)
      call s:current_annotations.add(l:annotation)
      call gadamer#signs#loadSign(l:annotation.line)
    endif
  endfor
endfunction

" Do everything we need to do to annotate a file.
" Create a buffer, create a mark, on save, save the contents.
" Maintain an association of file<->annotation.
function! gadamer#Annotate(line) abort
  let l:sign = gadamer#signs#new(a:line)
  call gadamer#signs#place(l:sign)
  call s:openAnnotation(a:line)
endfunction

function! gadamer#Read(line) abort
  let l:annotation = s:current_annotations.getByLine(a:line)

  if l:annotation == {}
    echoerr "No annotation file found."
    return
  endif

  call s:modes.open('view', [l:annotation])
endfunction
 
function! gadamer#List() abort
  call s:modes.open('list', values(s:current_annotations.set))
endfunction

function! s:startup() abort
  call s:getConfig()
  "Initialize sign support.
  call gadamer#signs#init(s:config.signchar)
  let s:current_annotations =
    \ gadamer#annotations#newFileAnnotations(expand("%:p"))
  
  if filereadable(".gadamer-config")
    call s:loadAnnotations()
  endif

  if !isdirectory(s:config.directory)
    call mkdir(s:config.directory)
  endif
endfunction

call s:startup()
