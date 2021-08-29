" Lightweight implementation of sets

let gadamer#set = {}

" Set membership
function! gadamer#set.member(key) 
  return has_key(self, item)
endfunction

function! gadamer#set.add(key, value)
  if self.member(a:key)
    return
  endif 

  self[a:key] = a:value
endfunction

function! gadamer#set.remove(key)
  if !self.member(a:key)
    return
  endif

  call remove(self[a:key])
endfunction

function! gadamer#set.update(key, value)
  if !self.member(a:key)
    call self.add(a:key, a:value)
    return
  endif 

  let self[a:key] = a:value
endfunction

function! gadamer#set.new() 
  return deepcopy(self)
endfunction
