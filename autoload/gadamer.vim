" Gadamer API functions.  
" Sign definitions.

let s:current_signs = {} 
let s:current_signs.signs = {}
let s:next_key = 0

let s:global_prefix = "g:gadamer_"
let s:config = {}
let s:config.signchar = '*'
let s:config.height = 12
let s:config.directory = '.annotations'

" Set the value of the script-local signs
" to that of user configured globals
" if they exist.
function! s:getConfig() 
  for key in keys(s:config)
    let gvar = s:global_prefix . key
    if exists(gvar)
      let val = split(execute("echo " . gvar), '\n')[0]
      echo val
      exe "let " . "s:config." . key . "=" . '"' . val . '"'
    endif
  endfor
endfunction

function! s:current_signs.ids() 
  let ids = map(values(self.signs), 'v:val[0]')
  return sort(ids, 'n')
endfunction

function! s:current_signs.getNextKey()
  if self.ids() == []
    let self.next_key = 1
  else
    let self.next_key = self.ids()[-1] + 1
  endif
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
    let line = str2nr(tokens[1])
    let s:current_signs.signs[line] = [str2nr(tokens[2])]
  endfor
endfunction

function! s:placeSign(line, id)
  exe "sign place " . a:id . " line=" . a:line . " name=gadamer file=" . expand("%:p")  
endfunction 

function! s:openAnnotation(line, id)
  let fname = s:config.directory . "/" . expand("%:r") . "-annotation-" . a:id . ".md"
  let s:current_signs.signs[a:line] = [a:id, fname] 
  exe s:config.height . "sp " . fname 
endfunction

function! s:saveSigns()
  let l:save_file = "." . expand("%:r") . "gadamer-config" 

  redi! > .gadamer-config
    for key in keys(s:current_signs.signs)
      silent! exe "echo " . "\"" . expand("%") . "\"" . " " . key . " " . get(s:current_signs.signs, key)[0] . " " . "\"" . get(s:current_signs.signs, key)[1] . "\"" 
    endfor
  redi! END
endfunction

" Load signs from a saved .gadamer-config
" Then place marks for each.
function! s:loadSigns()
  let saved_signs = readfile(".gadamer-config")[1:]
  for item in saved_signs
    let fields = split(item)
    if fields[0] == expand("%")
      let s:current_signs.signs[fields[1]] = [fields[2], fields[3]] 
    endif
  endfor
  for [k, v] in items(s:current_signs.signs)
    call s:placeSign(k, v[0])
  endfor
endfunction

" Do everything we need to do to annotate a file.
" Create a buffer, create a mark, on save, save the contents.
" Maintain an association of file<->annotation.
function! gadamer#Annotate() abort
  call s:current_signs.getNextKey()
  call s:placeSign(line("."), s:current_signs.next_key)
  call s:openAnnotation(line("."), s:current_signs.next_key)
endfunction

function! gadamer#Read()
  echo s:current_signs.signs
  if has_key(s:current_signs.signs, line("."))
    let anno = get(s:current_signs.signs, line("."))[1]
    exe s:config.height . "sp " . anno
  else 
    echo "No annotation file found."
  endif
endfunction

function! s:startup() abort
  call s:getConfig()
  exe "sign define gadamer text=" . s:config.signchar 
  call s:getSigns()
  
  if filereadable(".gadamer-config")
    call s:loadSigns()
  endif

  if !isdirectory(s:config.directory)
    call mkdir(s:config.directory)
  endif

  au VimLeave * call s:saveSigns()
endfunction

call s:startup()
