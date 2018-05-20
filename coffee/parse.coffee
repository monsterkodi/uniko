###
00000000    0000000   00000000    0000000  00000000
000   000  000   000  000   000  000       000     
00000000   000000000  0000000    0000000   0000000 
000        000   000  000   000       000  000     
000        000   000  000   000  0000000   00000000
###

{ post, log, _ } = require 'kxk'

class Parse

    constructor: () ->
        
        post.on 'inputChanged', @onInput
        
    onInput: (text) =>
        
        # log 'Parse.inInput', text

module.exports = Parse
