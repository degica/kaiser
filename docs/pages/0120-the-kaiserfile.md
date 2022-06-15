title: The Kaiserfile

---

## The Kaiserfile

The Kaiserfile a file that you add to your docker-based application. The most basic form a Kaiserfile can take has already been shown in the [Getting Started](/0110-getting_started) page:

```
dockerfile 'Dockerfile'

expose 8080
```

But what does this all mean?

---

## Kaiserfile Statements

A Kaiserfile is made up of statements, which are different commands followed by some parameters. Each command is just a ruby method so you can call it that way. Only the `dockerfile` command is required. All the other commands are either not required or have defaults.

- `plugin` - Takes 1 parameter: the name of the plugin you wish to use in this Kaiserfile.

```ruby
# Example
plugin :git_submodule
```

See [plugins](/0510-plugins) to find available plugins and their usage

- `dockerfile` - This command is always required. Takes 1 parameter: the name of the Dockerfile you want to use with this Kaiserfile. You only need to use this command once. Using it multiple times will simply cause the last command to be used. It takes relative paths and the paths are relative to where you run Kaiser.

```ruby
# Example
dockerfile 'Dockerfile'
```

- `service` - This command is optional. Use it to define additional containers that should be set up along with your environment,. You can use it multiple times to define multiple services. It takes multiple parameters, a name parameter which is required and optional parameters.

```ruby
# example that sets up a redis server for your app
service 'redis'
```

The following parameters are allowed for this command:
- image

```ruby
# example that tells it to use the redis server with the alpine tag from 'myrepo'
service 'redis', image: 'myrepo/redis:alpine'
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

(You do not have to use this strictly, see the Database [plugins](/0510-plugins) to see an easier way to include MySQL and Postgres in your environment)

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

---

## Alternative Kaiserfile

If you want change your dev environment for a project, but don't want to overwrite the project's Kaiserfile/Dockerfile,
you can use an alternative Kaiserfile.

An alternative Kaiserfile is located at `~/kaiserfiles/Kaiserfile.<app name>`,
where `<app name>` is replaced with the name you provided when calling `kaiser init`.

If Kaiser detects an alternative Kaiserfile, it will use it instead of the Project root one. Some things to watch out for:

- Of course, your app may behave differently if you change your environment from the project's default.
- The `dockerfile` declaration is still relative to the project root. If you want to use a custom Dockerfile as well, you need to specify the its full path in the Kaiserfile.
- If the project's Kaiserfile or Dockerfile changes, you'll have to update your custom ones manually.