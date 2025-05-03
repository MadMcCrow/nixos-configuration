# singletons.py
# all singletons used in our script
from .question import Form
from .config import Config
from .writer import Writer

# question
# ignore singleton, pass functions directly
def askyes( question, default_is_yes = True) :
    return Form().askyes(question, default_is_yes)
def ask(question : str, regex, default = '') :
    return Form().ask(question, regex, default)

# config
def sethost(hostname) :
    Config().hostname(hostname)
def setflake(flake = '.') :
    Config().flake(flake)
def config(attribute) :
    return Config().get(attribute)

# writer
def setoutput(path):
    Writer().set_path(path)
def write(text) :
    Writer().append(text)