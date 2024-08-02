import os

class ANSICOLORS :
    default = 0
    brighter = 1
    underlined = 4
    flashing = 5
    black_foreground = 30
    red_foreground   = 31
    green_foreground = 32
    yellow_foreground = 33
    blue_foreground = 34
    purple_foreground = 35	
    cyan_foreground = 36	
    white_foreground = 37	
    black_background = 40	
    red_background = 41	
    green_background = 42	
    yellow_background = 43	
    blue_background = 44	
    purple_background = 45	
    cyan_background = 46	
    white_background = 47	
    
def has_colors():
    if os.environ.get('NO_COLOR'):
        return False
    elif os.environ.get('CLICOLOR_FORCE'):
        return True
    elif os.environ.get('CLICOLOR'):
        return sys.stdout.isatty()
    else :
        return False

# code to use to remove any previous codes
clear_code = f'\x1b[0m'

# get a code with infos :
def get_color_code(foreground, background, style = None) :
    l = [ style, foreground, background ]
    format = ';'.join(list(map(lambda x: str(x), [s for s in l if s is not None])))
    return f'\x1b[{format}m'

