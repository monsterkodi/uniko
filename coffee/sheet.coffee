### 
 0000000  000   000  00000000  00000000  000000000
000       000   000  000       000          000   
0000000   000000000  0000000   0000000      000   
     000  000   000  000       000          000   
0000000   000   000  00000000  00000000     000   
###

{ post, elem, last, prefs, str, log, $, _ } = require 'kxk'

class html
    
    @pop: (text) -> text.slice 0, text.length - 1

class Sheet

    constructor: ->
        
        @view = $ "#sheet"
        @setFontSize prefs.get 'sheet:fontSize', 60
        @view.addEventListener 'wheel', @onWheel
        post.on 'sheet', @onSheet
    
    spanForChar: (char) -> 
        log "spanForChar #{char}"
        "<span class=\"unicodeChar\">&##{char};</span>"
        
    empty:            -> @view.children.length == 0
    clear:            -> @view.innerHTML = ''
    setText:  (text)  -> @clear(); @addText text
    addText:  (text)  -> @view.appendChild elem class:'sheet text', html:str(text)
    addChars: (chars) -> @addText chars.map((c) => @spanForChar(c)).join ''
    addChar:  (char)  -> if not @empty() then last(@view.children).innerHTML += @spanForChar(char) else @addText @spanForChar char
    backspace:        -> if not @popChar() then log 'backspace text?'
    popChar:          -> 
        if not @empty() 
            last(@view.children).innerHTML = html.pop last(@view.children).innerHTML
            true
        false

    # 00000000   0000000   000   000  000000000   0000000  000  0000000  00000000  
    # 000       000   000  0000  000     000     000       000     000   000       
    # 000000    000   000  000 0 000     000     0000000   000    000    0000000   
    # 000       000   000  000  0000     000          000  000   000     000       
    # 000        0000000   000   000     000     0000000   000  0000000  00000000  
    
    resetFontSize:      -> @setFontSize 60
    getFontSize:        -> parseInt window.getComputedStyle(@view, null).getPropertyValue 'font-size'
    
    changeFontSize: (d) -> @setFontSize d + @getFontSize()
        
    setFontSize:    (s) -> 
        @view.style.fontSize = "#{s}px" 
        prefs.set 'sheet:fontSize', s
        
    monospace: -> 
        @view.style.fontFamily = if @view.style.fontFamily then '' else 'monospace' #'"Meslo LG S", "Liberation Mono", "Menlo", "Cousine", "Andale Mono", monospace'
        log '@view.style.fontFamily', @view.style.fontFamily
        
    onWheel: (event) => 
        if event.ctrlKey then @changeFontSize parseInt -event.deltaY/100
            
    #  0000000   000   000   0000000  000   000  00000000  00000000  000000000  
    # 000   000  0000  000  000       000   000  000       000          000     
    # 000   000  000 0 000  0000000   000000000  0000000   0000000      000     
    # 000   000  000  0000       000  000   000  000       000          000     
    #  0000000   000   000  0000000   000   000  00000000  00000000     000     
    
    onSheet: (opt) =>
        
        opt ?= {}
        switch opt.action
            when 'clear'     then @clear()
            when 'setText'   then @setText opt.text
            when 'addText'   then @addText opt.text
            when 'addChar'   then @addChar opt.char
            when 'addChars'  then @addChars opt.chars
            when 'fontSize'  then @setFontSize opt.fontSize
            when 'backspace' then @backspace()
            when 'monospace' then @monospace()
            else
                log 'onSheet', opt

module.exports = Sheet
