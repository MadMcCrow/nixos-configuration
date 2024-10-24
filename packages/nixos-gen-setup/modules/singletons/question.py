# question.py
# helper function for asking question to the user
import re, os, json, atexit, hashlib
from .metasingleton import MetaSingleton

class Form(metaclass = MetaSingleton) :
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

    def askyes(self, question, default_is_yes = True) :
        result = self.ask(question, '|'.join(['Yes', 'No', 'yes', 'no', 'y', 'n', 'N', 'Y']), 'Yes' if default_is_yes else 'No') 
        return result.lower().startswith('y')

    def ask(self, question : str, regex, default = '') :
        h = str(hashlib.md5(question.encode('utf-8')).hexdigest())
        if h in self._dict :
            default = self._dict[h]
        if default != '' : 
            prompt = f'{question}\x1b[0;50;95m[{default}]\x1b[0m '
        else :
            prompt = f'{question} '
        answer = input(prompt)
        # get default :
        if answer == '' :
            answer = default
        # detect that it matches regex 
        if re.search(f'^{regex}$', answer) is not None :
            # only save what differs from default
            if answer != default : 
                self._dict[h] = answer
            return answer
        # restart the question :
        print(f'\x1b[0;50;91invalid response\x1b[0m: ({answer}), try again')
        return self.ask(question, regex, default)

    def save(self) :
        try:
            with open(self._path, 'w') as f :
                f.write(json.dumps(self._dict))
        except :
            raise

