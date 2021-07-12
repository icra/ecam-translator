#!/bin/bash

#local: commit and push
git add *
git commit
git push

#remote: pull and build
cmd="cd /var/www/vhosts/icradev.cat/ecamtranslator.icradev.cat/ecam-translator; git pull; npm run build;"
ssh root@217.61.208.188 "$cmd"
