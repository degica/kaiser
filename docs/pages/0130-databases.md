title: Databases

---

## Setting up a Database for your app

The easiest way to setup a database for your app to use is add the folliwing to your Kaiserfile:

```ruby
plugin :database

def_db :mysql # or :postgres
```

For more information about the database plugin, go to the [plugins page](/0510-plugins)

Usually at a base level you would want to define your root password and database version at least. That can be done with

```ruby
plugin :database

def_db mysql: {
  version: '8.0',
  root_password: 'secret'
}
```

And, in order to provide your application with access to it, simply give the application information about the database.

For example, to give the MySQL details to your Rails application, do the following:

```ruby
dockerfile 'Dockerfile'

plugin :database

def_db :mysql: {
  version: '8.0',
  root_password: 'secret'
}

app_params "
  -e DATABASE_URL=mysql2://root:secret@<%= db_container_name %>
  ...

```

You can also pass information in as separate pieces, like how a PHP application typically expects. Here is an example with postgres:

```ruby
dockerfile 'Dockerfile'

plugin :database
def_db postgres: { root_password: 'verysecret' }

app_params "
    -e DB_USER=postgres
    -e DB_PASS=verysecret
    -e DB_NAME=awesome_db
    -e DB_HOST=<%= db_container_name %>
    -e DB_PORT=5432
```
