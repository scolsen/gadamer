" Implementation of annotations representation.

" A set of annotations. 
" Annotation uniqueness is predicated on the annotation's `line` field. If two
" annotation lines are equivalent, the annotations are considered to be
" equivalent.
" Each set has an associated source file.
let s:annotations = {'source_file': '', 'set': {}}

" Create a new annotation. 
" Annotations are an association between a segment of a file and another file
" containing the contents of the annotation.
" For now, we only support one annotation per line.
" The actual file association is handled by the `s:annotations`, and not
" defined as a part of an annotation itself.
function! gadamer#annotations#new(line, file)
  return { 'line': a:line, 'annotation_file': a:file,}
endfunction

" Return a sorted list of the lines of all the annotations stored in a set of
" annotations.
function! s:annotations.lines()
  return sort(keys(self.set))
endfunction

" Set membership predicate function.
" Returns true if the provided annotation is a member of the annotations set.
function! s:annotations.member(annotation)
  return has_key(self.set, a:annotation.line)
endfunction

" Add an annotation to a set of annotations. 
" If the annotation is already a member of the set, this function does nothing.
function! s:annotations.add(annotation)
  if self.member(a:annotation)
    return 
  endif

  let self.set[a:annotation.line] = a:annotation
endfunction

" Remove an annotation from a set of annotations.
" If the annotation is not in the set, this function does nothing.
function! s:annotations.remove(annotation)
  if !self.member(a:annotation)
    return
  endif

  call remove(self.set, a:annotation.line)
endfunction

" Update an annotation in a set of annotations.
" If the provided annotation is not a member of the set, the annotation is
" added to the set using `s:annotations.add`
function! s:annotations.update(annotation)
  if !self.member(a:annotation)
    call self.add(a:annotation)
    return
  endif

  let self.set[a:annotation.line] = a:annotation
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
