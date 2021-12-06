title: Plugins

---

# Plugins

Kaiser has a plugin system that adds commands to the Kaiserfile to help improve your workflow. Below are a list of built-in plugins that come with Kaiser.

---

## Git Submodules Plugin

This plugin ensures that any submodules your repo has are checked out. If they are not, it will cause Kaiser to exit with a status code of 1.

Usage:

```ruby
plugin :git_submodule
```

That's all you need!

---

## Database Plugin

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
