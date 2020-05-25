/*
 * iio_genxml - Part of the Industrial I/O (IIO) utilities
 *
 * Copyright (C) 2014 Analog Devices, Inc.
 * Author: Paul Cercueil <paul.cercueil@analog.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 * */

#include <getopt.h>
#include <iio.h>
#include <stdio.h>
#include <string.h>

#include "iio_common.h"

#define MY_NAME "iio_genxml"

static const struct option options[] = {
	{0, 0, 0, 0},
};

static const char *options_descriptions[] = {
	"\t[-x <xml_file>]\n"
		"\t\t\t\t[-u <uri>]\n"
		"\t\t\t\t[-n <hostname>]",
};

int main(int argc, char **argv)
{
	char **argw;
	char *xml;
	const char *tmp;
	struct iio_context *ctx;
	int c, option_index = 0;
	size_t xml_len;

	argw = dup_argv(MY_NAME, argc, argv);
	ctx = handle_common_opts(MY_NAME, argc, argw, options, options_descriptions);

	while ((c = getopt_long(argc, argv, "+" COMMON_OPTIONS,  /* Flawfinder: ignore */
					options, &option_index)) != -1) {
		switch (c) {
		/* All these are handled in the common */
		case 'h':
		case 'n':
		case 'x':
		case 'S':
		case 'u':
		case 'a':
			break;
		case '?':
			printf("Unknown argument '%c'\n", c);
			return EXIT_FAILURE;
		}
	}

	if (optind != argc) {
		fprintf(stderr, "Incorrect number of arguments.\n\n");
		usage(MY_NAME, options, options_descriptions);
		return EXIT_FAILURE;
	}

	if (!ctx)
		return EXIT_FAILURE;

	tmp = iio_context_get_xml(ctx);
	if (!tmp) {
		iio_context_destroy(ctx);
		return EXIT_FAILURE;
	}
	xml_len = strnlen(tmp, (size_t)-1);
	xml = cmn_strndup(tmp, xml_len);
	if (!xml) {
		iio_context_destroy(ctx);
		return EXIT_FAILURE;
	}

	printf("XML generated:\n\n%s\n\n", xml);

	iio_context_destroy(ctx);

	ctx = iio_create_xml_context_mem(xml, xml_len);
	if (!ctx) {
		fprintf(stderr, "Unable to re-generate context\n");
	} else {
		printf("Context re-creation from generated XML succeeded!\n");
		iio_context_destroy(ctx);
	}
	free_argw(argc, argw);
	free(xml);
	return EXIT_SUCCESS;
}
