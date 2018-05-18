###
000   000  000   000  000  000   000   0000000   
000   000  0000  000  000  000  000   000   000  
000   000  000 0 000  000  0000000    000   000  
000   000  000  0000  000  000  000   000   000  
 0000000   000   000  000  000   000   0000000   
###

{ keyinfo, scheme, stopEvent, prefs, slash, post, elem, popup, pos, str, log, $ } = require 'kxk'

Input     = require './input'
Menu      = require './menu'
Titlebar  = require './titlebar'
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

$("#main").addEventListener "contextmenu", (event) ->
    
    absPos = pos event
    if not absPos?
        absPos = pos $("#main").getBoundingClientRect().left, $("#main").getBoundingClientRect().top
        
    opt = items: [
        text:   'Clear'
        combo:  'ctrl+k'
        cb:     -> post.emit 'menuAction', 'Clear'
    ,
        text:   'Toggle Menu'
        combo:  'alt+m'
        cb:     -> post.emit 'menuAction', 'Toggle Menu'
    ]
    
    opt.x = absPos.x
    opt.y = absPos.y

    popup.menu opt
    
window.onunload = -> document.onkeydown = null

# 00     00  00000000  000   000  000   000      0000000    0000000  000000000  000   0000000   000   000
# 000   000  000       0000  000  000   000     000   000  000          000     000  000   000  0000  000
# 000000000  0000000   000 0 000  000   000     000000000  000          000     000  000   000  000 0 000
# 000 0 000  000       000  0000  000   000     000   000  000          000     000  000   000  000  0000
# 000   000  00000000  000   000   0000000      000   000   0000000     000     000   0000000   000   000

menuAction = (name, args) ->

    switch name

        when 'Toggle Scheme'    then return scheme.toggle()
        when 'Toggle Menu'      then return window.menu.toggle()
        when 'Show Menu'        then return window.menu.show()
        when 'Hide Menu'        then return window.menu.hide()
        when 'Open DevTools'    then return win.webContents.openDevTools()
        when 'Reload Window'    then return win.webContents.reloadIgnoringCache()
        when 'Close Window'     then return win.close()
        when 'Clear'            then return window.input.clear()
        when 'Minimize'         then return win.minimize()
        when 'Maximize'         then if win.isMaximized() then win.unmaximize() else win.maximize()        
        
    # log "unhandled menu action! ------------ posting to main '#{name}' args: #{args}"
    
    post.toMain 'menuAction', name, args
    
#  0000000   0000000   00000000   000   000        00000000    0000000    0000000  000000000  00000000    
# 000       000   000  000   000   000 000         000   000  000   000  000          000     000         
# 000       000   000  00000000     00000          00000000   000000000  0000000      000     0000000     
# 000       000   000  000           000           000        000   000       000     000     000         
#  0000000   0000000   000           000           000        000   000  0000000      000     00000000    
    
copy = ->
    clipboard?.writeText window.input.text()

paste = ->
    window.input.setText clipboard?.readText()
    
cut = ->
    copy()
    window.input.clear()
    
# 000   000  00000000  000   000
# 000  000   000        000 000
# 0000000    0000000     00000
# 000  000   000          000
# 000   000  00000000     000

window.onresize = -> window.input.setText window.input.text()

document.onkeydown = (event) ->

    { mod, key, combo, char } = keyinfo.forEvent event

    return if not combo

    return stopEvent(event) if 'unhandled' != window.menu.globalModKeyComboEvent mod, key, combo, event
    return stopEvent(event) if 'unhandled' != window.input.globalModKeyComboCharEvent mod, key, combo, char, event
    
    switch combo
        when 'i', 'command+i', 'ctrl+i', 'alt+i' then return scheme.toggle()
        when 'ctrl+v'                            then return paste()
        when 'ctrl+c'                            then return copy()
        when 'ctrl+x'                            then return cut()
        when 'esc', 'delete'                     then menuAction 'Clear'

prefs.init()
scheme.set prefs.get 'scheme', 'dark'
window.titlebar = new Titlebar 
window.input    = new Input
window.menu     = new Menu
