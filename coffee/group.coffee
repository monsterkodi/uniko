###
 0000000   00000000    0000000   000   000  00000000 
000        000   000  000   000  000   000  000   000
000  0000  0000000    000   000  000   000  00000000 
000   000  000   000  000   000  000   000  000      
 0000000   000   000   0000000    0000000   000      
###

{ post, watch, noon, slash, last, elem, empty, error, log, _ } = require 'kxk'

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
            when 'removeChars'  then @removeChars opt
            when 'addGroups'    then @addGroups opt.groups
            when 'toggle'       then @toggle opt.target
            else
                log 'onGroup', opt

    getGroup: (path, parent=@groups) -> 
        
        split = path.split ' '
        if split.length == 1
            parent[split[0]]
        else
            @getGroup split.slice(1).join(' '), parent[split[0]]
            
    groupElem: (target) -> elem.upElem target, class:'group'
            
    getParent: (path) ->
        
        split = path.split ' '
        if split.length == 1
            @groups
        else
            split.pop()
            @getGroup split.join ' ' 
            
    rangesForGroup: (group) -> @getGroup(group).split ' '
    charsForGroup:  (group) -> _.flatten @rangesForGroup(group).map (r) -> rangeToChars r
    
    removeChars: (opt) ->
        # log 'removeChars', opt
        group = opt.group
        chars = opt.chars
        index = opt.index
        name = last group.split ' '
        groupChars = @charsForGroup group 
        groupChars.splice index, 0, chars
        @getParent(group)[name] = rangesToString charsToRanges groupChars
        noon.save @groupsFile, @groups
        
    insertChars: (opt) ->
        group = opt.group
        chars = opt.chars
        name = last group.split ' '
        @getParent(group)[name] = rangesToString charsToRanges @charsForGroup(group).filter (c) -> c not in chars
        noon.save @groupsFile, @groups
           
    isExpanded: (target) -> @groupElem(target).children.length > 1
        
    toggle: (target) ->

        log 'toggle', target?, target.className, target.innerText, elem.upElem(target, class:'group')?, @isExpanded(target)
        if @isExpanded target
            @collapse target
        else
            @expand target

    collapse: (target) ->

        groupElem = @groupElem target
        while groupElem.children.length > 1
            groupElem.removeChild groupElem.lastChild
            
    expand: (target) ->
        name = target.innerText
        content = @getGroup name
        groupElem = @groupElem target
        if _.isString content
            text = @htmlForRangeString content
            post.emit 'sheet', action:'insertText', parent:groupElem, text:text
        else # contains groups
            for group,value of content
                post.emit 'sheet', action:'insertGroup', parent:groupElem, group:name + ' ' + group
        
    htmlForGroup: (group) -> @rangesForGroup(group).map((r) -> htmlForChars rangeToChars r).join ''
    htmlForRangeString: (rngs) -> rngs.split(' ').map((r) -> htmlForChars rangeToChars r).join ''
            
    addGroups: (names) ->
        
        names = names.trim().split ' '
        names = [] if names.length == 1 and empty names[0] 
        
        if empty names
            @listGroups()
        else
            for group in names
                post.emit 'sheet', action:'addGroup', group:group, text:@htmlForGroup group
          
    listGroups: ->
        
        for name,v of @groups
            post.emit 'sheet', action:'addGroup', group:name
        
module.exports = Group
