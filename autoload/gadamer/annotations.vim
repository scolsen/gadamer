" Implementation of annotations representation.

" A set of annotations. 
" Annotation uniqueness is predicated on the annotation's `id` field. If two
" annotation ids are equivalent, the annotations are considered to be
" equivalent.
let s:annotations = {}

let s:annotation =
  \ {'id': g:gadamer#annotation#EMPTY_VALUE,
  \  'sourceFile': g:gadamer#annotation#EMPTY_VALUE,
  \  'line': g:gadamer#annotation#EMPTY_VALUE,
  \  'annotationFile': g:gadamer#annotation#EMPTY_VALUE,}

function! s:annotation.new(id, source, line, file)
  let self.id = a:id
  let self.sourceFile = a:source
  let self.line = a:line
  let self.annotationFile = a:file
  
  return self
endfunction

" Create a new annotation. Copies the base implementation/definition of an
" annotation, so annotations returned by this function can utilize any of the
" functions defined on the original annotation dict.
function! gadamer#annotation#new(id, source, line, file)
  let l:annotation = copy(s:annotation)
  return l:annotation.new(a:id, a:source, a:line, a:file)
endfunction

" Return a sorted list of the ids of all the annotations stored in the set of
" annotations.
function! s:annotations.ids()
  return sort(keys(self))
endfunction

" Remove an annotation from the set.
" If the annotation is not in the set, this function does nothing.
function! s:annotations.remove(annotation)
  let l:id = get(a:annotation, 'id')

  if !has_key(self, l:id)
    return
  endif

  call remove(self, l:id)
endfunction

" Add an annotation to the set of annotations. 
" If the annotation with the same id as the annotation provided as an argument
" already  exists in the set, this function does nothing. 
function! s:annotations.add(annotation)
  let l:id = get(a:annotation, 'id')
  
  if has_key(self, l:id)
    return 
  else
    let self[l:id] = a:annotation
  endif
endfunction

" Update an annotation in the set of annotations.
" If the annotation provided as an argument is not a member of the set, the
" annotation is added to the set using `s:annotations.add`
function! s:annotations.update(id, annotation)
  if has_key(self, a:id) 
    self[a:id] = a:annotation
  else
    self.add(a:annotation)
  endif
endfunction

" Returns an empty copy of the annotations dictionary. The copy has access to
" all the methods defined on the original dictionary.
function! gadamer#annotation#annotations()
  return copy(s:annotations)
endfunction
