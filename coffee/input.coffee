###
000  000   000  00000000   000   000  000000000
000  0000  000  000   000  000   000     000   
000  000 0 000  00000000   000   000     000   
000  000  0000  000        000   000     000   
000  000   000  000         0000000      000   
###

{ post, elem, empty, log, $ } = require 'kxk'

class Input

    constructor: ->
        
        @view = $ "#input"
        @plain = ''
        @input = elem class:'input-text', style: 'font-size: 60px'
        @view.appendChild @input
         
    popChar:    (txt) -> txt.substr 0, txt.length-1
    backspace:        -> @setText @popChar @text()
    complete:         -> log 'complete'
    execute:          -> post.emit 'sheet', action:'addText', text:@text()
    appendText: (txt) -> @setText @text() + txt
    textLength:       -> @text().length
    clear:            -> @setText ''
    
    text:  -> @plain
    setText: (@plain) -> 
        @input.innerHTML = @plain
        fs = parseInt @input.style.fontSize
        while fs > 10 and @input.clientWidth > @view.clientWidth
            fs -=1 
            @input.style.fontSize = "#{fs}px"
        while fs < 60 and @input.clientWidth < @view.clientWidth-60
            fs +=1 
            @input.style.fontSize = "#{fs}px"
        post.emit 'input', @plain
        
    # 000   000  00000000  000   000
    # 000  000   000        000 000 
    # 0000000    0000000     00000  
    # 000  000   000          000   
    # 000   000  00000000     000   
    
    globalModKeyComboCharEvent: (mod, key, combo, char, event) ->
        
        switch key
            when 'backspace' then return @backspace()
            when 'tab'       then return @complete()
            when 'enter'     then return @execute()
            else
                if char? then return @appendText char
        # log "unhandled mod:#{mod} key:#{key} combo:#{combo} char:#{char}"
        'unhandled'
    
module.exports = Input
