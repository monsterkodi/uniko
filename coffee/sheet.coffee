### 
 0000000  000   000  00000000  00000000  000000000
000       000   000  000       000          000   
0000000   000000000  0000000   0000000      000   
     000  000   000  000       000          000   
0000000   000   000  00000000  00000000     000   
###

{ post, elem, last, log, $, _ } = require 'kxk'

class Sheet

    constructor: ->
        
        @view = $ "#sheet"
        post.on 'sheet', @onSheet
     
    clear:          -> @view.innerHTML = ''
    setText: (text) -> @clear(); @addText text
    addText: (text) -> @view.appendChild elem class:'sheet text', html:text
    addChar: (char) -> if @view.children.length then last(@view.children).innerHTML += char else @addText char
        
    onSheet: (opt) =>
        
        opt ?= {}
        switch opt.action
            when 'clear'   then @clear()
            when 'setText' then @setText opt.text
            when 'addText' then @addText opt.text
            when 'addChar' then @addChar opt.char
            else
                log 'onSheet', opt

module.exports = Sheet
