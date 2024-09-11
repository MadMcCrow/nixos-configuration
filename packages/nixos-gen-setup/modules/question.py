# question.py
# helper function for asking question to the user

import re, os, json, atexit, hashlib

def _matchregex(string, regex) :
    sch = re.search(f'^{regex}$', string)
    return True if sch is not None else False

def askyes(question, default_is_yes = True) :
    result = ask(question, '|'.join(['Yes', 'No', 'yes', 'no', 'y', 'n', 'N', 'Y']), 'yes' if default_is_yes else 'no') 
    return result.lower().startswith('y')

def ask(question : str, regex, default = '') :
    # create form if necessary
    global singleton
    try : 
        singleton
    except :
        singleton = Form()
    #pass to the form
    return singleton.ask(question, regex, default)   


class Form :
    '''
        the class that perform the asking of question
        It remembers the questions and reload the anwsers
        to make relaunch faster
    '''
    
    def __init__(self) :
        self._path = os.path.normpath('./.anwsers')
        try : 
            with open(self._path, 'r') as f :
                self._dict = json.loads(f.read())
        except FileNotFoundError :
            self._dict = dict()
        atexit.register(self.save)

    def save(self) :
        try:
            with open(self._path, 'w') as f :
                f.write(json.dumps(self._dict))
        except :
            raise


    def ask(self, question, regex, default) :
        h = str(hashlib.md5(question.encode('utf-8')).hexdigest())
        if h in self._dict :
            default = self._dict[h]
        if default != '' : 
            print(f'{question}\x1b[0;50;95m[{default}]\x1b[0m')
        else :
            print(f'{question}')
        answer = input()
        if answer == '' :
            answer = default
        if _matchregex(answer, regex) :
            if answer != default : # only save what differs from default
                self._dict[h] = answer
            return answer
        print(f'\x1b[0;50;91invalid response\x1b[0m: ({answer}), try again')
        return self.ask(question, regex, default)
