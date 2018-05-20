###
00000000  000   000  00000000   0000000
000        000 000   000       000     
0000000     00000    0000000   000     
000        000 000   000       000     
00000000  000   000  00000000   0000000
###

{ noon, slash, empty, post, watch, error, log, _ } = require 'kxk'

class Exec

    constructor: ->
        
        post.on 'exec', @onExec
        
        @groupsFile = slash.join __dirname, '../bin/groups.noon'
        @groups = noon.load @groupsFile

        watcher = watch.watch @groupsFile
        watcher.on 'change', => @groups = noon.load @groupsFile
        watcher.on 'error', (err) -> error err
        
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
                post.emit 'sheet', action:'addText', text:cmmd
            
    showGroup: (name) ->
        
        ranges = @groups[name].split ' '
        post.emit 'sheet', action:'addText', text:name
        post.emit 'sheet', action:'addText', text:''
        for range in ranges
            post.emit 'sheet', action:'addRange', range:range
                
    showGroups: (names) ->
        names = names.trim().split ' '
        names = [] if names.length == 1 and empty names[0] 
        
        if empty names then names = _.keys @groups
        for name in names
            log 'group', name, @groups[name]
            @showGroup name
                
    onExec: (text) =>
        
        switch 
            when text == 'c'       then post.emit 'menuAction', 'Clear'
            when text == 'd'       then post.emit 'sheet', action:'backspace'
            when text == 'm'       then post.emit 'sheet', action:'monospace'
            when text == 's'       then window.valid.saveRanges()
            when text.startsWith 'g' then @showGroups text.substr 1
            when text.startsWith 'i' then window.valid.addRange text.substr 1
            when /^f\d+/.test text then post.emit 'sheet', action:'fontSize', fontSize:parseInt text.substr 1
            else
                @execCmmds text
                
        post.emit 'menuAction', 'Reset'

module.exports = Exec
