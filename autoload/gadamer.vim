" Gadamer API functions.

function! s:openAnnotation(line)
  let l:annotation_file =
    \ g:gadamer#config.directory . "/" . expand("%:t:r") . a:line . ".md"
  let s:current_annotation = gadamer#annotations#open(a:line, l:annotation_file, s:current_annotations)

  call g:gadamer#edit.open([s:current_annotation])

  " Save this annotation to the configuration file when the buffer is exited.
  au QuitPre <buffer> call gadamer#annotations#save(s:current_annotation, s:current_annotations)
endfunction

" Load signs from a saved .gadamer-config
" Then place marks for each.
function! s:loadAnnotations()
  call gadamer#annotations#load(".gadamer-config")

  for annotation in s:current_annotations
    call gadamer#signs#loadSign(annotation)
  endfor
endfunction

" Do everything we need to do to annotate a file.
" Create a buffer, create a mark, on save, save the contents.
" Maintain an association of file<->annotation.
function! gadamer#Annotate(line = line(".")) abort
  " Store a reference to this buffer--otherwise, we'd place the sign
  " in the annotation buffer by default.
  let l:buf = expand("%:p")
  call s:openAnnotation(a:line)
  let l:sign = gadamer#signs#fromAnnotation(s:current_annotation)
  call gadamer#signs#place(l:sign, l:buf)
endfunction

function! gadamer#Read(line = line(".")) abort
  let l:annotation = s:current_annotations.getByLine(a:line)

  if l:annotation == {}
    echoerr "No annotation file found."
    return
  endif

  call g:gadamer#view.open([l:annotation])
endfunction

function! gadamer#List() abort
  call g:gadamer#list.open(values(s:current_annotations.set))
endfunction

function! s:startup() abort
  " Load other components
  call gadamer#list#init()
  call gadamer#edit#init()
  call gadamer#view#init()
  call gadamer#config#init()
  "Initialize sign support.
  call gadamer#signs#init(g:gadamer#config.signchar)
  let s:current_annotations =
    \ gadamer#annotations#newFileAnnotations(expand("%:p"))

  if filereadable(".gadamer-config")
    call s:loadAnnotations()
  endif

  if !isdirectory(g:gadamer#config.directory)
    call mkdir(g:gadamer#config.directory)
  endif
endfunction

call s:startup()
