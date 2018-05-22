###
00     00  00000000  000   000  000   000
000   000  000       0000  000  000   000
000000000  0000000   000 0 000  000   000
000 0 000  000       000  0000  000   000
000   000  00000000  000   000   0000000 
###

{ post, elem, sds, menu, log, $, _ } = require 'kxk'

pkg = require '../package'

class Menu

    @template: ->

        [
            #  0000000   00000000   00000000   
            # 000   000  000   000  000   000  
            # 000000000  00000000   00000000   
            # 000   000  000        000        
            # 000   000  000        000        
    
            # text: "#{pkg.name}"
            text: "unꖶĸo"
            menu: [
                text:   "About",                        accel:  'ctrl+shift+/'
            ,
                text:   ''
            ,
                text:   'Save ...',                     accel:  'ctrl+s'
            ,
                text:   'Clear',                        accel:  'ctrl+k'
            ,
                text:   ''
            ,
                text:   'Quit',                         accel:  'ctrl+q'
            ]
        ,
            # 000   000  000  000   000  0000000     0000000   000   000
            # 000 0 000  000  0000  000  000   000  000   000  000 0 000
            # 000000000  000  000 0 000  000   000  000   000  000000000
            # 000   000  000  000  0000  000   000  000   000  000   000
            # 00     00  000  000   000  0000000     0000000   00     00
    
            text:   'Window'
            menu: [
                text:   'Minimize',                     accel:  'alt+ctrl+shift+m'
            ,
                text:   'Maximize',                     accel:  'alt+shift+m'
            ,
                text:   ''
            ,
                text:   'Toggle Menu',                  accel:  'alt+m'
            ,
                text:   'Toggle Scheme',                accel:  'alt+i'
            ,
                text:   ''
            ,
                text:   'Reload',                       accel:  'alt+ctrl+l'
            ,
                text:   'DevTools',                     accel:  'alt+ctrl+i'
            ,
                text:   ''
            ,
                text:   'Font Size'
                menu: [
                    text:   'Increase',                 accel:  'ctrl+=',   action: 'Font Size Increase'   
                ,
                    text:   'Decrease',                 accel:  'ctrl+-',   action: 'Font Size Decrease'
                ,
                    text:   'Reset',                    accel:  'ctrl+0',   action: 'Font Size Reset'
                ]
            ]
        ]
    
    constructor: ->
        
        @menu = new menu items:Menu.template()
        @elem = @menu.elem
        window.titlebar.elem.insertBefore @elem, window.titlebar.elem.firstChild.nextSibling
        @hide()
        
    visible: => @elem.style.display != 'none'
    show:    => @elem.style.display = 'inline-block'; @menu?.focus?(); post.emit 'titlebar', 'hideTitle'
    hide:    => @menu?.close(); @elem.style.display = 'none'; post.emit 'titlebar', 'showTitle'
    toggle:  => if @visible() then @hide() else @show()

    # 000   000  00000000  000   000
    # 000  000   000        000 000 
    # 0000000    0000000     00000  
    # 000  000   000          000   
    # 000   000  00000000     000   
    
    globalModKeyComboEvent: (mod, key, combo, event) ->

        if not @mainMenu
            @mainMenu = Menu.template()

        for keypath in sds.find.key @mainMenu, 'accel'
            if combo == sds.get @mainMenu, keypath
                keypath.pop()
                item = sds.get @mainMenu, keypath
                post.emit 'menuAction', item.action ? item.text, item.actarg
                return item
                
        'unhandled'
    
module.exports = Menu
