#!/bin/sh

set -e

bundle install
bundle exec rake build
/usr/bin/gem install "$(ls pkg/*.gem | sort -V | tail -n1)"
