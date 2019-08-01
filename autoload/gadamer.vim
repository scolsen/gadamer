" Gadamer API functions.  
" Sign definitions.

let s:file_win = winnr()
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
  let ids = map(values(self.signs), 'v:val[id]')
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
    let s:current_signs.signs[line]["id"] = str2nr(tokens[2])
  endfor
endfunction

function! s:placeSign(line, id)
  exe "sign place " . a:id . " line=" . a:line . " name=gadamer file=" . expand("%:p")  
endfunction 

function! s:openAnnotation(line, id)
  let l:fname = s:config.directory . "/" . expand("%:t:r") . "-annotation-" . a:id . ".md"
  " We have to use a script scoped-variable to store a reference to the latest
  " signEntry because a function local variable would go out of scope before we
  " can use it in the call to saveSign. Same deal for the reference to the
  " current line.
  let s:current_line = a:line
  let s:signEntry = {'id': a:id, 'sourceFile': expand("%:p"), 'annoFile': l:fname,}
  let s:current_signs.signs[a:line] = s:signEntry
  
  exe s:config.height . "sp " . fname 
  " Save this sign to the config file when the buffer is exited.
  au QuitPre <buffer> call s:saveSign(s:current_line, s:signEntry)
endfunction

function! s:saveSign(line, signEntry) abort
  redi! >> .gadamer-config
    silent! exe "echo " . "\"" . a:signEntry['sourceFile'] . "\"" . " " . a:line . " " . 
      \ a:signEntry['id'] . " " . "\"" . 
      \ a:signEntry['annoFile'] . "\""
  redi! END
endfunction

function! s:saveSigns()
  " TODO: Determine how to save the configuration to a variable
  " location.
  " let l:save_file = expand("%:p:h") . ".gadamer-config" 
 
  redi! > .gadamer-config
    for [line, signEntry] in items(s:current_signs.signs)
      silent! exe "echo " . "\"" . signEntry['sourceFile'] . "\"" . " " . line . " " . 
      \ signEntry['id'] . " " . "\"" . 
      \ signEntry['annoFile'] . "\"" 
    endfor
  redi! END

endfunction

" Load signs from a saved .gadamer-config
" Then place marks for each.
function! s:loadSigns()
  let saved_signs = readfile(".gadamer-config")[1:]
  for item in saved_signs
    let fields = split(item)
    if fields[0] == expand("%:p")
      let s:current_signs.signs[fields[1]] = 
      \ {'id': fields[2] 'sourceFile': fields[0], 'annoFile': fields[3]}
    endif
  endfor
  for [line, signEntry] in items(s:current_signs.signs)
    call s:placeSign(line, signEntry['id'])
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

function! gadamer#Read(...) abort
  if a:0 > 0
    let line = a:2
  else
    let line = line(".")
  endif
  
  echo s:current_signs.signs
  if has_key(s:current_signs.signs, line("."))
    let anno = get(s:current_signs.signs, line("."))["annoFile"]
    exe s:config.height . "sp " . anno
  else 
    echo "No annotation file found."
  endif
endfunction
 
function! gadamer#List() abort
  let annotations = []
  for [line, signEntry] in items(s:current_signs.signs)
    let anno = "line " . line . ': ' . signEntry["annoFile"]
    call add(annotations, [anno, k])
  endfor

  let annotations_window = maktaba#selector#Create(annotations)
    \.WithMappings(s:key_maps)
  
  call annotations_window.Show()
endfunction

let s:key_maps = {'<CR>' : ['gadamer#Read', 'Return', 'Open an annotation.']}

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
endfunction

call s:startup()
