# writer.py
# Writer for writing string output
import sys, os, stat, atexit, textwrap

class Writer :

    def __init__(self, path) :
        self._path = path
        self._buffer = ''
        atexit.register(self._write)

    def append(self, string) :
        if string.rstrip(' ') == '\n' :
          self._buffer += '\n' 
          return
        strs = string.lstrip('\n').splitlines()
        c = len(strs[0]) - len(strs[0].expandtabs().lstrip(' '))
        for s in strs :
            s = s.expandtabs().removeprefix(c * ' ')
            self._buffer = self._buffer + s + '\n' 
        self._buffer = textwrap.indent(self._buffer, '')

    def _write(self) :
        if self._buffer == '' :
            return
        try:
            with open(self._path,'wb') as f:
                f.write('#!/bin/sh\nset -e\n'.encode('utf-8'))
                f.write(self._buffer.encode('utf-8'))
        except Exception as E :
            print(f"\x1b[0;50;91mError\x1b[0m: {E}, writing failed")
        else :
            st = os.stat(self._path)
            os.chmod(self._path, st.st_mode | stat.S_IEXEC | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)
