#!/bin/sh

set -e

rake build
rvm default do gem install "$(ls pkg/*.gem | sort -V | tail -n1)"
