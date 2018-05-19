### 
 0000000  000   000  00000000  00000000  000000000
000       000   000  000       000          000   
0000000   000000000  0000000   0000000      000   
     000  000   000  000       000          000   
0000000   000   000  00000000  00000000     000   
###

{ post, elem, log, $, _ } = require 'kxk'

class Sheet

    constructor: ->
        
        @view = $ "#sheet"
        post.on 'sheet', @onSheet
     
    clear:          -> @view.innerHTML = ''
    setText: (text) -> @clear(); @addText text
    addText: (text) -> 
        @view.appendChild elem class:'sheet greet', text:text
        
    onSheet: (opt) =>
        
        opt ?= {}
        switch opt.action
            when 'clear'   then @clear()
            when 'setText' then @setText opt.text
            when 'addText' then @addText opt.text
            else
                log 'onSheet', opt

module.exports = Sheet
