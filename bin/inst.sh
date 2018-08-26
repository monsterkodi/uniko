#!/usr/bin/env bash
cd `dirname $0`/..

rm -rf /Applications/uniko.app
cp -R uniko-darwin-x64/uniko.app /Applications

open /Applications/uniko.app 
