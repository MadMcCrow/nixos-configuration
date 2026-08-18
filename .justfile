mod ostool
mod packages

[default, parallel]
dev : _update_template _update_packages

_update_template :
    just ostool template update

_update_packages :
    just packages update