#!/usr/bin/env python
# useful class for decrypting output

class Output() :
    """
    the result of a runcmd call
    """
    def __init__(self) -> None:
        self._errors = []
        self._output = []

    def __repr__(self) -> str:
        output = '\n'.join(self._output)
        errors = '\n'.join(self._errors)
        return str({"stdout" : output, "stderr" : errors})

    def __str__(self) -> str :
        return '\n'.join(self._output)

    def addLine(self, txt : str) :
        self._output.append(txt)

    def addError(self, txt : str) :
        self._errors.append(txt) 