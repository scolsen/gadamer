let s:mappings =
  \ { '<CR>': {'mapping': 'g:gadamer#visualizer.openAnnotation()', 'help': 'Open an annotation.'},
  \   'q': {'mapping': 'g:gadamer#visualizer.close()', 'help': 'Close the list window.'},}

let s:local_options =
  \ [{'option': 'readonly'}, {'option': 'noswapfile'},
  \  {'option': 'cursorline'},
  \  {'option': 'bufhidden', 'value': 'delete'},
  \  {'option': 'buftype', 'value': 'nofile'},
  \  {'option': 'scrollbind'},]
let s:window_options =
  \ {'position': 'rightb', 'size': 40, 'cmd': 'vnew'}
let s:help_text = "========= End of annotations for this file. ========"

let gadamer#visualizer = gadamer#mode#new(s:mappings, s:window_options, s:local_options, s:help_text)

let gadamer#visualizer.max_line = 1
let gadamer#visualizer.help_pos = 'bot'

function! gadamer#visualizer.close()
  let self.max_line = 1
  :q
endfunction

function! gadamer#visualizer.openAnnotation()
  let l:selections =
    \ filter(copy(self.annotations),
    \ {_, val -> val.lines.start == line(".")})

  " We couldn't find any annotations by starting line, try searching by ending
  " line.
  if empty(l:selections)
    let l:selections =
      \ filter(copy(self.annotations),
      \ {_, val -> val.lines.end == line(".")})
  endif

  " We still couldn't find anything. Tell the user and return.
  if empty(l:selections) 
    echo "Unknown annotation"
    return
  endif

  if len(l:selections) == 1
    call g:gadamer#view.open(l:selections)
  else
    call g:gadamer#list.open(l:selections)
  endif
endfunction

function! gadamer#visualizer.prepare()
  " set scrollbind on the previous buffer
  set scrollbind
endfunction

function! gadamer#visualizer.onInvocation(annotation)
  let l:counter = a:annotation.lines.start+1

  " Add new lines until we can add the annotation anchor to the correct
  " position.
  while self.max_line <= a:annotation.lines.start
    call append(self.max_line, '')
    let self.max_line += 1
  endwhile

  let l:file = split(a:annotation.annotation_file, "/")[-1]
  
  if getline(a:annotation.lines.start) ==? ''
    call setline(a:annotation.lines.start, l:file)
  end

  while l:counter <= a:annotation.lines.end
    let l:dots = getline(l:counter) . '.'

    call setline(l:counter, l:dots)
    let l:counter += 1
  endwhile
endfunction

function! gadamer#visualizer#init() abort
endfunction
