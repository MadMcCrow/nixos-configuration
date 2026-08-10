# default recipe
help:
    echo 'run one of the following recipes : install, init, update, format'

# import all the other recipes
import './tools/install/justfile'
import './tools/init/justfile'
