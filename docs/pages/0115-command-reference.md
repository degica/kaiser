title: Command Reference

---

## Command Reference

This is a reference for commands available in Kaiser. It is sorted by importance but not necessarily by how one would use them.

### Global Options

These options can be used with any of the commands below.

#### `-v` `--verbose` Verbose mode

Verbose mode. This tells Kaiser to spit out all the output of the commands it runs so it is clear if something went wrong. By default, Kaiser simply writes a period character for each line of output to avoid being noisy.

---

## `kaiser init`

This initializes an environment in Kaiser. In reality this assigns your current directory to a particular environment name. For example

```
kaiser init hats
```

Will assign this directory to the name `hats`.

This is an important first step because this will determine the domain name you can use to access this environment. For example if you start it up the domain will be `hats.lvh.me` if you did not set the suffix. If you did set the suffix the domain will be `hats.<whatever the suffix is>`. More info [on suffixes here](/0140-suffixes).

### Errors

- This command requires you be in a directory that has a Kaiserfile. If you don't have one, you will get the message

```
Error: No Kaiserfile in current directory.
Try --help for help.
```

- If you try to run this command without an environment name you will get

```
Error: Needs environment name.
Try --help for help.
```

- If you already initialized the current directory in Kaiser you will get this message:

```
Error: Already initialized as hats.
Try --help for help.
```

---

## `kaiser up`

This command will bring up the app in the current directory, but only if it was initialized using `kaiser init`.

Usually in user testing we noticed that most people prefer to start up their environment using `kaiser up -av`.

### Options

#### `-a` `--attach` Attach

Attaches to the process after starting up. By default Kaiser will start up the app and run in the background. Using this parameter the process will run in the foreground, which can be useful for debugging or if you are in a GUI where switching terminals is very easy.

If you use this option, and bash `exit` or Ctrl+C interrupt out and the process you started ends, it will close the process. Unlike if you ran `kaiser up` without this option, and then ran `kaiser attach`.

### Parameters

This command takes a command line as parameters, which means you can go `kaiser up -av bash`. This will start the application in the foreground and run `bash`. You can also use it to go `kaiser up -av rails c` or `kaiser up -av sh -c 'mylongcommand; andmorestuff'` or whatever suits your fancy.

### Errors

- If you try running this command in a directory that has not been initialized, you will get the error:

```
Error: No environment? Please use kaiser init <name>.
Try --help for help.
```

---

## `kaiser login <cmd>`

If there already exists a running process that was started by `kaiser up`, you can simply login from the side using the default user as defined in its Dockerfile this way. Usually you want to provide a parameter, such as `kaiser login bash` or something. It will always be started in TTY and interactive.

### Errors

- If you try and run this in a dir where the process is not up and running, you will get a message like this:

```
Error response from daemon: No such container: hats-app
```

or one like this:

```
Error response from daemon: container ceff5f43ca1632294512afd1ed88e30d051bd97438204bb34674fea75e001eab is not running
```

---

## `kaiser root <cmd>`

This command is essentially the same as `kaiser login` except it forces the login to use the `root` user. This can sometimes be useful if the container was built with very tight perms on the user, or does not have `sudo` installed in it.

---

## `kaiser show <thing>`

This shows special globals that were set using `kaiser set`. Valid parameters right now are

- `ports`
- `cert-source`
- `http-suffix`

### Parameters

#### `ports` Ports reserved for app

This tells you what ports are reserved for the app. While most traffic should go to the thing through the environment name, sometimes you want the actual port number if you want to connect to it to check stuff. Example output is:

```
app: 9015
db: 9016
```

#### `cert-source` Certificate source

This tells you the URL from which SSL/HTTPS certificates are downloaded from. You can use this to check if you have it set to the right URL.

#### `http-suffix` HTTP Suffix

This tells you what the HTTP suffix is. See [suffixes](/0140-suffixes). Usually you use this with conjunction with the cert source above so you can request wildcard certificates from domains you own and then tell nginx to serve those suffixes so you can have an SSL setup on your local.

### Errors

- If you do not specify what thing, `kaiser` will try to be helpful and tell you:

```
Error: Available things to show: ports cert-source http-suffix.
Try --help for help.
```

---

## `kaiser shutdown`

This command shuts down all the containers started by Kaiser.

---

## `kaiser deinit`

This command removes the current environment from the kaiser configuration, and essentially undoes the effects of the `kaiser init` command.

---

## `kaiser db_save`

This command saves the current state of the database of the application. By default it saves it in a file in the `$HOME/.kaiser` directory. But you can also specify a file for it to write to by going `kaiser db_save ./mydb.mysql`.

### Notes

The default save file is actually **git branch aware**. What this means is that kaiser checks what git branch it is in right now and keys the file on that branch name.

This means that if you

1. checked out the `main` branch
2. ran `kaiser db_save` and then
3. checked out `mybranch` branch and then
4. ran `kaiser db_save`

it will save the state to a different file and not overwrite the db state saved when you were in the `main` branch. How it saves this file is actually an implementation detail and we don't make any guarantees about how it really works or if it will not change.

---

## `kaiser db_load`

This command loads the saved state of the database of an application (if one exists), and destroys the previous state. By default it loads the file for the branch you are on. You can provide a parameter to load a file instead, like `kaiser db_load ./mydb.mysql`

---

## `kaiser db_reset`

This command re-runs the command defined in the `db_reset_command` in the [Kaiserfile](/0120-the-kaiserfile).

---

## `kaiser db_reset_hard`

Sometimes a db state can become somewhat inconsistent or the command defined by `db_reset_command` in the [Kaiserfile](/0120-the-kaiserfile) does not handle all cases of db consistency. This command actually deletes the current state and re-initializes the database from scratch, and then runs the command defined by `db_reset_command`. This can be used to work around a messed up database state.

---

## `kaiser set <key> <value>`

### Parameters

Valid `<key>` parameters are:

- `http-suffix` - Sets the domain suffix for the reverse proxy to use (defaults to lvh.me)
- `cert-url`    - Sets up a URL from which HTTPS certificates can be downloaded.

For example you can go

`kaiser set http-suffix local.aweso.me` and nginx will serve everything on that suffix, i.e. `hats.local.aweso.me`.

### Errors

- If you do not provide a key and value it will fail like this:

```
Error: Unknown subcommand: ''.
Try --help for help.
```

---

## `kaiser attach`

If you started kaiser using just `kaiser up` without the `--attach` option, you can use this command to "takeover" the process and bring it up to the foreground. This is useful if you intend to apply a breakpoint and interrupt the process, which means you want to be able to make it interactive so you can gracefully unbreakpoint it without having to kill it.

You can also Ctrl+C to interrupt out of this without closing the process, unlike if you used the `--attach` option, which if you used that would close the process.
