" Gadamer Commands

if v:version < 801
  echo "Gadamer requires vim version 801 or greater."
  finish
endif

command! -nargs=? GadamerRead call gadamer#Read(<f-args>)
command! -nargs=? GadamerAnnotate call gadamer#Annotate(<f-args>)
command! -nargs=? GadamerList call gadamer#List()
command! GadamerVisualizer call gadamer#Visualize()
