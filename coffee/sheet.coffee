### 
 0000000  000   000  00000000  00000000  000000000
000       000   000  000       000          000   
0000000   000000000  0000000   0000000      000   
     000  000   000  000       000          000   
0000000   000   000  00000000  00000000     000   
###

{ post, prefs, elem, last, empty, str, log, $, _ } = require 'kxk'

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
        
    empty:                          -> @view.children.length == 0
    clear:                          -> @view.innerHTML = ''; window.input.focus()
    backspace:                      -> if not @popChar() then log 'backspace text?'
    addChar:        (char)          -> if not @empty() then last(@view.children).innerHTML += spanForChar(char) else @addText spanForChar char
    addChars:       (chars)         -> @addText htmlForChars chars.filter (c) -> window.valid.char c
    addText:        (text)          -> @view.appendChild @elemForText text
    elemForText:    (text)          -> elem class:'text',  html:str text
    elemForGroup:   (group)         -> 
    
        groupElem = elem class:'group'
        groupElem.appendChild @elemForName group
        groupElem
        
    elemForName: (group) -> 
        
        nameElem = elem class:'name'
        for name in group.split ' '
            nameElem.appendChild elem 'span', text:name+' '
        nameElem

    insertGroup:    (opt)           -> opt.parent.appendChild @elemForGroup opt.group 
    insertText:     (opt)           -> opt.parent.appendChild @elemForText opt.text
        
    addGroup: (opt) -> 
        @view.appendChild @elemForGroup opt.group
        if opt.text then @view.appendChild @elemForText opt.text
        
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
    
    currentSelection: ->
        
        selection = document.getSelection().toString()
        if selection.length and not window.input.hasSelection()
            return selection
        ''
    
    onMouseMove: (event) =>
        
        selection = @currentSelection()
        if not empty selection
            post.emit 'input', action:'setText', text:rangesToString stringToRanges selection
            return
            
        t = event.target.innerText
        if t.length <= 2 and t.codePointAt 0 
            if not window.valid.char t.codePointAt 0 
                log "invalid #{t.codePointAt 0}"
      
    onMouseClick: (event) =>

        nameElem = elem.upElem event.target, class:'name'
        log 'nameElem', nameElem?, nameElem?.className
        
        if nameElem
            post.emit 'group', action:'toggle', target:nameElem
        else
            log "click className: '#{event.target.className}'"
       
    remove: ->
        
        if selection = @currentSelection()
            if document.getSelection().rangeCount
                range = document.getSelection().getRangeAt(0)
                ancestor = range.commonAncestorContainer
                clist = ancestor.classList
                if not clist? and selection.length <= 2
                    ancestor = ancestor.parentNode.parentNode
                    clist = ancestor.classList
                if clist.contains 'text' 
                    group = ancestor.parentNode.childNodes[0].nodeValue
                    post.emit 'group', action:'removeChars', group:group, chars:stringToChars @currentSelection()
                    document.getSelection().deleteFromDocument()
            
    #  0000000   000   000   0000000  000   000  00000000  00000000  000000000  
    # 000   000  0000  000  000       000   000  000       000          000     
    # 000   000  000 0 000  0000000   000000000  0000000   0000000      000     
    # 000   000  000  0000       000  000   000  000       000          000     
    #  0000000   000   000  0000000   000   000  00000000  00000000     000     
    
    onSheet: (opt) =>
        
        opt ?= {}
        switch opt.action
            when 'clear'        then @clear()
            when 'insertText'   then @insertText opt
            when 'addGroup'     then @addGroup opt
            when 'insertGroup'  then @insertGroup opt
            when 'addChar'      then @addChar opt.char
            when 'addChars'     then @addChars opt.chars
            when 'fontSize'     then @setFontSize opt.fontSize
            when 'backspace'    then @backspace()
            when 'monospace'    then @monospace()
            else
                log 'onSheet', opt

module.exports = Sheet
