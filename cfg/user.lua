--[[--
  Use this file to specify **User** preferences.
  Review [examples](+C:\Users\Franco\Downloads\ZeroBraneStudio\cfg\user-sample.lua) or check [online documentation](http://studio.zerobrane.com/documentation.html) for details.
--]]--

local G = ...
styles = G.loadfile('cfg/tomorrow.lua')('Molokai') -- Molokai background: {27, 29, 30}

stylesoutshell = styles -- apply the same scheme to Output/Console windows
styles.auxwindow = styles.text -- apply text colors to auxiliary windows
styles.calltip = styles.text -- apply text colors to tooltips

styles.indicator.fncall = nil
styles.indicator.varlocal = nil
styles.indicator.varmasking = {fg = {255,0,0}};
styles.indicator.varmasked = {fg = {255,0,0}};
styles.indicator.varglobal =  { st = wxstc.wxSTC_INDIC_DOTS, fg = {82,80,80} };
styles.fold = {fg = {42,43,44}, bg = {32,33,34} } -- fold color
styles.indent.fg = {48, 49, 50} -- indent color
styles.linenumber = { fg = {98,99,100}, bg = {32,33,34} }

editor.tabwidth = 4
editor.usetabs = false

acandtip.nodynwords = false -- do not offer dynamic (user entered) words; set to false to collect all words from all open editor tabs and offer them as part of the auto-complete list.
acandtip.shorttip = false -- show short calltip when typing; set to false to show a long calltip.

-- TODO: Read fonts from file
output.fontname = "Open Sans"
console.fontname = "Open Sans"
filetree.fontname = "Open Sans"