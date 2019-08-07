" Sign management functions

" The gadamer sign name constant.
let g:gadamer#signs#NAME = 'gadamer'

" Create a new sign.
function! gadamer#signs#new(id, line, name) 
  return {'id': a:id, 'line': a:line, 'name': a:name}
endfunction

" Initialize sign support. 
" This function defines signs to indicate annotations by using the provided
" text as the sign symbol.
function! gadamer#signs#init(text)
  exe "sign define " . g:gadamer#signs#NAME . " text=" . a:text
endfunction

" Returns a list containing all the signs in a file. This is needed on startup
" to ascertain what number we should use for gadamer sign ids (necessary to
" 'unplace' signs after annotation removal). We cannot conflict with signs from
" other plugins or user defined signs, so we need to be cautious.
function! gadamer#signs#getAllSigns()
  let l:signs = []
  
  redi => placed_signs 
    silent! exe 'sign place file=' . expand("%:p")
  redi END
  
  " shamefully cribbed from signify.vim
  " https://github.com/mhinz/vim-signify
  for signl in split(placed_signs, '\n')[2:]
    let regex = '\v^\s+\S+\=(\d+)\s+\S+\=(\d+)\s+\S+\=(\S+)\s+\S+=(.*)$'
    let l:tokens = matchlist(signl, regex)
    
    let l:line = str2nr(l:tokens[1])
    let l:id  = str2nr(l:tokens[2])
    let l:name = tokens[3]
    call add(l:signs, gadamer#signs#new(l:id, l:line, l:name))
  endfor
  
  return l:signs
endfunction

" Get a list of signs added by gadamer.
function! gadamer#signs#getGadamerSigns()
  return filter(gadamer#signs#getAllSigns(), 
       \ {idx, val -> get(value, 'name') == g:gadamer#signs#NAME})
endfunction

" Returns a list of the ids of all the placed signs in a file.
function! gadamer#signs#getAllIds()
  let l:ids = map(gadamer#signs#getAllSigns(), {idx, val -> get(val, 'id')})
  return sort(l:ids)
endfunction

" Place a gadamer sign.
function! gadamer#signs#place(sign)
  l:placement = "sign place " . a:sign.id . " line=" . a:sign.line . 
              \ " name=" . g:gadamer#signs#NAME . " file=" . expand("%:p")
  exe l:placement
endfunction 