#!/bin/sh

set -e

bundle install
bundle exec rake build
gem install "$(ls pkg/*.gem | sort -V | tail -n1)"
