" Sign management functions

" The gadamer sign name constant.
let g:gadamer#signs#NAME = 'gadamer'
let g:gadamer#signs#ALT  = 'gadamer-range'

" Create a new sign.
" If varargs are provided, the first argument is used as a name for the sign.
" Otherwise g:gadamer#signs#NAME is used by default
function! gadamer#signs#new(id, line, name = g:gadamer#signs#NAME)
  return {'id': a:id, 'line': a:line, 'name': a:name}
endfunction

" Create a sign from the contents of an annotation.
function! gadamer#signs#fromAnnotation(line, alt = v:false)
  let l:ids = gadamer#signs#getAllIds()
  let l:next_id = empty(l:ids) ? 1 : l:ids[-1] + 1

  if a:alt == v:true
    return gadamer#signs#new(l:next_id, a:line, g:gadamer#signs#ALT)
  endif

  return gadamer#signs#new(l:next_id, a:line)
endfunction

" Initialize sign support.
" This function defines signs to indicate annotations by using the provided
" text as the sign symbol.
function! gadamer#signs#init(text, alt)
  exe "sign define " . g:gadamer#signs#NAME . " text=" . a:text . " texthl=DiffText" . " texthl=DiffText"
  exe "sign define " . g:gadamer#signs#ALT . " text=" . a:alt . " linehl=DiffChange" . " texthl=DiffText"
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
    let regex = '\v^\s+\S+\=(\d+)\s+\S+\=(\d+)\s+\S+\=(.*)$'
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

function! gadamer#signs#loadSign(annotation, buf = expand("%:p"))
  " Place the initial sign.
  let l:sign = gadamer#signs#fromAnnotation(a:annotation.lines.start)
  call gadamer#signs#place(l:sign, a:buf)

  " Place continuation signs for range comments.
  let l:counter = a:annotation.lines.start+1
  while l:counter <= a:annotation.lines.end
    let l:sign = gadamer#signs#fromAnnotation(l:counter, v:true)
    call gadamer#signs#place(l:sign, a:buf)
    let l:counter += 1
  endwhile
endfunction

" Place a gadamer sign. The vararg should be a file. If no file is provided,
" this function places a sign in the current buffer's file.
function! gadamer#signs#place(sign, file = expand("%:p"))
  echo a:sign
  let l:placement = "sign place " . a:sign.id . " line=" . a:sign.line .
              \ " name=" . a:sign.name . " file=" . a:file
  exe l:placement
endfunction
