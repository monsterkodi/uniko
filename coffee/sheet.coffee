### 
 0000000  000   000  00000000  00000000  000000000
000       000   000  000       000          000   
0000000   000000000  0000000   0000000      000   
     000  000   000  000       000          000   
0000000   000   000  00000000  00000000     000   
###

{ post, elem, last, log, $, _ } = require 'kxk'

class html
    
    @pop: (text) -> text.slice 0, text.length - 1

class Sheet

    constructor: ->
        
        @view = $ "#sheet"
        post.on 'sheet', @onSheet
     
    empty:          -> @view.children.length == 0
    clear:          -> @view.innerHTML = ''
    setText: (text) -> @clear(); @addText text
    addText: (text) -> @view.appendChild elem class:'sheet text', html:text
    addChar: (char) -> if not @empty() then last(@view.children).innerHTML += char else @addText char
    backspace:      -> if not @popChar() then log 'backspace text?'
    popChar:        -> 
        if not @empty() 
            last(@view.children).innerHTML = html.pop last(@view.children).innerHTML
            true
        false
    
    onSheet: (opt) =>
        
        opt ?= {}
        switch opt.action
            when 'clear'     then @clear()
            when 'setText'   then @setText opt.text
            when 'addText'   then @addText opt.text
            when 'addChar'   then @addChar opt.char
            when 'backspace' then @backspace()
            else
                log 'onSheet', opt

module.exports = Sheet
