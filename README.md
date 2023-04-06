# Prequisites

`svn` and `dosbox` must be available to run from the command line.

On Ubuntu this can be done with apt:
`sudo apt install subversion dosbox`

To use the helper scripts (not mandatory, but nice), `just` must be installed. It is often found in your distributons package manager, but you may need to follow specific instructions in [its repository](https://github.com/casey/just). If `just` is not installed, consult the `.justfile` and find the relevant recipe when needed.

# Setting up

After first cloning the project, perform `just init` to retrieve all submodules and dependencies.
