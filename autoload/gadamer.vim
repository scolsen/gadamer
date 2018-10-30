" Gadamer API functions.  
" Sign definitions.

let s:sign_annotation = '*' 
exe "sign define gadamer text=" . s:sign_annotation

" initialized to 0.
let s:current_signs = {}
let s:current_signs.signs = {}
let s:gadamer_winheight = 12
let s:next_key = 0

function! s:current_signs.ids() 
  return sort(keys(self.signs), 'n')
endfunction

function! s:current_signs.getNextKey()
  let self.next_key = self.ids()[-1] + 1
endfunction

" Set the value of the script-local signs
" to that of user configured globals
" if they exist.
function! s:getConfig() 

endfunction

" Get the current signs set in a file.
function! s:getSigns()
  redi => placed_signs 
    silent! exe 'sign place file=' . expand("%:p")
  redi END
  " shamefully cribbed from signify.vim
  " https://github.com/mhinz/vim-signify
  for signl in split(placed_signs, '\n')[2:]
    let tokens = matchlist(signl, '\v^\s+\S+\=(\d+)\s+\S+\=(\d+)\s+\S+\=(.*)$') 
    let id = str2nr(tokens[2])
    let s:current_signs.signs[id] = [str2nr(tokens[1])]
  endfor
  if len(s:current_signs.signs) <= 0
    let s:current_signs.signs[0] = [0, "/dev/null"]
  endif
endfunction

function! s:placeSign(line, id)
  let s:current_signs.signs[a:id] = [a:line] 
  exe "sign place " . a:id . " line=" . a:line . " name=gadamer file=" . expand("%:p")  
endfunction

function! s:openAnnotation(id)
  let fname = expand("%:r") . "-annotation-" . a:id . ".md"
  exe s:gadamer_winheight . "sp " . fname 
  call add(s:current_signs.signs[a:id], fname)
endfunction

function! s:saveSigns()
  let l:save_file = "." . expand("%:r") . "gadamer-config" 

  redi! > .gadamer-config
    for key in keys(s:current_signs.signs)
      silent! exe "echo " . "\"" . expand("%") . "\"" . " " . key . " " . get(s:current_signs.signs, key)[0] . " " . "\"" . get(s:current_signs.signs, key)[1] . "\"" 
    endfor
  redi! END
endfunction

function! s:loadSigns()

endfunction

" Do everything we need to do to annotate a file.
" Create a buffer, create a mark, on save, save the contents.
" Maintain an association of file<->annotation.
function! gadamer#Annotate()
  call s:current_signs.getNextKey()
  call s:placeSign(line("."), s:current_signs.next_key)
  call s:openAnnotation(s:current_signs.next_key)
endfunction

call s:getSigns()

au VimLeave * call s:saveSigns()
