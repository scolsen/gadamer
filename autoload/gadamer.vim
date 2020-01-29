" Gadamer API functions.

function! s:openAnnotation(line, ...)
  if a:0 >= 1
    let l:end = a:1
  else
    let l:end = a:line
  end

  let l:annotation_file =
    \ g:gadamer#config.directory . "/" . expand("%:t:r") . a:line . ".md"
  let s:current_annotation = gadamer#annotations#open(a:line, l:end, l:annotation_file, s:current_annotations)

  call g:gadamer#edit.open([s:current_annotation])

  " Save this annotation to the configuration file when the buffer is exited.
  au QuitPre <buffer> call gadamer#annotations#save(s:current_annotation, s:current_annotations)
endfunction

" Load signs from a saved .gadamer-config
" Then place marks for each.
function! s:loadAnnotations()
  call gadamer#annotations#load(".gadamer-config", s:current_annotations)

  for annotation in gadamer#annotations#allAnnotations(s:current_annotations)
    call gadamer#signs#loadSign(annotation)
  endfor
endfunction

" Do everything we need to do to annotate a file.
" Create a buffer, create a mark, on save, save the contents.
" Maintain an association of file<->annotation.
function! gadamer#Annotate(line = line("."), ...) abort
  " Store a reference to this buffer--otherwise, we'd place the sign
  " in the annotation buffer by default.
  let l:buf = expand("%:p")

  if a:0 >=1
    let l:end = a:1
  else
    let l:end = a:line
  endif

  call s:openAnnotation(a:line, l:end)
  " TODO: Replace this with a single call to loadSign
  let l:sign = gadamer#signs#fromAnnotation(s:current_annotation.lines.start)
  call gadamer#signs#place(l:sign, l:buf)
endfunction

" Opens an annotation for reading.
" If more than one annotation exists for the given starting line, a list of
" annotations is returned.
function! gadamer#Read(line = line(".")) abort
  let l:annotations = values(s:current_annotations.getByLine(a:line))

  if len(l:annotations) == 0
    echoerr "No annotation file found."
    return
  endif

  if len(l:annotations) == 1
    call g:gadamer#view.open(l:annotations)
  else
    call g:gadamer#list.open(l:annotations)
  endif
endfunction

function! gadamer#List() abort
  call g:gadamer#list.open(gadamer#annotations#allAnnotations(s:current_annotations))
endfunction

function! gadamer#Visualize() abort
  call g:gadamer#visualizer.open(gadamer#annotations#allAnnotations(s:current_annotations))
endfunction

function! s:startup() abort
  " Load other components
  call gadamer#list#init()
  call gadamer#edit#init()
  call gadamer#view#init()
  call gadamer#visualizer#init()
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
