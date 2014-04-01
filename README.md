unbroken
========

A continuous integration library. 

Well it is almost nothing right now, but will probably provide a library
to build local, remote, virtualized or containerized ci runners. 

And lua client configuration able to run commands in the runners.

I started by writing the config files, look at `config/dnode.lua` for the one I started with and then adapted to `config/dnode-alt.lua` which adds travis-ci alike callbacks.

I think this could be used in multiple scenarios, here are a few I am thinking of:

- Local runner:

  Config in `~/.unbroken/my_project.lua`
  
  It is possible to store templates files under  `~/.unbroken/my_project/my_file.conf` that can be accessed by the runner.
  
- Remote runner:

  Actually just the local runner but bound to a tcp port. So probably going to be the same to support http?.

- Docker runner:

  Multiple ways to do it, one would be to run a remote runner in containers and build a proxy between the two.

- etc.

All these will be callable through `bin/unrboken` which would support commands like:

- `build PROJECT`

  Builds the project named PROJECT.

- `buildall`

  Builds all projects.

- `list`
  
  List projects that can be built.

- `status`

  List projects and last build statuses.

These commands are similar to the `cerberus` CI server and think are simple and might be expandable.

Cerberus also supports more commands: `add URL ...` and `remove PROJECT` (TODO: Check if its remove or delete or whatever)

Config will probably change depending on some features runners can provide, I'm thinking of Dockerfiles or simply remote runners setting up services and env variables or writing configs. 

I think plugins should be easy to add, I'm thinking of two kinds:

- generic plugins, used in the config files. (like add beforeInstall hooks, helper functions called on the remote)

- language plugins, they could be implemented in the same way but run different callbacks.
