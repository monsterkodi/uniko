#!/usr/bin/env bash
cd `dirname $0`/..

rm -r uniko-win32-x64

konrad

node_modules/.bin/electron-rebuild

IGNORE="/(.*\.dmg$|Icon$|watch$|coffee$|icons$|.*md$|pug$|styl$|.*\.noon$|.*\.lock$|img/banner\.png)"

node_modules/electron-packager/cli.js . --overwrite --icon=img/uniko.ico --no-prune --ignore=$IGNORE--win32metadata.FileDescription=uniko

