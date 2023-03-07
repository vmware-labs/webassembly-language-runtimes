#include <stdio.h>
#include <string.h>

#include <uuid/uuid.h>
#include <zlib.h>

static char *USAGE_FMT =
    "Usage: %s [compress|decompress] INPUT_FILE OUTPUT_FILE\n"
    "   OUTPUT_FILE always gets overwritten.\n"
    "\n"
    "\n"
    "Usage: %s [genuuid]\n"
    "   Generates UUID and prints it to STDOUT\n"
    "\n"
    "\n"
    "Program exits on any system error!\n"
    "\n";

static char BUF[1024];

int decompress_impl(char *input_file, char *ouput_file)
{
    gzFile in = gzopen(input_file, "rb");
    FILE *out = fopen(ouput_file, "wb");
    if (!in || !out)
        return -1;

    int num_read = 0;
    while ((num_read = gzread(in, BUF, sizeof(BUF))) > 0)
        fwrite(BUF, 1, num_read, out);

    gzclose(in);
    fclose(out);

    return 0;
}

int compress_impl(char *input_file, char *ouput_file)
{
    FILE *in = fopen(input_file, "rb");
    gzFile out = gzopen(ouput_file, "wb");
    if (!in || !out)
        return -1;

    int num_read = 0;
    while ((num_read = fread(BUF, 1, sizeof(BUF), in)) > 0)
        gzwrite(out, BUF, num_read);

    fclose(in);
    gzclose(out);

    return 0;
}

int genuuid_impl()
{
    uuid_t generated;
    uuid_generate(generated);

    char buffer[64];
    uuid_unparse_lower(generated, buffer);

    fprintf(stdout, "%s\n", buffer);

    return 0;
}

int main(int argc, char **argv)
{
    if (0 == strcmp(argv[1], "genuuid") && argc == 2)
        return genuuid_impl();

    if (argc != 4)
    {
        fprintf(stderr, USAGE_FMT, argv[0], argv[0]);
        return -1;
    }

    if (0 == strcmp(argv[1], "compress"))
        return compress_impl(argv[2], argv[3]);

    if (0 == strcmp(argv[1], "decompress"))
        return decompress_impl(argv[2], argv[3]);

    fprintf(stderr, USAGE_FMT, argv[0], argv[0]);
    return -1;
}
