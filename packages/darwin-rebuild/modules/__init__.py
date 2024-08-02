#!/usr/bin/python
# try to import everything and warn of missing libraries :
import sys

try :
    from rich import print
except:
    print('Warning: rich module not found, output will not be easily readable')

try :
    import sh
except:
    print('Error: python module sh not found, script cannot work')
    sys.exit(1)

try :
    import shutil
except:
    print('Error: python module shutil not found, script cannot work')
    sys.exit(1)

try :
    import urllib
except:
    print('Error: python module urllib not found, script cannot work')
    sys.exit(1)