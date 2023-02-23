import sdk

def reverse(s):
    str = ""
    for i in s:
        str = i + str
    return str

def run_e(payload, ident):
    print(f'\t\tplugin.py | id={ident} | Received payload "{payload}"')
    result = reverse(payload)

    print(f'\t\tplugin.py | id={ident} | Returning result "{result}"...')
    sdk.return_result(result, ident)

    print(f'\t\tplugin.py | id={ident} | Result returned for {ident}.')
