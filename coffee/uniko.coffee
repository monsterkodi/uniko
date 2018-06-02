###
000   000  000   000  000  000   000   0000000   
000   000  0000  000  000  000  000   000   000  
000   000  000 0 000  000  0000000    000   000  
000   000  000  0000  000  000  000   000   000  
 0000000   000   000  000  000   000   0000000   
###

{ args, keyinfo, title, scheme, stopEvent, prefs, slash, post, elem, popup, pos, str, log, $, _ } = require 'kxk'

prefs.init()

log 'args', args

Funcs     = require './funcs'
Exec      = require './exec'
Input     = require './input'
Parse     = require './parse'
Group     = require './group'
Valid     = require './valid'
Sheet     = require './sheet'
Menu      = require './menu'
electron  = require 'electron'
pkg       = require '../package.json'

clipboard = electron.clipboard
remote    = electron.remote
win       = window.win = remote.getCurrentWindow()

# 000       0000000    0000000   0000000
# 000      000   000  000   000  000   000
# 000      000   000  000000000  000   000
# 000      000   000  000   000  000   000
# 0000000   0000000   000   000  0000000

post.on 'reload', -> win.webContents.reloadIgnoringCache()
post.on 'schemeChanged', -> 
post.on 'menuAction', (action, args) -> menuAction action, args

window.onunload = -> document.onkeydown = null

# 00     00  00000000  000   000  000   000      0000000    0000000  000000000  000   0000000   000   000
# 000   000  000       0000  000  000   000     000   000  000          000     000  000   000  0000  000
# 000000000  0000000   000 0 000  000   000     000000000  000          000     000  000   000  000 0 000
# 000 0 000  000       000  0000  000   000     000   000  000          000     000  000   000  000  0000
# 000   000  00000000  000   000   0000000      000   000   0000000     000     000   0000000   000   000

menuAction = (name, args) ->

    switch name

        when 'Reset'                then return window.input.clear()
        when 'Clear'                then return window.sheet.clear()
        when 'Cut'                  then return window.sheet.cut()
        when 'Font Size Reset'      then return window.sheet.resetFontSize()
        when 'Font Size Increase'   then return window.sheet.changeFontSize +1
        when 'Font Size Decrease'   then return window.sheet.changeFontSize -1
        
    post.toMain 'menuAction', name, args
        
# 000   000  00000000  000   000
# 000  000   000        000 000
# 0000000    0000000     00000
# 000  000   000          000
# 000   000  00000000     000

window.onresize = -> window.input.setText window.input.text()

# 000000000  000  000000000  000      00000000  
#    000     000     000     000      000       
#    000     000     000     000      0000000   
#    000     000     000     000      000       
#    000     000     000     0000000  00000000  

window.titlebar = new title
    pkg:    pkg 
    menu:   __dirname + '/../coffee/menu.noon' 
    icon:   __dirname + '/../img/menu@2x.png'

#  0000000   0000000   000   000  000000000  00000000  000   000  000000000  
# 000       000   000  0000  000     000     000        000 000      000     
# 000       000   000  000 0 000     000     0000000     00000       000     
# 000       000   000  000  0000     000     000        000 000      000     
#  0000000   0000000   000   000     000     00000000  000   000     000     

$("#main").addEventListener "contextmenu", (event) ->
    
    absPos = pos event
    if not absPos?
        absPos = pos $("#main").getBoundingClientRect().left, $("#main").getBoundingClientRect().top
       
    items = _.clone window.titlebar.menuTemplate()
    items.unshift text:'Clear', accel:'ctrl+k'
        
    popup.menu
        items:  items
        x:      absPos.x
        y:      absPos.y
    
# 000   000  00000000  000   000
# 000  000   000        000 000
# 0000000    0000000     00000
# 000  000   000          000
# 000   000  00000000     000

window.onunload = -> document.onkeydown = null
document.onkeydown = (event) ->

    return stopEvent(event) if 'unhandled' != window.titlebar.handleKey event, true
    
    { mod, key, combo, char } = keyinfo.forEvent event

    return if not combo
    
    return stopEvent(event) if 'unhandled' != window.input.globalModKeyComboCharEvent mod, key, combo, char, event
    
    switch combo
        when 'command+i', 'ctrl+i', 'alt+i' then scheme.toggle()
        when 'ctrl+='                       then menuAction 'Font Size Increase'
        when 'ctrl+-'                       then menuAction 'Font Size Decrease'
        when 'ctrl+0'                       then menuAction 'Font Size Reset'
        when 'ctrl+x', 'delete'             then window.sheet.cut()
        when 'esc'                          then menuAction 'Reset'
        
    null

window.input    = new Input
window.parse    = new Parse
window.group    = new Group
window.valid    = new Valid
window.sheet    = new Sheet
window.exec     = new Exec

scheme.set prefs.get 'scheme', 'dark'

window.group.addGroups ''
