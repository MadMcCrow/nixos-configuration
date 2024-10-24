# install.py
# start nixos-install
from .singletons import write, ask

# for fstrings
_NL = '\\n'

def install(flake, hostname) :
    tmpdir = ask('what directory to use for building nixos ?', r'/mnt/[a-z0-9\-/]+', '/mnt/tmp')
    write (f'''
        echo "starting nixos install :"
        TMPDIR={tmpdir} nixos-install --flake {flake}#{hostname} --no-root-passwd
    ''')
