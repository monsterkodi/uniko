###
00000000  000   000  00000000   0000000
000        000 000   000       000     
0000000     00000    0000000   000     
000        000 000   000       000     
00000000  000   000  00000000   0000000
###

{ empty, post, error, log, _ } = require 'kxk'

{ stringToChars, toggleRainbow } = require './funcs'

Card = require './card'

class Exec

    @: ->
        
        post.on 'exec', @onExec
                
    addChars: (list) -> 
        
        post.emit 'sheet', action:'addChars', chars:list
        true
        
    addChar: (char) ->
        
        post.emit 'sheet', action:'addChar', char:char
        true
        
    execCmmd: (text) ->
        
        if /^\d+$/.test text
            return @addChar parseInt text
            
        if /^\+[\da-fA-F]+$/.test text
            return @addChar parseInt text.slice(1), 16
        
        if /^\d+-\d+$/.test text
            [a,b] = text.split('-').map (s) -> parseInt s
            return @addChars [a..b]
            
        if /^\d+\+\d+$/.test text
            [a,b] = text.split('+').map (s) -> parseInt s
            return @addChars [a..a+b]

        if /^\+[\da-fA-F]+-[\da-fA-F]+$/.test text
            [a,b] = text.slice(1).split('-').map (s) -> parseInt s, 16
            return @addChars [a..b]
            
        if /^\+[\da-fA-F]+\+[\da-fA-F]+$/.test text
            [a,b] = text.slice(1).split('+').map (s) -> parseInt s, 16
            return @addChars [a..a+b]
         
    execCmmds: (text) ->
        
        cmmds = text.split ' '
        for cmmd in cmmds
            if not @execCmmd cmmd
                error 'no command?', cmmd
                post.emit 'sheet', action:'addChars', chars:stringToChars cmmd
                            
    onExec: (text) =>
        
        switch 
            when text == 'c'         then post.emit 'menuAction', 'Clear'
            when text == 'd'         then post.emit 'sheet', action:'backspace'
            when text == 'm'         then post.emit 'sheet', action:'monospace'
            when text == 's'         then window.valid.saveRanges()
            when text == 'r'         then toggleRainbow()
            when text.startsWith '.' then window.sheet.appendElem elem:Card.elemForString text
            when text.startsWith 'n' then window.group.newGroup  text.substr 1
            when text.startsWith 'g' then window.group.addGroups text.substr 1
            when text.startsWith 'i' then window.valid.addRange  text.substr 1
            when /^f\d+/.test text then post.emit 'sheet', action:'fontSize', fontSize:parseInt text.substr 1
            else
                @execCmmds text
                
        post.emit 'menuAction', 'Reset'

module.exports = Exec
