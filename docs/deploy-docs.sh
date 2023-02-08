#!/bin/bash

rm -rf build
rm -rf gittemp

echo "This document has been deployed to https://tech.degica.com/kaiser$ROOT_DIR"

git clone git@github.com:degica/kaiser gittemp
pushd gittemp
git checkout gh-pages
popd
weaver build --root "https://tech.degica.com/kaiser$ROOT_DIR"
rm -rf build/js/MathJax
echo "Making dir gittemp$ROOT_DIR"
mkdir -p "gittemp$ROOT_DIR"
cp -r build/* "gittemp$ROOT_DIR"
pushd gittemp
rm -rf js/MathJax
git add .
git add -u
git commit -m "update"
git push
popd
