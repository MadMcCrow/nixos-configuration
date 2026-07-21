# exceptions.py :
#       execute commands

from shutil import which

class ShellException(Exception):
    """
    Error during shell command
    """
    def __init__(self, cmd, message, *args):
        self.message = message # without this you may get DeprecationWarning
        self.cmd = cmd

class CommandNotFoundException(ShellException):
    """
    Command does not exist, shell cannot run
    """
    def __init__(self, cmd, message = "", *args):
        message = f"{cmd} : command not found." + message
        super(CommandNotFoundException, self).__init__(cmd, message, *args)

def assert_cmd(cmd : str) :
    if which(cmd) is None :
        raise CommandNotFoundException(cmd)

