#!/usr/bin/env bash
cd `dirname $0`/..

if rm -rf uniko-darwin-x64; then

    konrad
    node_modules/.bin/electron-rebuild
    
    IGNORE="/(.*\.dmg$|Icon$|.*md$|.*\.lock$|three/examples)"
    node_modules/electron-packager/cli.js . --overwrite --icon=img/app.icns --ignore $IGNORE
    
fi
