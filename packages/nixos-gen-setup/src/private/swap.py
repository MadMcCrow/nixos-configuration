# swap.py
# enable swap for installation
from .singletons import config, write

# for fstrings
_NL = '\\n'

def swap() : 
    swap = [x['device'] for x in config('swapDevices')]
    for s in swap :
        write(f'''
                if (swaplabel {s} &>/dev/null); then
                    printf 'swap detected on  {s}:'
                    swapoff {s} &> /dev/null || true
                else
                    printf 'creating swap on  {s}:'
                    mkswap  {s}
                fi
                printf ' enabling swap {_NL}'
                swapon {s}
            ''')

