title: Suffixes

---

## Suffixes in Kaiser

By default, Kaiser starts up an NGINX server on port 80 and 443 on your computer as a reverse proxy to all the applications started on it. It also uses a by default the `lvh.me` suffix. 

This means that if you start an app on Kaiser with the environment name `foo` then the URL on your computer will be `http://foo.lvh.me`

`lvh.me` is a domain that is set up in such a way that all of its subdomains also point to `127.0.0.1`.

---

## Reverse proxy

Why does it magically work?

By default kaiser sets up a reverse proxy that puts all your apps on a subdomain of (lvh.me)[lvh.me]. This means all your environments can be accessed like so: `envname.lvh.me`. Easy.

[Read more about lvh.me](https://nickjanetakis.com/blog/ngrok-lvhme-nipio-a-trilogy-for-local-development-and-testing#lvh-me)

---

## HTTPS

If you want to you can create a self-signed HTTPS certificate for lvh.me, trust it and use it to access your dev sites with HTTPS! (Cool! Now you can debug your websites in HTTPS!)

It is easy to do this: Simply run

```sh
kaiser set cert-folder /home/me/my-certificate-folder
```

As preparation you need to generate [HTTPS certificates](https://gist.github.com/dagjaneiro/dc1e26d87e745b47c4e2596f6b54022c). You should have the following files:

```
/home/me/my-certificate-folder/lvh.me.crt
/home/me/my-certificate-folder/lvh.me.key
/home/me/my-certificate-folder/lvh.me.chain.pem
```

Hint: you can create the `.chain.pem` file by going

```
cat lvh.me.crt >> lvh.me.key
cat lvh.me.crt >> lvh.me.crt
```

Remember to trust your certificates! Otherwise your browser will give you an error (if it isn't dodgy).

If you and your colleagues all want to sign using the same certificates, simply put the certificates on a webserver and go:

```sh
kaiser set cert-url https://internal-site.com/dev-certificates
```

and Kaiser will look for certificates at:

```
https://internal-site.com/dev-certificates/lvh.me.crt
https://internal-site.com/dev-certificates/lvh.me.key
https://internal-site.com/dev-certificates/lvh.me.chain.pem
```

#### HTTP/HTTPS Your own domain

If you have a fancy setup where you have your own localhost domain (like local.aweso.me) and you can generate your own SSL certificates (yes, very fancy) then you can set the suffix of your domain like this:

```sh
kaiser set http-suffix local.aweso.me
```

And your apps will be all `envname.local.aweso.me`

#### If you change these settings

You will need to run

```sh
kaiser shutdown
```

And run

```sh
kaiser up
```

Again for changes to take effect.
