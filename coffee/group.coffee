###
 0000000   00000000    0000000   000   000  00000000 
000        000   000  000   000  000   000  000   000
000  0000  0000000    000   000  000   000  00000000 
000   000  000   000  000   000  000   000  000      
 0000000   000   000   0000000    0000000   000      
###

{ post, watch, noon, slash, last, elem, empty, error, log, _ } = require 'kxk'

{ rangeToChars, groupTextForChars, htmlForGroupText } = require './funcs'

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
            when 'removeRange'  then @removeRange opt
            when 'removeChars'  then @removeChars opt
            when 'insertChars'  then @insertChars opt
            when 'toggle'       then @toggle opt.target
            when 'collapse'     then @collapse opt.target
            else
                log 'onGroup', opt

    getGroup: (path, parent=@groups) -> 
        
        split = path.split ' '
        if split.length == 1
            parent[split[0]]
        else
            @getGroup split.slice(1).join(' '), parent[split[0]]
            
    groupElem: (target) -> elem.upElem target, class:'group'
    groupName: (target) -> @groupElem(target).firstChild.innerText
            
    getParent: (path) ->
        
        split = path.split ' '
        if split.length == 1
            @groups
        else
            split.pop()
            @getGroup split.join ' ' 
            
    rangesForGroup: (group) -> @getGroup(group).split ' '
    charsForGroup:  (group) -> _.flatten @rangesForGroup(group).map (r) -> rangeToChars r
    
    # 000  000   000   0000000  00000000  00000000   000000000  
    # 000  0000  000  000       000       000   000     000     
    # 000  000 0 000  0000000   0000000   0000000       000     
    # 000  000  0000       000  000       000   000     000     
    # 000  000   000  0000000   00000000  000   000     000     
    
    insertChars: (opt) ->
        
        group = opt.group
        chars = opt.chars
        index = opt.index
        name = last group.split ' '
        groupChars = @charsForGroup group 
        groupChars.splice.apply groupChars, [index, 0].concat chars
        @getParent(group)[name] = groupTextForChars groupChars
        noon.save @groupsFile, @groups
        
    removeChars: (opt) ->
        
        group = opt.group
        chars = opt.chars
        name = last group.split ' '
        @getParent(group)[name] = groupTextForChars @charsForGroup(group).filter (c) -> c not in chars
        noon.save @groupsFile, @groups
        
    removeRange: (opt) ->

        group = opt.group        
        name = last group.split ' '
        chars = @charsForGroup group
        chars.splice opt.start, opt.end-opt.start+1
        @getParent(group)[name] = groupTextForChars chars
        noon.save @groupsFile, @groups
           
    # 00000000  000   000  00000000    0000000   000   000  0000000    
    # 000        000 000   000   000  000   000  0000  000  000   000  
    # 0000000     00000    00000000   000000000  000 0 000  000   000  
    # 000        000 000   000        000   000  000  0000  000   000  
    # 00000000  000   000  000        000   000  000   000  0000000    
    
    isExpanded: (target) -> @groupElem(target).children.length > 1
        
    toggle: (target) ->

        if @isExpanded target
            @collapse target
        else
            @expand target

    
    collapse: (target) ->

        groupElem = @groupElem target
        while groupElem.children.length > 1
            groupElem.removeChild groupElem.lastChild
            
    expand: (target) ->
        
        name = @groupName target
        content = @getGroup name
        groupElem = @groupElem target
        if _.isString content
            text = htmlForGroupText content
            post.emit 'sheet', action:'insertText', parent:groupElem, text:text
        else # contains groups
            for group,value of content
                post.emit 'sheet', action:'insertGroup', parent:groupElem, group:name + ' ' + group
        
    #  0000000   0000000    0000000    
    # 000   000  000   000  000   000  
    # 000000000  000   000  000   000  
    # 000   000  000   000  000   000  
    # 000   000  0000000    0000000    
    
    addGroups: (names) ->
        
        names = names.trim().split ' '
        names = [] if names.length == 1 and empty names[0] 
        
        names = names.map (name) -> name.replace '.', ' ' 
        
        if empty names
            @listGroups()
        else
            for group in names
                @addGroup group:group
       
    addGroup: (opt) -> window.sheet.addGroup opt
                
    newGroup: (name) ->
        
        names = name.trim().split ' '
        return if empty names or names.length == 1 and empty names[0] 
        parent = @groups
        ranges = '128578+0'
        
        while part = names.shift()
            group = @getGroup part, parent
            if not group
                if empty names
                    parent[part] = ranges
                else
                    parent[part] = {}
                    parent = parent[part]
            else 
                if _.isString(group) and not empty names
                    ranges = group
                    parent[part] = {}
                    parent = parent[part]
                else
                    parent = group
                
        @addGroup group:name, text:htmlForGroupText ranges
                
    # 000      000   0000000  000000000  
    # 000      000  000          000     
    # 000      000  0000000      000     
    # 000      000       000     000     
    # 0000000  000  0000000      000     
    
    listGroups: ->
        
        for name,v of @groups
            window.sheet.addGroup group:name
        
module.exports = Group
