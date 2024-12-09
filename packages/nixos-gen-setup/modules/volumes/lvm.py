# lvm.py
# Handle logical volumes 
from ..singletons import ask, askyes
from ..singletons import config
from ..singletons import write
# get luks
from .luks import luks

# for f-strings
_NL = '\\n'

def createlvm() :
    write(f'''
        printf "create LVM2 devices :{_NL}"
    ''')
    # get the config :
    _vgs  = {}
    _lvs  = {}
    paths = {}
    filesystems = [x for x in config('fileSystems').values()]
    swapdevices = [x for x in config('swapDevices')]
    lvms = []
    for dev in (filesystems + swapdevices) :
        lvm = {}
        if 'device'  in dev :
            path = dev['device']
        elif 'label' in dev :
            path = f"/dev/disk/by-label/{dev['label']}"
        elif 'encrypted' in dev :
            path = f"/dev/mapper/{dev['encrypted']['label']}"
        else :
            raise TypeError(f"could not find path for {dev}")
        path = str(path)
        # ignore luks volumes
        if any(map(lambda x: x[0] in path, luks())) :
            continue
        # ignore non device filesystem
        if not path.startswith('/dev') :
            continue
        # ignore filesystem directly on device
        if any(map(lambda x: x in path,  ['by-label', 'by-uuid', 'by-partlabel', 'by-partuuid', 'none'] )):
            continue
        split = path.split('/')
        if len(split) == 4 :
            lvm['label'] = split[-1]
            lvm['vg'] = split[-2]
            lvms.append(lvm)
    lvms = [i for n, i in enumerate(lvms) if i['label'] not in map(lambda x: x['label'],lvms[n + 1:])]
    lvms = sorted(lvms, key = lambda x: x['label'])
    if len(lvms) <= 0 :
        return
    while len(lvms) > 0 :
        if len(lvms) > 1 :
            for idx in range(len(lvms)) :
                print(f"{idx} - {lvms[idx]['label']}")
            num = int(ask('what volume to build first', f'[0-{min(len(lvms)-1,9)}]', '0'))
            lv = lvms[num]
        else :
            lv = lvms[0]
        lvname = lv['label']
        # check if truely a lvm :
        if not askyes(f'is {lvname} a LVM2 device ?') :
            continue
        print(f'LVM block {lvname} :')
        # vg name
        try : 
            vgname = lv['vg']
            print(f'Found : {lvname} volume group is {vgname}')
        except :
            try :
                default = [ x['vg'] for x in _lvs if 'vg' in x][0]
            except:
                default = "vg01"
            vgname = ask(f'what is the name of the volume group for {lvname} ?', r'[a-z0-9\-_]+', default )
        # find block device
        if vgname not in _vgs :
            try :
                default = [ x for x,z in _vgs.items()][0]
            except:
                default = "vg01"
            block = ask(f'what is the underlying block device for {lvname} ?', r'/dev/[a-z0-9\-/]+', default)
        else : 
            block = _vgs[vgname]
            print(f'Found : {lvname} is physically on {_vgs[vgname]} ')
        # volume size
        size = ask(f'what size for {lvname} ?', r'[0-9.]+[MGT]|%(?:FREE|VG)?')
        size = f'-l {size}' if '%' in size else f'-L {size}'
        _lvs[lvname] = {
            'vg' : vgname,
            'size' : size
        } 
        _vgs[vgname] = block
        # for other systems :
        paths[lvname] = f'/dev/{vgname}/{lvname}'
        lvms.remove(lv)

    # now create them
    for vgname, block in _vgs.items()  :
        write(f'''
            if [ "$(pvdisplay {block} 2>/dev/null)" ]
            then
                printf "physical volume on {block} already exists, skipping{_NL}"
            else
                pvcreate {block}
            fi
            if [ "$(vgdisplay {vgname} 2>/dev/null)" ]
            then
                printf "volume {vgname} already exists, skipping{_NL}"
            else
               vgcreate {vgname} {block}
            fi
        ''')
    for lvname , lvinfo in _lvs.items() :
        write(f'''
            if [ "$(lvdisplay {paths[lvname]} 2>/dev/null)" ]
            then
                printf "logical volume {lvname} already exists, skipping{_NL}"
            else
                 lvcreate {lvinfo['size']} -n {lvname} {lvinfo['vg']}
            fi''')

