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

Confirm it is working by running

```
kaiser -h
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

## More documentation

You can find even more documentation in https://tech.degica.com/kaiser.

If you wish to read a HTML version of this documentation you can go:

```
cd docs
bundle install
bundle exec weaver
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
