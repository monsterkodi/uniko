###
000   000   0000000   000      000  0000000  
000   000  000   000  000      000  000   000
 000 000   000000000  000      000  000   000
   000     000   000  000      000  000   000
    0      000   000  0000000  000  0000000  
###

{ elem, slash, noon, log, _ } = require 'kxk'

{ charsToRanges, stringToRange } = require './funcs'

html2canvas = require 'html2canvas'

class Valid

    constructor: ->
        
        @invalid = new Set [1]
        @square = null
        @current = 10000
        
        @rangesFile = slash.join __dirname, '../bin/invalid.noon'
        @invalidRanges = noon.load @rangesFile
        log '@invalidRanges', @invalidRanges.length
        # @validate()
        
    validate: ->
        log 'validate'
        @div = elem class:'test-char', html:"&#1;"
        document.body.appendChild @div
        html2canvas(@div, logging:false).then (canvas) => 
            context = canvas.getContext '2d' 
            imageData = context.getImageData 0, 0, canvas.width, canvas.height
            @square = imageData.data
            @check()
        
    check: ->

        @current += 1
        # log 'check', @current
        
        if @current > 100000 # 195060
            rngs = charsToRanges Array.from @invalid
            noon.save slash.resolve('~/Desktop/invalid.noon'), rngs
            log 'done', rngs
            @div.remove()
            return
        
        @div.innerHTML = "&##{@current};"
        
        html2canvas(@div, logging:false).then (canvas) => 
                        
            context = canvas.getContext '2d' 
            if canvas.width == 0 or canvas.height == 0
                @invalid.add @current
                log @current, @invalid.has @current
                return @check()
            imageData = context.getImageData 0, 0, canvas.width, canvas.height
            dataBuffer = imageData.data
            if dataBuffer.length == 280 
                if dataBuffer.every (v,i) => v == @square[i]
                    # log 'invalid', @current, canvas.width, canvas.height, dataBuffer.length
                    @invalid.add @current
            log @current, @invalid.has @current
            @check()
       
    addRange: (range) -> 
    
        @invalidRanges.push stringToRange range
        @invalidRanges = @invalidRanges.sort (a,b) -> a[0]-b[0]
        log @invalidRanges
        
    saveRanges: ->
        
        log 'saveRanges', @invalidRanges.length
        noon.save @rangesFile, @invalidRanges
            
    char: (char) -> 
        # return true
        return false if char >= 250000
        for r in @invalidRanges
            continue if r[0]+r[1] < char
            return false if char >= r[0] and char <= r[0]+r[1]
            return true
        true
                        
module.exports = Valid
