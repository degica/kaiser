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

Or if you use fish

```
function kaiser
  docker run --rm -ti -v /var/run/docker.sock:/var/run/docker.sock -v $HOME/.kaiser:/root/.kaiser -v (pwd):(pwd) -e CONTEXT_DIR=(pwd) degica/kaiser $argv
end
```

## Usage

You'll need a Dockerfile and a Kaiserfile. The Kaiserfile should be placed in the project root directory, with contents like this:

```ruby
# Example Kaiserfile for a Rails app

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

#### Anatomy of a Kaiserfile

A Kaiserfile is made up of statements, which are different commands followed by some parameters. Each command is just a ruby method so you can call it that way. Only the `dockerfile` command is required. All the other commands are either not required or have defaults.

- `plugin` - Takes 1 parameter: the name of the plugin you wish to use in this Kaiserfile.

```ruby
# Example
plugin :git_submodule
```

See further below to find available plugins and their usage

- `dockerfile` - This command is always required. Takes 1 parameter: the name of the Dockerfile you want to use with this Kaiserfile. You only need to use this command once. Using it multiple times will simply cause the last command to be used. It takes relative paths and the paths are relative to where you run Kaiser.

```ruby
# Example
dockerfile 'Dockerfile'
```

- `attach_mount` - Takes 2 parameters: The first parameter is the relative path of a folder or a file outside the container and the second parameter is its absolute path inside the container. This is only used when `kaiser attach` or `kaiser up -a` is used. This will mount the file or folder inside the container and sync their contents. If the file you specified does not exist, Kaiser will create a folder where you specify it and then mount that folder inside the container. You can specify as many of these as you want.

```ruby
# Example to mount the `app` directory into the container's `/srv/files/app`
attach_mount 'app', '/srv/files/app'
```

- `expose` - Takes 1 parameter: The port of the server running inside the container. This port is not exposed on the host, so it will not occupy a port on the computer you run kaiser on. Instead, Kaiser will select a random port on the host computer to forward traffic to and from. You can only use this statement once. If you have multiple of these statements the last one will be used.

```ruby
# Example to expose the port 3636
expose 3636
```

- `app_params` - Takes 1 parameter: A string of parameters to the `docker run` command to add custom environment variables with. Please refer to the docker documentation to see what kinds of parameters you can pass to the `docker run` command. By default this is just an empty string. You can only pass one of these. Any newline characters in the string will be converted into spaces.

```ruby
# Example
app_params '-e INTERACTIVE=no'
```

- `type` - Takes 1 parameter: Right now the only parameter it can take is `:http`. If this parameter is specified, kaiser will poll the application until it receives a 200 status code before it closes when you use `kaiser up` If it doesn't it will close with a status code of 1.

```ruby
# Example
type :http
```

- `db_reset_command` - Takes 1 parameter: A command to reset the database. This command is optional. By default this parameter is `echo "no db to reset"`. You can only specify one of these. If you have multiple of these commands only the last one will be used.

```ruby
# Example if running this command drops the db and recreates it.
db_reset_command 'rake db:reset'
```

- `db` - Takes 1 parameter in the form of a hash. The default value of the hash is as follows:

(You do not have to use this strictly, see the Database Plugin below to see an easier way to include MySQL and Postgres in your environment)

```ruby
# Default settings
{
  image: 'alpine',
  port: 1234,
  data_dir: '/tmp/data',
  params: '',
  commands: 'echo "no db"',
  waitscript: 'echo "no dbwait"',
  waitscript_params: ''
}
```

You can use this to customize the database that you wish to use with your server.

### Alternative Kaiserfile

If you want change your dev environment for a project, but don't want to overwrite the project's Kaiserfile/Dockerfile,
you can use an alternative Kaiserfile.

An alternative Kaiserfile is located at `~/kaiserfiles/Kaiserfile.<app name>`,
where `<app name>` is replaced with the name you provided when calling `kaiser init`.

If Kaiser detects an alternative Kaiserfile, it will use it instead of the Project root one. Some things to watch out for:

- Of course, your app may behave differently if you change your environment from the project's default.
- The `dockerfile` declaration is still relative to the project root. If you want to use a custom Dockerfile as well, you need to specify the its full path in the Kaiserfile.
- If the project's Kaiserfile or Dockerfile changes, you'll have to update your custom ones manually.

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

## Plugins

Kaiser has a plugin system that adds commands to the Kaiserfile to help improve your workflow. Below are a list of built-in plugins that come with Kaiser.

### Git Submodules Plugin

This plugin ensures that any submodules your repo has are checked out. If they are not, it will cause Kaiser to exit with a status code of 1.

Usage:

```ruby
plugin :git_submodule
```

That's all you need!

### Database Plugin

This plugin allows you to specify well known DBs (MySQL and PostgresSQL) with default values that work generally. You can customize your database however you want it for your own project.

Usage:

```ruby
# Simplest usage
plugin :database

def_db :mysql
```

If for example you wish to use a different root password, simply go

```ruby
plugin :database

def_db mysql: { root_password: 'extremesecret' }
```

Sometimes you want to use a specific version for testing. You can set up the version by going

```ruby
plugin :database

def_db postgres: { version: '9.4' }
```

You can also pass startup parameters to your database server:

```ruby
plugin :database

def_db mysql: { parameters: '--verbose' }
```

## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `rake spec` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/degica/kaiser. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Kaiser project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/degica/kaiser/blob/master/CODE_OF_CONDUCT.md).
