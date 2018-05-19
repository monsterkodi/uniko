###
00000000  000   000  00000000   0000000
000        000 000   000       000     
0000000     00000    0000000   000     
000        000 000   000       000     
00000000  000   000  00000000   0000000
###

{ post, log, _ } = require 'kxk'

class Exec

    constructor: ->
        
        post.on 'exec', @onExec

    addChars: (list) -> 
        
        post.emit 'sheet', action:'addText', text:list.map((n) -> "&##{n};").join ' '
        true
        
    unicodeChar: (text) ->
        
        if /^\d+$/.test text
            return post.emit 'sheet', action:'addChar', char:"&##{[parseInt text]};" 
            
        else if /^\+[\da-fA-F]+$/.test text
            return post.emit 'sheet', action:'addChar', char:"&##{[parseInt text.slice(1), 16]};" 
        
    unicodeList: (text) ->
        
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
            
    onExec: (text) =>
        
        switch 
            when text == 'c'       then post.emit 'menuAction', 'Clear'
            when text == 'd'       then post.emit 'sheet', action:'backspace'
            when /^f\d+/.test text then post.emit 'sheet', action:'fontSize', fontSize:parseInt text.substr 1
            when @unicodeChar text then return
            when @unicodeList text then return
            else
                post.emit 'sheet', action:'addText', text:text
                
        post.emit 'menuAction', 'Reset'

module.exports = Exec
