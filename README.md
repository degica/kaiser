# Kaiser

Welcome to Kaiser! Kaiser will mind-control all your monsters and make them even more effective.

Kaiser lets you define how an application starts, so trying out a web application simply reduces to a `kaiser up`

## Installation (Traditional)

1. Download and setup [Docker](https://www.docker.com/get-started)

2. Add this line to your application's Gemfile:

```ruby
gem 'kaiser', git: "https://github.com/degica/kaiser"
```

3. Execute:

    ```$ bundle```

    Or install it yourself as:

        $ gem install specific_install
        $ gem specific_install -l https://github.com/degica/kaiser

## Installation (Docker)

You can install Kaiser as a docker image on your machine too!

Simply clone the repo and run 

```
cd kaiser
docker build -t degica/kaiser . 
```

And then add the following line to your `.bashrc` or `.bash_profile`

```
alias kaiser='docker run --rm -ti -v /var/run/docker.sock:/var/run/docker.sock -v $HOME/.kaiser:/root/.kaiser -v `pwd`:`pwd` -e CONTEXT_DIR="`pwd`" degica/kaiser'
```

## Usage

You will need to provide a Kaiserfile, and write a Dockerfile for your app (in the app repo's root dir) like so:

```ruby
# Example for a Rails app

dockerfile "Dockerfile.kaiser"

db "mysql:5.6",
  port: 3306,
  data_dir: "/var/lib/mysql",
  params: "-e MYSQL_ROOT_PASSWORD=test123",
  commands: ""

app_params "-e DATABASE_URL=mysql2://root:test123@<%= db_container_name %>"

expose "9000"
db_reset_command "bin/rails db:reset"
```

```dockerfile
FROM ruby:alpine

COPY . /app
RUN apk update && apk add build-base
RUN gem install bundler
RUN bundle install

EXPOSE "3000"

CMD ["sh", "-c", "rails -b 0.0.0.0 -p 3000"]
```

Then go to your repo's root folder and go

```sh
bundle exec kaiser init myapp
bundle exec kaiser up
```

Once its done, simply

```sh
open http://myapp.lvh.me
```

And enjoy previewing your app!

### Debugging

You can also debug by going

```sh
bundle exec kaiser attach
```

### Run stuff in the container

You can also run stuff inside by going

```sh
bundle exec kaiser login sh
```

And you can do anything inside the container

### Attach to the container

If you want to run with the container in the foreground simply go

```sh
bundle exec kaiser attach
```

This is similar to `kaiser login` but it terminates the running container, whereas `kaiser login` will simply run you in the same container as the running container.

```sh
bundle exec kaiser attach nano /etc/hosts
```

### Save database state

```sh
bundle exec kaiser db_save customer_setup
```

You can also save your database state to a file in your current dir:

```sh
bundle exec kaiser db_save ./my_setup.dbimage
```

### Load database state

```sh
bundle exec kaiser db_load customer_setup
```

You can load a previously saved database file that you have

```sh
bundle exec kaiser db_load ./my_setup.dbimage
```

### Get ports

Kaiser decides what ports to use on the host. To know them simply go

```sh
bundle exec kaiser show ports
```

### Curious?

You can see what Kaiser is doing under the hood with the `-v` flag:

```sh
bundle exec kaiser -v db_reset 
```

## Reverse proxy

Why does it magically work?

By default kaiser sets up a reverse proxy that puts all your apps on a subdomain of (lvh.me)[lvh.me]. This means all your environments can be accessed like so: `envname.lvh.me`. Easy.

[Read more about lvh.me](https://nickjanetakis.com/blog/ngrok-lvhme-nipio-a-trilogy-for-local-development-and-testing#lvh-me)

#### HTTPS

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

## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `rake spec` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/degica/kaiser. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Kaiser project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/degica/kaiser/blob/master/CODE_OF_CONDUCT.md).
