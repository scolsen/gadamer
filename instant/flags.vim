let [s:plugin, s:enter] = maktaba#plugin#Enter(expand('<sfile>:p'))
if !s:enter
  finish
endif

call s:plugin.Flag('sign', '*')
call s:plugin.Flag('height', 12)
call s:plugin.Flag('directory', '.annotations')
