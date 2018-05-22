###
000   000  000   000  000  000   000   0000000   
000   000  0000  000  000  000  000   000   000  
000   000  000 0 000  000  0000000    000   000  
000   000  000  0000  000  000  000   000   000  
 0000000   000   000  000  000   000   0000000   
###

{ keyinfo, scheme, stopEvent, prefs, slash, post, elem, popup, pos, str, log, $ } = require 'kxk'

Exec      = require './exec'
Input     = require './input'
Parse     = require './parse'
Group     = require './group'
Valid     = require './valid'
Sheet     = require './sheet'
Menu      = require './menu'
Titlebar  = require './title'
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
        text:   'Cut'
        combo:  'ctrl+x'
        cb:     -> post.emit 'menuAction', 'Cut'
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

        when 'Toggle Scheme'        then return scheme.toggle()
        when 'Toggle Menu'          then return window.menu.toggle()
        when 'Show Menu'            then return window.menu.show()
        when 'Hide Menu'            then return window.menu.hide()
        when 'DevTools'             then return win.webContents.openDevTools()
        when 'Reload'               then return win.webContents.reloadIgnoringCache()
        when 'Close Window'         then return win.close()
        when 'Reset'                then return window.input.clear()
        when 'Clear'                then return window.sheet.clear()
        when 'Cut'                  then return window.sheet.cut()
        when 'Minimize'             then return win.minimize()
        when 'Maximize'             then if win.isMaximized() then win.unmaximize() else win.maximize()        
        when 'Font Size Reset'      then return window.sheet.resetFontSize()
        when 'Font Size Increase'   then return window.sheet.changeFontSize +1
        when 'Font Size Decrease'   then return window.sheet.changeFontSize -1
        
    # log "unhandled menu action! ------------ posting to main '#{name}' args: #{args}"
    
    post.toMain 'menuAction', name, args
        
# 000   000  00000000  000   000
# 000  000   000        000 000
# 0000000    0000000     00000
# 000  000   000          000
# 000   000  00000000     000

window.onresize = -> window.input.setText window.input.text()

document.onkeydown = (event) ->

    { mod, key, combo, char } = keyinfo.forEvent event

    return if not combo

    # switch combo
        # when 'ctrl+x' 
            # if not window.input.hasFocus() 
                # return stopEvent event, menuAction 'Cut'
    
    return stopEvent(event) if 'unhandled' != window.input.globalModKeyComboCharEvent mod, key, combo, char, event
    return stopEvent(event) if 'unhandled' != window.menu.globalModKeyComboEvent mod, key, combo, event
    
    # log combo
    
    switch combo
        when 'command+i', 'ctrl+i', 'alt+i' then scheme.toggle()
        when 'ctrl+='                       then menuAction 'Font Size Increase'
        when 'ctrl+-'                       then menuAction 'Font Size Decrease'
        when 'ctrl+0'                       then menuAction 'Font Size Reset'
        when 'ctrl+x', 'delete'             then window.sheet.cut()
        when 'esc'                          then menuAction 'Reset'
        
    null

prefs.init()
scheme.set prefs.get 'scheme', 'dark'
window.titlebar = new Titlebar 
window.input    = new Input
window.parse    = new Parse
window.group    = new Group
window.valid    = new Valid
window.sheet    = new Sheet
window.exec     = new Exec
window.menu     = new Menu

post.emit 'group', action:'addGroups', groups:''
