mod ostool
mod packages

[parallel]
dev : _update_template _update_packages

_update_template :
    just ostool update_template

_update_packages :
    just packages update