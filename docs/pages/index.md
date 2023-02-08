title: Home

---

# Kaiser

This is documentation for Kaiser. This first page contains some text that gives an overview of what Kaiser is, what it isn't, what it does for you and why we wrote it in the first place.

If you already know it is for you, you can skip to the [Getting Started](0110-getting_started) page!

---

## Introduction

Kaiser is an opinionated tool that will streamline setting up a development environment. In the Kaiser world, all webapps at their most basic consist of a server backend and a database. The server is packaged in an environment fully described by a Dockerfile. Kaiser makes describing and setting these up super easy.

If you have a webapp that has two databases and one server backend, or one database but two server backends, Kaiser is almost certainly not for you.

For everyone else whose webapps and web services follow this pattern, read on!

---

## Developing with Kaiser

Those of us who package our webapps in a docker image and deploy it to a website, we expect our image to be sent out properly, and run in a way we expect it to be run, and then for all traffic to go into it properly.

Alas, is it truly so? A large number of us developers also simply run our webservers locally, from the commandline on our own machines, and only when we test pushing our code do we realize we forgot to add to the Dockerfile what we `brew install`ed or `apt install`'ed on our PCs, forcing us to redo this work again but against our staging environment!

Kaiser is writted (to our best effort) in a way to allow you to run that very container that you built in a containerized environment for you to test it.

It does not matter what language your webapp is written in, or what frameworks or runtimes it uses, as long as you package it in Docker, it will work with Kaiser.
