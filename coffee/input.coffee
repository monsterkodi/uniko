###
000  000   000  00000000   000   000  000000000
000  0000  000  000   000  000   000     000   
000  000 0 000  00000000   000   000     000   
000  000  0000  000        000   000     000   
000  000   000  000         0000000      000   
###

{ post, elem, empty, str, log, $ } = require 'kxk'

class Input

    constructor: ->
        
        @view  = $ "#input"
        @plain = ''
        @input = elem 'input', type:'text', class:'input-text', style: 'font-size: 60px', autofocus:true, size:1
        @view.appendChild @input
        @view.addEventListener 'click', => @input.focus()
        
        @input.addEventListener 'input', @onInput
        @input.addEventListener 'change', @execute
        
    onInput: => 
        @plain = @input.value
        @sizeInput()
         
    popChar:    (txt) -> txt.substr 0, txt.length-1
    backspace:        -> @setText @popChar @text()
    complete:         -> log 'complete'
    execute:          => post.emit 'exec', @text()
    appendText: (txt) -> @setText @text() + txt
    textLength:       -> @text().length
    clear:            -> @setText ''
    
    text:  -> @plain
    setText: (@plain) -> 
        @input.value = @plain
        @sizeInput()
        
    sizeInput: ->
        # @input.setAttribute 'size', Math.max 1, str parseInt @plain.length*1.3
        @input.setAttribute 'size', Math.max 1, str parseInt @plain.length+1
        fs = parseInt @input.style.fontSize
        while fs > 4 and @input.clientWidth > @view.clientWidth-60
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
            # when 'backspace' then return @backspace()
            when 'tab'       then return @complete()
            # when 'enter'     then return @execute()
            # else
                # if char? then return @appendText char
        # log "unhandled mod:#{mod} key:#{key} combo:#{combo} char:#{char}"
        'unhandled'
    
module.exports = Input
