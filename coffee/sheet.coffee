### 
 0000000  000   000  00000000  00000000  000000000
000       000   000  000       000          000   
0000000   000000000  0000000   0000000      000   
     000  000   000  000       000          000   
0000000   000   000  00000000  00000000     000   
###

{ post, elem, last, prefs, str, log, $, _ } = require 'kxk'

{ stringToChars, stringPop, stringToRanges, rangesToString, 
  validChar, rangeToChars, spanForChar, htmlForChars } = require './funcs'

class Sheet

    constructor: ->
        
        @view = $ "#sheet"
        @setFontSize prefs.get 'sheet:fontSize', 60
        @view.addEventListener 'wheel', @onWheel
        @view.addEventListener 'mousemove', @onMouseMove
        @view.addEventListener 'click', @onMouseClick
        
        post.on 'sheet', @onSheet
        
    empty:            -> @view.children.length == 0
    clear:            -> @view.innerHTML = ''
    setText:  (text)  -> @clear(); @addText text
    elemForText: (text) -> elem class:'sheet text', html:str text
    addText:  (text)  -> @view.appendChild @elemForText text
    insertText: (text,after) -> after.parentNode.insertBefore @elemForText(text), after.nextSibling
    addChar:  (char)  -> if not @empty() then last(@view.children).innerHTML += spanForChar(char) else @addText spanForChar char
    backspace:        -> if not @popChar() then log 'backspace text?'
    addChars: (chars) -> @addText htmlForChars chars.filter (c) -> window.valid.char c
    addGroup: (group) -> @view.appendChild elem class:'sheet group', html:group
        
    popChar: -> 
        if not @empty() 
            last(@view.children).innerHTML = stringPop last(@view.children).innerHTML
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
         
    # 00     00   0000000   000   000   0000000  00000000
    # 000   000  000   000  000   000  000       000     
    # 000000000  000   000  000   000  0000000   0000000 
    # 000 0 000  000   000  000   000       000  000     
    # 000   000   0000000    0000000   0000000   00000000
    
    onMouseMove: (event) =>
        
        selection = document.getSelection().toString()
        
        if selection.length and not window.input.hasSelection()
            # log 'win', selection.length, selection
            post.emit 'input', action:'setText', text:rangesToString stringToRanges selection
            return
            
        t = event.target.innerText
        if t.length <= 2 and t.codePointAt 0 
            if not window.valid.char t.codePointAt 0 
                log "invalid #{t.codePointAt 0}"
      
    onMouseClick: (event) =>
        
        if event.target.classList.contains 'group'
            if event.target.nextSibling?.classList.contains 'text'
                event.target.nextSibling.remove()
            else
                post.emit 'group', action:'expand', target:event.target
        else
            log 'click', event.target.className
                
    #  0000000   000   000   0000000  000   000  00000000  00000000  000000000  
    # 000   000  0000  000  000       000   000  000       000          000     
    # 000   000  000 0 000  0000000   000000000  0000000   0000000      000     
    # 000   000  000  0000       000  000   000  000       000          000     
    #  0000000   000   000  0000000   000   000  00000000  00000000     000     
    
    onSheet: (opt) =>
        
        opt ?= {}
        switch opt.action
            when 'clear'        then @clear()
            when 'setText'      then @setText opt.text
            when 'addText'      then @addText opt.text
            when 'insertText'   then @insertText opt.text, opt.after
            when 'addGroup'     then @addGroup opt.group
            when 'addChar'      then @addChar opt.char
            when 'addChars'     then @addChars opt.chars
            when 'fontSize'     then @setFontSize opt.fontSize
            when 'backspace'    then @backspace()
            when 'monospace'    then @monospace()
            else
                log 'onSheet', opt

module.exports = Sheet
