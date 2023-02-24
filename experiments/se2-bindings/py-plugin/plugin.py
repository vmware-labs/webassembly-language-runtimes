import sdk

def log(msg, id=None):
    print(f'\033[35m    [plugin.py]\033[0m | id={id} | {msg}', flush = True)

def reverse(s):
    str = ""
    for i in s:
        str = i + str
    return str

def run_e(payload, ident):
    log(f'Received payload "{payload}"', ident)
    result = reverse(payload)

    log(f'Returning result "{result}"', ident)
    sdk.return_result(result, ident)

    log(f'Result returned for "{ident}"', ident)
