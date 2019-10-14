" Gadamer API functions.

function! s:openAnnotation(line)
  let l:annotation_file =
    \ g:gadamer#config.directory . "/" . expand("%:t:r") . a:line . ".md"
  let s:current_annotation = gadamer#annotations#new(a:line, l:annotation_file)
  call s:current_annotations.add(s:current_annotation)

  call g:gadamer#edit.open([s:current_annotation])

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
      call gadamer#signs#loadSign(l:annotation)
    endif
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
