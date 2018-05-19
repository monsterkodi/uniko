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
        
    onExec: (text) =>
        
        switch text
            when 'c' then post.emit 'menuAction', 'Clear'
            else
                post.emit 'sheet', action:'addText', text:text
        post.emit 'menuAction', 'Reset'

module.exports = Exec
