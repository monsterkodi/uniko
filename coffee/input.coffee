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
    appendText: (txt) -> @setText @text() + txt
    textLength:       -> @text().length
    clear:            -> @setText ''
    
    text:  -> @plain
    setText: (@plain) -> 
        @input.innerHTML = @plain
        fs = parseInt @input.style.fontSize
        log fs, @input.style.fontSize
        while fs > 10 and @input.clientWidth > @view.clientWidth
            fs -=1 
            @input.style.fontSize = "#{fs}px"
        while fs < 60 and @input.clientWidth < @view.clientWidth-60
            fs +=1 
            @input.style.fontSize = "#{fs}px"
        
    # 000   000  00000000  000   000
    # 000  000   000        000 000 
    # 0000000    0000000     00000  
    # 000  000   000          000   
    # 000   000  00000000     000   
    
    globalModKeyComboCharEvent: (mod, key, combo, char, event) ->
        
        switch key
            when 'backspace' then return @backspace()
            else
                if char?
                    # log "mod:#{mod} key:#{key} combo:#{combo} char:#{char}"
                    return @appendText char
        'unhandled'
    
module.exports = Input
