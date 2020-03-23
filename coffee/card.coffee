###
 0000000   0000000   00000000   0000000  
000       000   000  000   000  000   000
000       000000000  0000000    000   000
000       000   000  000   000  000   000
 0000000  000   000  000   000  0000000  
###

{ _, elem, noon } = require 'kxk'

{ stringToChars, spanForChar } = require './funcs'

class Card

    @: () ->

    @htmlForString: (s) -> @elemForString(s).outerHTML
        
    @elemForString: (s) -> 
    
        o = @parseString s
        o.class ?= 'card'
        
        if o.anim
            o.style += 'position:relative;'
            text = o.text
            delete o.text
            cont = elem o
            cont.appendChild elem 'style', text:"@keyframes blink {0% {opacity: 1;} 100% {opacity: 1;}} .item { position: absolute; opacity: 0; animation: blink #{o.anim}s; }"
            delay = 0
            for c in stringToChars text
                cont.appendChild elem class:'item', html:spanForChar(c), style:"animation-delay:#{delay}s;"
                delay += o.anim
            cont
        else
            elem o
    
    @parseString: (s) -> 
    
        s = s.trim()
        
        o = noon.parse 'card ' + s
        
        if _.isArray(o['card']) and _.isString o['card'][0]
            
            return 
                text: o['card'][0]
                
        else if _.isObject o['card']
            
            o = o['card']
            o.style = ''
            o.style += "font-size:#{o.size}px;" if o.size?
            
            return o
                
        else
            log 'dafuk', s, o
        
        return text:"??? #{s}"

module.exports = Card
