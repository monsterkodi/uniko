###
00000000  000   000  000   000   0000000   0000000
000       000   000  0000  000  000       000     
000000    000   000  000 0 000  000       0000000 
000       000   000  000  0000  000            000
000        0000000   000   000   0000000  0000000 
###

{ last, prefs, elem, randInt, log, $, _ } = require 'kxk'

Color = require 'color'

rainbow       = prefs.get 'rainbow', true
rainbowIndex  = -1
rainbowColors = [0...10].map (h) -> Color(h:h*270/10, s:100, l:80).string()

class Funcs

    @toggleRainbow: -> rainbow = not rainbow; prefs.set 'rainbow', rainbow
    
    @charsToRanges: (chars) ->
        rngs = []
        for char in chars
            l = last rngs 
            if l and l[0] + l[1] + 1 == char
                l[1] += 1
            else
                rngs.push [char, 0]
        rngs
        
    @parseRange:     (s) -> s.split('+').map (n) -> parseInt n
    @stringifyRange: (r) -> "#{r[0]}+#{r[1]}"
    
    @groupTextForChars: (chars) -> Funcs.charsToRanges(chars).map((r) -> Funcs.stringifyRange(r)).join ' '
    @htmlForGroupText:  (text) -> text.split(' ').map((r) -> Funcs.htmlForChars Funcs.rangeToChars Funcs.parseRange r).join ''
    @htmlForChars: (chars) -> chars.map((c) -> Funcs.spanForChar(c)).join ''
    @spanForChar:  (char)  -> 
        if rainbow          
            rainbowIndex = (rainbowIndex + 1) % rainbowColors.length
            "<span style='color:#{rainbowColors[rainbowIndex]};'>&##{char};</span>"
        else
            "<span>&##{char};</span>"
    
    @rangeToChars: (r) -> 
            
        if _.isString(r) then r = Funcs.parseRange r
        [r[0]..r[0]+r[1]]
    
    @stringToRanges: (s) -> Funcs.charsToRanges Funcs.stringToChars s 
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

module.exports = Funcs
