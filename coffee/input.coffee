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
        @input = elem 'input', type:'input', class:'input-text', style: 'font-size: 60px;', autofocus:true, size:1
        @view.appendChild @input
        @view.addEventListener 'click', => @input.focus()
        @input.addEventListener 'input',  @onInputChanged
        @input.addEventListener 'blur',   @onBlur
        
        post.on 'input', @onInput
    
    onBlur: (event) => @clearSelection()
        
    onInput: (opt) =>
        
        opt ?= {}
        switch opt.action
            when 'setText' then @setText opt.text
            else 
                log 'onInput', opt
        
    onInputChanged: => 
        @plain = @input.value
        @sizeInput()
        
    focus:            -> @input.focus()
    hasFocus:         -> document.activeElement == @input
    hasSelection:     -> @input.selectionEnd - @input.selectionStart != 0
    clearSelection:   -> @input.setSelectionRange @input.selectionEnd, @input.selectionEnd
    
    popChar:    (txt) -> txt.substr 0, txt.length-1
    backspace:        -> @setText @popChar @text()
    complete:         -> log 'complete'
    appendText: (txt) -> @setText @text() + txt
    textLength:       -> @text().length
    clear:            -> @setText '' ; @focus()
    execute: => 
        
        if @hasFocus() 
            log 'execute'
            post.emit 'exec', @text()
    
    text:  -> @plain
    setText: (@plain) -> 
        @input.value = @plain
        @sizeInput()
        
    sizeInput: ->
        
        @input.setAttribute 'size', str Math.max 1, @plain.length+1
        fs = parseInt @input.style.fontSize
        while fs > 2 and @input.clientWidth > @view.clientWidth-60
            fs -=1 
            @input.style.fontSize = "#{fs}px"
        while fs < 60 and @input.clientWidth < @view.clientWidth-60
            fs +=1 
            @input.style.fontSize = "#{fs}px"
                        
        post.emit 'inputChanged', @plain
        
    # 000   000  00000000  000   000
    # 000  000   000        000 000 
    # 0000000    0000000     00000  
    # 000  000   000          000   
    # 000   000  00000000     000   
    
    globalModKeyComboCharEvent: (mod, key, combo, char, event) ->
        
        switch key
            when 'tab' then return @complete()
            when 'enter' then return @execute()
        # log "unhandled mod:#{mod} key:#{key} combo:#{combo} char:#{char}"
        'unhandled'
    
module.exports = Input
