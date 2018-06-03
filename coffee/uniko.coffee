###
000   000  000   000  000  000   000   0000000   
000   000  0000  000  000  000  000   000   000  
000   000  000 0 000  000  0000000    000   000  
000   000  000  0000  000  000  000   000   000  
 0000000   000   000  000  000   000   0000000   
###

{ win, stopEvent, slash, post, elem, pos, str, log, $, _ } = require 'kxk'

w = new win 
    dir:    __dirname
    pkg:    require '../package.json'
    menu:   '../coffee/menu.noon'
    icon:   '../img/menu@2x.png'

Funcs = require './funcs'
Exec  = require './exec'
Input = require './input'
Parse = require './parse'
Group = require './group'
Valid = require './valid'
Sheet = require './sheet'

window.onresize = -> window.input.setText window.input.text()

# 00     00  00000000  000   000  000   000      0000000    0000000  000000000  000   0000000   000   000
# 000   000  000       0000  000  000   000     000   000  000          000     000  000   000  0000  000
# 000000000  0000000   000 0 000  000   000     000000000  000          000     000  000   000  000 0 000
# 000 0 000  000       000  0000  000   000     000   000  000          000     000  000   000  000  0000
# 000   000  00000000  000   000   0000000      000   000   0000000     000     000   0000000   000   000

onMenuAction = (action, args) ->

    switch action

        when 'Reset'                then return window.input.clear()
        when 'Clear'                then return window.sheet.clear()
        when 'Cut'                  then return window.sheet.cut()
        when 'Font Size Reset'      then return window.sheet.resetFontSize()
        when 'Font Size Increase'   then return window.sheet.changeFontSize +1
        when 'Font Size Decrease'   then return window.sheet.changeFontSize -1
        
post.on 'menuAction', onMenuAction
    
# 000   000  00000000  000   000
# 000  000   000        000 000
# 0000000    0000000     00000
# 000  000   000          000
# 000   000  00000000     000

onCombo = (combo, info) ->

    return stopEvent(info.event) if 'unhandled' != window.input.globalModKeyComboCharEvent info.mod, info.key, info.combo, info.char, info.event
    
    switch combo
        when 'ctrl+='           then menuAction 'Font Size Increase'
        when 'ctrl+-'           then menuAction 'Font Size Decrease'
        when 'ctrl+0'           then menuAction 'Font Size Reset'
        when 'ctrl+x', 'delete' then window.sheet.cut()
        when 'esc'              then menuAction 'Reset'
        
post.on 'combo', onCombo        
        
# 000   000  000  000   000  
# 000 0 000  000  0000  000  
# 000000000  000  000 0 000  
# 000   000  000  000  0000  
# 00     00  000  000   000  
    
window.input = new Input
window.parse = new Parse
window.group = new Group
window.valid = new Valid
window.sheet = new Sheet
window.exec  = new Exec

window.group.addGroups ''
