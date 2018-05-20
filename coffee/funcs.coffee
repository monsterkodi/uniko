###
00000000  000   000  000   000   0000000   0000000
000       000   000  0000  000  000       000     
000000    000   000  000 0 000  000       0000000 
000       000   000  000  0000  000            000
000        0000000   000   000   0000000  0000000 
###

{ last, elem, log, $, _ } = require 'kxk'

class Funcs

    @charsToRanges: (chars) ->
        rngs = []
        for char in chars
            l = last rngs 
            if l and l[0] + l[1] + 1 == char
                l[1] += 1
            else
                rngs.push [char, 0]
        rngs
    
    @stringToRanges: (s) -> Funcs.charsToRanges Funcs.stringToChars s 
        
    @stringToRange: (s) -> s.split('+').map (n) -> parseInt n
    
    @rangeToChars: (r) -> 
            
        if _.isString(r) then r = Funcs.stringToRange r
        [r[0]..r[0]+r[1]]
    
    @rangesToString: (rngs) -> s = rngs.map((r) -> "#{r[0]}+#{r[1]}").join ' '

    @stringToChars: (s) -> 
        
        chars = []
        i = 0
        while cp = s.codePointAt i
            chars.push cp
            i++
            if cp > 65535
                i++
        chars
        
    @stringPop: (s) ->
    
        s.slice 0, s.length - 1   

    @spanForChar: (char) -> "<span>&##{char};</span>"
        
    @htmlForChars: (chars) -> chars.map((c) -> Funcs.spanForChar(c)).join ''
        
module.exports = Funcs
