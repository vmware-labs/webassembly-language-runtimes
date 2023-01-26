"""
Sample script that generates a letter histogram for
a given text and renders it as an SVG bar chart. Depends
on the 'pygal' module.

Prints on stdout if no OUTPUT_FILE is given.

Usage:
text_histogram.py SOURCE_FILE [OUTPUT_FILE]
"""
import pygal
import string
import sys

# Open source file
source_file_path = sys.argv[1]
source_file = open(source_file_path, 'r')

# Prime the histogram
histogram = dict.fromkeys(string.ascii_lowercase, 0)

# Populate the histogram
for line in source_file.readlines():
    for character in line:
        normalized_character = character.lower
        if character in histogram:
            histogram[character] += 1

# Prepare the bar chart
histogram_chart = pygal.Bar()
histogram_chart.title = f'Letter histogram of "{source_file_path}"'
for k, v in histogram.items():
    histogram_chart.add(k, v)

# Write the output
out_file = open(sys.argv[2], 'w') if len(sys.argv) > 2 else sys.stdout
out_file.write(histogram_chart.render(is_unicode=True))
