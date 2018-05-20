###
 0000000   00000000    0000000   000   000  00000000 
000        000   000  000   000  000   000  000   000
000  0000  0000000    000   000  000   000  00000000 
000   000  000   000  000   000  000   000  000      
 0000000   000   000   0000000    0000000   000      
###

{ post, watch, noon, slash, empty, error, log, _ } = require 'kxk'

{ spanForChar, htmlForChars, rangeToChars, charsToRanges, rangesToString } = require './funcs'

class Group

    constructor: ->

        @groupsFile = slash.join __dirname, '../bin/groups.noon'
        @groups = noon.load @groupsFile

        @watcher = watch.watch @groupsFile
        @watcher.on 'change', => @groups = noon.load @groupsFile
        @watcher.on 'error', (err) -> error err
        
        post.on 'group', @onGroup

    onGroup: (opt) =>
        opt ?= {}
        switch opt.action
            when 'removeChars'  then @removeChars opt.group, opt.chars
            when 'addGroups'    then @addGroups opt.groups
            when 'expand'       then @expand opt.target
            else
                log 'onGroup', opt

    rangesForGroup: (group) -> @groups[group].split ' '
    charsForGroup: (group) -> _.flatten @rangesForGroup(group).map (r) -> rangeToChars r
                
    removeChars: (group, chars) ->
        log 'remove', chars
        @groups[group] = rangesToString charsToRanges @charsForGroup(group).filter (c) -> c not in chars
        noon.save @groupsFile, @groups
            
    expand: (target) ->
        log 'expand', target.innerHTML
        post.emit 'sheet', action:'insertText', after:target, text:@htmlForGroup target.innerHTML
        
    htmlForGroup: (group) -> @rangesForGroup(group).map((r) -> htmlForChars rangeToChars r).join ''
            
    addGroup: (name) ->
        
        post.emit 'sheet', action:'addGroup', group:name
        post.emit 'sheet', action:'addText',  text:@htmlForGroup name
            
    addGroups: (names) ->
        names = names.trim().split ' '
        names = [] if names.length == 1 and empty names[0] 
        
        if empty names 
            @listGroups()
        else
            for name in names
                @addGroup name
          
    listGroups: ->
        
        for name,v of @groups
            post.emit 'sheet', action:'addGroup', group:name
        
module.exports = Group
