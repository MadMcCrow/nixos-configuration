#
# main function to perform 
#
from . import volumes, config, filesystems, writer

def script(hostname, path, flake = '.', local = True) :
    conf = config.Config(hostname, flake if not local else '.')
    wtr  = writer.Writer(path)
    _sudocheck(wtr)
    _format(conf, wtr)
    _nixos_install(flake, hostname, wtr)

def _sudocheck(wtr) :
    wtr.append('''
    if [ "$EUID" -ne 0 ]
        then echo "Please run as root"
    exit
    fi
    ''')

def _format(conf, wtr) :
    # first off build volumes :
    volumes.format_luks(conf,wtr)
    volumes.open_luks(conf,wtr)
    volumes.create_lvm(conf,wtr)
    filesystems.format_fs(conf,wtr)
    filesystems.mount_fs(conf,wtr)

def _mount(conf, wtr) :
    volumes.open_luks(conf,wtr)
    filesystems.mount_fs(conf,wtr)

def _nixos_install(flake, hostname, wtr) :
    wtr.append(f'''
    echo "starting nixos install :"
    nixos-install --flake {flake}#{hostname}
    ''')
  

