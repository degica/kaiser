title: Suffixes

---

## Suffixes in Kaiser

By default, Kaiser starts up an NGINX server on port 80 and 443 on your computer as a reverse proxy to all the applications started on it. It also uses a by default the `lvh.me` suffix. 

This means that if you start an app on Kaiser with the environment name `foo` then the URL on your computer will be `http://foo.lvh.me`

`lvh.me` is a domain that is set up in such a way that all of its subdomains also point to `127.0.0.1`.

