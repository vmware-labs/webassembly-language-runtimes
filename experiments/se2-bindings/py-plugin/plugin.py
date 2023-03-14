import sdk
import re

def log(msg, id=None):
    print(f'\033[35m    [plugin.py]\033[0m | id={id} | {msg}', flush = True)

def reverse(s):
    str = ""
    for i in s:
        str = i + str
    return str

def process_word(word):
    # Reverse only words without non-letter signs
    return word if re.match(r"\w+[.,'!?\"]\w*", word) else reverse(word)

def run_e(payload, ident):
    log(f'Received payload "{payload}"', ident)

    text_words = payload.split(' ')
    result = ' '.join([process_word(w) for w in text_words])

    log(f'Returning result "{result}"', ident)
    sdk.return_result(result, ident)

    log(f'Result returned for "{ident}"', ident)
