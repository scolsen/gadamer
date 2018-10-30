" Gadamer API functions.

" Sign definitions.

let s:sign_annotation = '*'
exe "sign define gadamer text=" . s:sign_annotation

let s:current_signs = {}
let s:gadamer_winheight = 12

function! s:current_signs.ids() 
  return sort(keys(self), 'n')
endfunction

function! s:getNextKey()
  return s:current_signs.ids()[-1] + 1
endfunction

function! s:getSigns()
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

function! s:getConfig() 
  " Set the value of the script-local signs
  " to that of user configured globals
  " if they exist.
endfunction

function! gadamer#Annotate()
  " Do everything we need to do to annotate a file.
  " Create a buffer, create a mark, on save, save the contents.
  " Maintain an association of file<->annotation.
  call s:placeSign(line("."))
  call s:openAnnotation()
endfunction!

function! s:placeSign(line)
  let l:id = s:getNextKey()
  let s:current_signs[l:id] = a:line 
  exe "sign place " . l:id . " line=" . a:line . " name=gadamer file=" . expand("%:p")  
endfunction

function! s:openAnnotation()
  exe s:gadamer_winheight . "sp dummy.md"
endfunction

call s:getSigns()
call s:getNextKey()
