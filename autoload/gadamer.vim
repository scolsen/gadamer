" Gadamer API functions.

" Sign definitions.

let s:sign_annotation = *
let s:sign_ids=
let s:current_signs = {}

sign define annotation text=s:sign_annotation

function! s:current_signs.ids() 
  return sort(keys(self), 'n')
endfunction

function! s:getNextKey()
  return s:current_signs.ids()[-1] + 1
endfunction

function! s:splitSigns()
  redi => placed_signs 
    silent! execute 'sign place file=' . expand("%:p")
  redi END
  " shamefully cribbed from signify.vim
  " https://github.com/mhinz/vim-signify
  for signl in split(placed_signs, '\n')[2:]
    let tokens = matchlist(signl, '\v^\s+\S+\=(\d+)\s+\S+\=(\d+)\s+\S+\=(.*)$') 
    let id = str2nr(tokens[2])
    let s:current_signs[id] = str2nr(tokens[1])
  endfor
endfunction

function! s:getSigns()
  " Because all signs in a file must have unique
  " ids, see `help sign` we must get a list of
  " signs in the file and maintain it
  " to determine the next unique id for sign placement.
  " listing all placed signs: sign place
  " listing only signs placed in the file:
  " sign place file={fname}
  " returned as a \n delimited text.
  " with rows: line= id= name=
endfunction

function! s:setSign() 
  " Set the value of the script-local signs
  " to that of user configured globals
  " if they exist.
endfunction

function! gadamer#Annotate()
  " Do everything we need to do to annotate a file.
  " Create a buffer, create a mark, on save, save the contents.
  " Maintain an association of file<->annotation.
endfunction!

function! gadamer#PlaceSign(line)
  " Set sign ID.
  " Place sign.
  " To place: exe "sign place 1 line=2 name=test file=" . expand("%:p")
  let l:id = s:getNextKey()
  let s:current_signs[l:id] = a:line 
  exe "sign place " . l:id . " line=" . a:line . " name=test file=" . expand("%:p")  
endfunction

call s:splitSigns()
call s:getNextKey()
