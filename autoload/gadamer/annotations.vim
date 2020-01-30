" Implementation of annotations representation.

" A set of annotations.
" Annotation uniqueness is predicated on the annotation's `line` field. If two
" annotation lines are equivalent, the annotations are considered to be
" equivalent.
" Each set has an associated source file.
let s:annotations = {'source_file': '', 'set': {}}

" The range of lines a given annotation spans.
function! s:range(start, end)
  return {'start': a:start, 'end': a:end}
endfunction

" Create a new annotation.
" Annotations are an association between a segment of a file and another file
" containing the contents of the annotation.
" For now, we only support one annotation per line.
" The actual file association is handled by the `s:annotations`, and not
" defined as a part of an annotation itself.
function! gadamer#annotations#new(line, file, link = 'false', dest = 1, ...)

  if a:0 < 1
    let l:end = a:line
  else
    let l:end = a:1
  endif

  let l:range = s:range(a:line, l:end)

  if a:link ==# 'true'
    if a:0 >= 2
      let l:dest_end = a:2
    else
      let l:dest_end = a:dest
    endif
   
    let l:dest = s:range(a:dest, l:dest_end)

    return { 'lines': l:range, 'annotation_file': a:file, 
           \ 'link': 'true', 'dest': l:dest}
  else 
    return { 'lines': l:range, 'annotation_file': a:file, 'link': 'false',}
  endif
endfunction

" Return a sorted list of the lines of all the annotations stored in a set of
" annotations.
function! s:annotations.lines()
  return sort(keys(self.set))
endfunction

" Set membership predicate function.
" Returns true if the provided annotation is a member of the annotations set.
function! s:annotations.member(annotation)
  let l:range = a:annotation.lines
  let l:set = self.set

  if !has_key(l:set, l:range.start)
    return v:false
  endif

  return has_key(self.set[l:range.start], a:annotation.lines.end)
    \ && l:set[l:range.start].link ==? a:annotaion.link
endfunction

" Add an annotation to a set of annotations.
" If the annotation is already a member of the set, this function does nothing.
function! s:annotations.add(annotation)
  let l:range = a:annotation.lines

  if self.member(a:annotation)
    return
  endif

  if !has_key(self.set, l:range.start)
    let self.set[l:range.start] = {}
  endif

  let self.set[l:range.start][l:range.end] = a:annotation
endfunction

" Remove an annotation from a set of annotations.
" If the annotation is not in the set, this function does nothing.
function! s:annotations.remove(annotation)
  let l:range = a:annotation.lines

  if !self.member(a:annotation)
    return
  endif

  call remove(self.set[l:range.start], l:range.end)

  if empty(self.set[l:range.start])
    call remove(self.set[l:range.start])
  endif
endfunction

" Update an annotation in a set of annotations.
" If the provided annotation is not a member of the set, the annotation is
" added to the set using `s:annotations.add`
function! s:annotations.update(annotation)
  l:range = a:annotation.lines

  if !self.member(a:annotation)
    call self.add(a:annotation)
    return
  endif

  let self.set[l:range.start][l:range.end] = a:annotation
endfunction

" Attempt to retrieve an annotation by line number.
" If the annotation is not a member of the set, an empty dictionary is returned.
function! s:annotations.getByLine(line)
  return get(self.set, a:line, {})
endfunction

" Creates a new set of annotations associated with `a:source` file.
" Expects a list of annotations as an optional argument, which is used to
" populate the initial set contents.
function! gadamer#annotations#newFileAnnotations(source_file, ...)
  let l:annotations = copy(s:annotations)

  let l:annotations.source_file = a:source_file

  if a:0 > 0 && type(a:1) == v:t_list
    for annotation in a:1
      call l:annotations.add(annotation)
    endfor
  endif

  return l:annotations
endfunction

" Returns a new annotation based on the contents of a saved annotation file
" and adds it to the given set of annotations.
function! gadamer#annotations#open(lineStart, lineEnd, file, annotations) abort
  let l:annotation = gadamer#annotations#new(a:lineStart, a:file, a:lineEnd)
  call a:annotations.add(l:annotation)
  return l:annotation
endfunction

" Save an annotation to the source file assocaited with a set of annotations.
function! gadamer#annotations#save(annotation, annotations) abort
  let l:annotation_line = "echo \"" . a:annotations.source_file .
    \ " " . a:annotation.lines.start .
    \ " " . a:annotation.lines.end .
    \ " " . a:annotation.annotation_file . "\"" .
    \ " " . a:annotation.link .
    \ " " . a:annotation.dest.start .
    \ " " . a:annotation.dest.end .
  redi! >> .gadamer-config
    silent! exe l:annotation_line
  redi! END
endfunction

function! gadamer#annotations#load(annotations_spec, annotations) abort
  let l:saved_annotations = readfile(a:annotations_spec)[1:]

  for annotation_line in l:saved_annotations
    let fields = split(annotation_line)
    
    echo fields

    if len(fields) == 3
      let [filename, lineStart, annotation_file] = fields
      let lineEnd = lineStart
    else
      let [filename, lineStart, lineEnd, annotation_file, link, destStart, destEnd] = fields
    endif

    if filename == a:annotations.source_file
      let l:annotation = 
        \ gadamer#annotations#new(lineStart, annotation_file, link, destStart, lineEnd, destEnd)
      call a:annotations.add(l:annotation)
    endif
  endfor
endfunction

function! gadamer#annotations#allAnnotations(annotations) abort
  let l:result = []
  let l:set = a:annotations.set

  for k in keys(l:set)
    let l:result = l:result + values(l:set[k])
  endfor

  return l:result
endfunction
