title: Getting Started

---

# Prerequisites

You will need docker to be installed on your machine.

---

# Getting Started with Kaiser

Kaiser is a Ruby Gem. You can install it using

```
gem install kaiser
```

We don't recommend adding it to your bundle files, because Kaiser is more useful as an environment handler than a gem that your program can use.

---

# A Minimal Example

> Do this tutorial to learn Kaiser!

Since Kaiser is meant to be used to improve the dev process of a web app, it makes no sense to go into all the different ways it can be used, so this section is written like a _tutorial_ with a simple example to demonstrate its usage.

This tutorial will show you 3 simple steps to illustrate how to get started with Kaiser. At the end of this tutorial you will be directed to where you can find more detailed topics about how to use Kaiser

## 1. Start with a folder

First of all, create a directory called `hello`

```
mkdir hello
```

And enter it

```
cd hello
```

## 2. Make a simple app

In order to use this you need a Kaiserfile and a Dockerfile at the very least. 

For this very simple example lets make an extremely simple application that serves `Hello Kaiser`. In order to do this, we just have to create a Dockerfile containing the following:

```
touch Dockerfile
```

```
# Dockerfile
FROM public.ecr.aws/degica/barcelona-hello

RUN echo 'Hello Kaiser' > /var/www/static/index.html
```

The `public.ecr.aws/degica/barcelona-hello` image is a simple image that contains just an nginx server and a fileserver that serves out of `/var/www/static/` in the container. You can find its source code here: https://github.com/degica/barcelona-hello

And then we create a Kaiserfile

```
touch Kaiserfile
```

```
# Kaiserfile
dockerfile 'Dockerfile'

expose '8080'
```

## 3. Start up the App

Now we initialize Kaiser. We do this with the `kaiser init` command. This command takes one parameter called the environment name, and it is stored in a configuration file in `$HOME/.kaiser/config.yml` so it is global to your user.

This allows Kaiser to set up some data required to start your environment. This only needs to be done once. If you want to throw this environment away, you can call `kaiser deinit`

```
kaiser init hello
```

In this case, we call our environment `hello`. This is also important as it will be the prefix for the DNS name that will be used for this. In this case by default, setting the environment name to `hello` makes the URL for the app `http://hello.lvm.me`

Having done that, we can start up the program using:

```
kaiser up -av
```

And you should be able to go to `http://hello.lvm.me` and find a page that displays the text `Hello Kaiser`

## That's all, folks!

Congratulations for getting to the end of the tutorial for Kaiser! Obviously you would want to find out more!

To find out about how you would provide this application with a database, check out [Databases](/0130-databases).

To find out how to set up HTTPS on your server, go to [Suffixes](/0140-suffixes).

To find out more about setting up environment variables, and other features, go to [Kaiserfile](/0120-the-kaiserfile)

