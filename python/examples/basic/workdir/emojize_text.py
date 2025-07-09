"""
Sample script that replaces words with their emoji codes,
if there are any. Depends on the `emoji` module.

"The rabbit is eating a carrot." will be transformed to:
"The 🐇 is eating a 🥕."

Prints on stdout if no OUTPUT_FILE is given.

Usage:
emojize_text.py SOURCE_FILE [OUTPUT_FILE]
"""
import sys
from emoji import emojize

# Open source file
source_file_path = sys.argv[1]
source_file = open(source_file_path, 'r')

# Prepare output file
out_file = open(sys.argv[2], 'w') if len(sys.argv) > 2 else sys.stdout

# Transform text
output = ''
for line in source_file.readlines():
    output_line = []
    for word in line.split():
        # Try to convert the word to an emoji using the format :word:
        emoji_word = emojize(f':{word}:', language='en')
        # If the word wasn't converted (still has colons), use the original word
        if emoji_word == f':{word}:':
            output_line.append(word)
        else:
            output_line.append(emoji_word)
    line_text = " ".join(output_line)
    out_file.write(line_text)
    out_file.write('\n')
    # Accumulate output for the final print
    output += line_text + '\n'

# Print output
print(output)

# Print output
print(output)
