# for fstrings
_NL = '\\n'

from ..singletons import write


class Filesystem :

    def __init__(self, configdict : dict ) :
        # lets hope this works all the time
        self.mountpoint = configdict['mountPoint']
        self.options = configdict['options']
        self.fstype = configdict['fsType']
        # this should equal mountpoint
        self.name = configdict['name']
        # lets get unique device settings
        if configdict['encrypted']['label'] is not None :
            self.device = f"/dev/mapper/{configdict['encrypted']['label']}"
        elif configdict['encrypted']['blkDev'] is not None :
            self.device = f"{configdict['encrypted']['blkDev']}"
        elif configdict['label'] is not None :
            print(f'LBL:{self.name}')
            self.device = f"/dev/mapper/{configdict['label']}"
        elif configdict['device'] != "none" :
            self.device = configdict['device']
            
    def setup(self) :
        pass

    def mkfs_cmd(self) -> str :
        return f'mkfs.{self.fstype} {self.device} 1> /dev/null'

    def mkfs(self) :
        write (f'''
        if [ $(blkid {self.device} -s TYPE -o value) == "{self.fstype}" ];
        then
            read -r -p "{self.device} ({self.mountpoint}) already formated as {self.fstype}, format anyway? [y/N]" response
            response=${{response,,}}
            if [[ $response =~ ^(n| ) ]] || [[ -z $response ]]; 
            then
                printf 'skipping format for {self.device}{_NL}'
            else
                {self.mkfs_cmd()}
                partprobe &> /dev/null || true
            fi
        else
            {self.mkfs_cmd()}
            partprobe &> /dev/null || true
        fi
        ''')

    def mount(self) :
        opts = list(filter(lambda x: x != 'x-initrd.mount', self.options))
        mp = f"/mnt{self.mountpoint}"
        check = """mount | awk '{if ($3 == "%s") { exit 0}} ENDFILE{exit -1}'""" % mp
        write(f'''
            if $({check})
            then
                printf "{mp} already mounted{_NL}"
            else
                printf "mounting {mp}{_NL}"
                mkdir -p {mp} {self.device if 'bind' in opts else ''}
                mount {'-o ' + ','.join(opts) if len(opts) > 0 else ''} {self.device} {mp}
            fi
            ''')

     