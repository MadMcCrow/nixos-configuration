# luks.py
# Handle encrypted volumes 
from ..singletons import ask, askyes
from ..singletons import config
from ..singletons import write
# for f-strings
_NL = '\\n'

def luks() -> list :
    # get luks from config
    configluks = config('boot.initrd.luks.devices')
    nixluks = [ (x, configluks[x]) for x in set(configluks.keys())]
    return nixluks
    
def createluks() :
    write(f'''
        #{'-' * 30}
        echo "creating LUKS devices"
    ''')
    for vn, vd in luks() :
        dev = vd['device'] or f"/dev/mapper/{vd['encrypted']['label']}"
        print(f"will create luks volume \x1b[0;35;3m{vn}\x1b[0m on device \x1b[0;35;3m{dev}\x1b[0m")
        if askyes(f'Force recreate {vn} ? (this will erase everything)', False) :
            write(f'''
            printf "{_NL}creating luks encrypted drive \x1b[0;35;3m{vn}\x1b[0m{_NL}"
            cryptsetup --verbose luksFormat --verify-passphrase {dev}     
            ''')
        else :
            write(f'''
            if ! [ -e {dev} ]
            then
                printf "\x1b[0;31;1mError\x1b[0m : cannot find disk {dev} : please fix your config !{_NL}"
                return 1 # error
            fi
            TYPE=$(blkid {dev} -s TYPE -o value)
            if ! [ -e /dev/mapper/{vn} ]
            then
            if [ $TYPE == "crypto_LUKS" ]
            then
                printf "luks encrypted drive \x1b[0;35;3m{vn}\x1b[0m already exists, trying to open it{_NL}"
                cryptsetup -v luksClose {vn} &> /dev/null || true
                if cryptsetup -v luksOpen {dev} {vn}
                then
                    printf "luks encrypted drive \x1b[0;35;3m{vn}\x1b[0m successfully decrypted{_NL}"
                else
                    printf "rebuilding luks encrypted drive \x1b[0;35;3m{vn}\x1b[0m{_NL}"
                    cryptsetup --verbose luksFormat --verify-passphrase {dev}
                fi
            else
                printf "{_NL}creating luks encrypted drive \x1b[0;35;3m{vn}\x1b[0m{_NL}"
                cryptsetup --verbose luksFormat --verify-passphrase {dev}          
            fi
            fi
            ''')

def openluks() :
    write(f'''
        #{'-' * 30}
        echo "opening luks devices"
    ''')
    for vn, vd in luks() :
        write(f'''
        if ! [ -e /dev/mapper/{vn} ]
        then
            printf "{_NL}open luks encrypted drive \x1b[0;35;3m{vn}\x1b[0m{_NL}"
            cryptsetup -v luksOpen {vd['device']} {vn}
        fi
        ''')