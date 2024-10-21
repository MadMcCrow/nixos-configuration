#
# main function to perform 
#
from .singletons import setflake, sethost, setoutput, write, config
from .volumes import volumes
from .filesystems import umountall, filesystems
from .swap import swap
from .install import install

def script(hostname, path, flake = '.') :
    setoutput(path)
    sethost(hostname)
    setflake('.') # always local !
    # parse config :
    config('fileSystems')
    config('swapDevices')
    config('boot.initrd.luks.devices')
    # check sript is run with sudo
    write('''
    if [ "$EUID" -ne 0 ]
        then echo "Please run as root"
    exit
    fi
    ''')
    # make filesystems
    umountall()
    volumes()
    swap()
    filesystems()
    # perform install :
    install(flake, hostname)
