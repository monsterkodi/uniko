### 
 0000000  000   000  00000000  00000000  000000000
000       000   000  000       000          000   
0000000   000000000  0000000   0000000      000   
     000  000   000  000       000          000   
0000000   000   000  00000000  00000000     000   
###

{ post, prefs, elem, last, empty, str, pos, log, $, _ } = require 'kxk'

{ stringToChars, stringPop, stringToRanges, rangesToString, 
  validChar, rangeToChars, spanForChar, htmlForChars } = require './funcs'

class Sheet

    constructor: ->
        
        @view = $ "#sheet"
        @setFontSize prefs.get 'sheet:fontSize', 60
        @view.addEventListener 'wheel',     @onWheel
        @view.addEventListener 'mousemove', @onMouseMove
        @view.addEventListener 'click',     @onMouseClick
        @view.addEventListener 'dragstart', @onDragStart
        @view.addEventListener 'dragover',  @onDragOver
        @view.addEventListener 'drop',      @onDrop

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

    insertGroup: (opt) -> opt.parent.appendChild @elemForGroup opt.group 
    insertText:  (opt) -> opt.parent.appendChild @elemForText opt.text
    appendElem:  (opt) -> @view.appendChild opt.elem
        
    addGroup: (opt) -> 
        @view.appendChild @elemForGroup opt.group
        if opt.text then @view.appendChild @elemForText opt.text
        
    popChar: -> 
        if not @empty() 
            last(@view.children).innerHTML = stringPop last(@view.children).innerHTML
            true
        false

    # 0000000    00000000    0000000    0000000   
    # 000   000  000   000  000   000  000        
    # 000   000  0000000    000000000  000  0000  
    # 000   000  000   000  000   000  000   000  
    # 0000000    000   000  000   000   0000000   
    
    onDragStart: (event) =>
    
    onDragOver: (event) => 
    
        @clearDropTarget event
        
        eventPos = pos event 
        dropElem = document.elementFromPoint eventPos.x, eventPos.y
        if dropElem.parentNode.classList.contains 'text'
            @dropTarget = dropElem
            @dropTarget.style.borderLeft = '1px solid white'
        else
            groupElem = elem.upElem dropElem, class:'group'
            if window.group.isExpanded groupElem
                @dropTarget = groupElem.lastChild.lastChild
                @dropTarget.style.borderRight = '1px solid white'
    
    onDrop: (event) =>
        
        data = event.dataTransfer.getData "text"
        if @dropTarget?
            group = window.group.groupName @dropTarget
            index = elem.childIndex @dropTarget
            chars = stringToChars data
            post.emit 'group', action:'insertChars', group:group, chars:chars, index:index
            groupElem = elem.upElem @dropTarget, class:'group'
            while groupElem.children.length > 1
                groupElem.removeChild groupElem.lastChild
            @insertText parent:groupElem, text:htmlForChars window.group.charsForGroup group
            
        @clearDropTarget event

    clearDropTarget: (event) ->
        
        event.preventDefault()
        
        @dropTarget?.style.borderLeft = ''
        @dropTarget?.style.borderRight = ''
        
        delete @dropTarget
                 
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
            if event.altKey
                post.emit 'input', action:'setText', text:rangesToString stringToRanges selection
            return
            
        t = event.target.innerText
        if t.length <= 2 and t.codePointAt 0 
            if not window.valid.char t.codePointAt 0 
                log "invalid #{t.codePointAt 0}"
      
    onMouseClick: (event) =>

        nameElem = elem.upElem event.target, class:'name'
        
        if nameElem
            post.emit 'group', action:'toggle', target:nameElem
        else if event.target.classList.contains 'group'
            post.emit 'group', action:'toggle', target:event.target.firstChild
        # else
            # log "click className: '#{event.target.className}'"
       
    copy: -> 
        if selection = @currentSelection()
            require('electron').clipboard.writeText selection
       
    paste: -> 
        selection = window.getSelection()
    
        if not selection.rangeCount then return
    
        selection.getRangeAt(0).insertNode document.createTextNode require('electron').clipboard.readText() 
            
    cut: -> 
        if selection = @currentSelection()
            require('electron').clipboard.writeText selection
            range = document.getSelection().getRangeAt(0)
            start = elem.childIndex range.startContainer.parentElement
            end   = elem.childIndex range.endContainer.parentElement
            groupElem = elem.upElem range.startContainer, class:'group'
            group = window.group.groupName groupElem
            post.emit 'group', action:'removeRange', group:group, start:start, end:end
            while end >= start
                groupElem.children[1].children[end].remove()
                end-=1
                    
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
            when 'clear'        then @clear()
            when 'insertText'   then @insertText opt
            when 'insertGroup'  then @insertGroup opt
            when 'addChar'      then @addChar opt.char
            when 'addChars'     then @addChars opt.chars
            when 'fontSize'     then @setFontSize opt.fontSize
            when 'backspace'    then @backspace()
            when 'monospace'    then @monospace()
            else
                log 'onSheet', opt

module.exports = Sheet
