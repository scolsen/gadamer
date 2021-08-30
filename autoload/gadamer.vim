" Gadamer API functions.

function! s:openAnnotation(line, ...)
  if a:0 >= 1
    let l:end = a:1
  else
    let l:end = a:line
  end

  " TODO: Add the requisite checks when we're given a name as an argument
  " Remove ext and replace with md. Ensure file doesn't already exist.
  if a:0 >= 2
    let l:name = a:2 . ".md"
  else
    let l:name = expand("%:t:r") . a:line . "-" . l:end . ".md"
  end

  let l:relativedir = expand("%:p:h")
  let l:annotation_file =
    \ l:relativedir . g:gadamer#config.directory . "/" . l:name
  let s:current_annotation = gadamer#annotations#open(a:line, l:end, l:annotation_file, s:current_annotations, {'start': 1, 'end': 1})

  call g:gadamer#edit.open([s:current_annotation])

  " Save this annotation to the configuration file when the buffer is exited.
  au QuitPre <buffer> call gadamer#annotations#save(s:current_annotation, s:current_annotations)
endfunction

function! s:openLink(file, start, end, line, ...)
  if a:0 >= 1
    let l:end = a:1
  else
    let l:end = a:line
  end

  let s:current_annotation = gadamer#annotations#open(a:line, l:end, a:file, s:current_annotations, {'start': a:start, 'end': a:end}, 'true')

  call g:gadamer#view.open([s:current_annotation])

  " Save this annotation to the configuration file when the buffer is exited.
  au QuitPre <buffer> call gadamer#annotations#save(s:current_annotation, s:current_annotations)
endfunction

" Load signs from a saved .gadamer-config
" Then place marks for each.
function! s:loadAnnotations()
  call gadamer#annotations#load(".gadamer-config", s:current_annotations)

  for annotation in gadamer#annotations#allAnnotations(s:current_annotations)
    if annotation.link ==# 'true'
      call gadamer#signs#loadSign(annotation, g:gadamer#signs#LINK)
    else
      call gadamer#signs#loadSign(annotation, g:gadamer#signs#NAME)
    endif
  endfor
endfunction

" Do everything we need to do to annotate a file.
" Create a buffer, create a mark, on save, save the contents.
" Maintain an association of file<->annotation.
function! gadamer#Annotate(line = line("."), ...) abort
  " Store a reference to this buffer--otherwise, we'd place the sign
  " in the annotation buffer by default.
  let l:buf = expand("%:p")

  if a:0 >= 1
    let l:end = a:1
  else
    let l:end = a:line
  endif

  if a:0 >= 2
    call s:openAnnotation(a:line, l:end, a:2)
  else
    call s:openAnnotation(a:line, l:end)
  endif

  call gadamer#signs#loadSign(s:current_annotation, g:gadamer#signs#NAME, l:buf)
endfunction

function! gadamer#Link(file, start, end, line = line("."), ...)
let l:buf = expand("%:p")

  if a:0 >= 1
    let l:end = a:1
  else
    let l:end = a:line
  endif

  call s:openLink(a:file, str2nr(a:start), str2nr(a:end), a:line, l:end)

  call gadamer#signs#loadSign(s:current_annotation, g:gadamer#signs#LINK, l:buf)
endfunction

" Opens an annotation for reading.
" If more than one annotation exists for the given starting line, a list of
" annotations is returned.
function! gadamer#Read(line = line(".")) abort
  let l:annotations = values(s:current_annotations.getByLine(a:line))

  if len(l:annotations) == 0
    echoerr "No annotation for the corresponding line."
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
  call gadamer#signs#init(g:gadamer#config.signchar, g:gadamer#config.alt_sign, g:gadamer#config.link_sign, g:gadamer#config.backlink_sign)
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
