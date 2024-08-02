#
# main function to perform 
#
from . import volumes, config, filesystems, writer

def script(hostname, path, formatdisk = True) :
    conf = config.Config(hostname)
    wtr  = writer.Writer(path)
    if formatdisk :
        _format(conf, wtr)
    else :
        _mount(conf, wtr)

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
  

