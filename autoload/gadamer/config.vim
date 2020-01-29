" Gadamer configuration.

" Plugin options prefix.
"
" All Gadamer options must begin with this prefix. Users should use it to
" specify options, and gadamer components must use it to access configuration
" options.
let gadamer#global_prefix = "g:gadamer_"

" Valid configuration options for Gadamer.
"
" Only these option names are recognized by the Plugin. Each is set to a default
" value. User values should follow the example of the defaults.
let gadamer#config = {}

" The character to use to indicate annotated lines in a file.
" This character is displayed in the signs column whenever an annotation exists
" for a given line.
let gadamer#config.signchar = "※"
let gadamer#config.alt_sign = "|"

" The default height of Gadamer windows.
let gadamer#config.height = 12

" The directory in which to save annotation files.
let gadamer#config.directory = ".annotations"

" Set the value of the plugin configuration to that of user configured globals,
" if they exist.
function! gadamer#config#init()
  for key in keys(g:gadamer#config)
    let gvar = g:gadamer#global_prefix . key
    if exists(gvar)
      let val = split(execute("echo " . gvar), '\n')[0]
      echo val
      exe "let " . "g:gadamer#config." . key . "=" . '"' . val . '"'
    endif
  endfor
  return g:gadamer#config
endfunction


