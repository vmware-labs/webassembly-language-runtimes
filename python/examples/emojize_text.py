"""
Sample script that replaces words with their emoji codes,
if there are any. Depends on the `emoji` module.

"The rabbit is eating a carrot." will be transformed to:
"The 🐇 is eating a 🥕."

Prints on stdout if no OUTPUT_FILE is given.

Usage:
emojize_text.py SOURCE_FILE [OUTPUT_FILE]
"""
import sys;
from emoji import unicode_codes;

# Open source file
source_file_path = sys.argv[1]
source_file = open(source_file_path, 'r')

# Prepare output file
out_file = open(sys.argv[2], 'w') if len(sys.argv) > 2 else sys.stdout

# Transform text
emoji_dict = unicode_codes.get_emoji_unicode_dict('en')
output = ''
for line in source_file.readlines():
    output_line = []
    for word in line.split():
        output_line.append(emoji_dict.get(f':{word}:', word))
    out_file.write(" ".join(output_line))
    out_file.write('\n')

# Print output
print(output)
