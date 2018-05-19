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
        
    unicodeChar: (text) ->
        
        if /\d+/.test text
            return "&##{text};"
        null
        
    onExec: (text) =>
        
        switch 
            when text == 'c'            then post.emit 'menuAction', 'Clear'
            when @unicodeChar text then post.emit 'sheet', action:'addChar', char:@unicodeChar text
            else
                post.emit 'sheet', action:'addText', text:text
        post.emit 'menuAction', 'Reset'

module.exports = Exec
