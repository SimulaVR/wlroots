#define _POSIX_C_SOURCE 199506L
#include <errno.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include <wlr/util/log.h>

static bool colored = true;
static enum wlr_log_importance log_importance = WLR_ERROR;

static const char *verbosity_colors[] = {
	[WLR_SILENT] = "",
	[WLR_ERROR ] = "\x1B[1;31m",
	[WLR_INFO  ] = "\x1B[1;34m",
	[WLR_DEBUG ] = "\x1B[1;30m",
};

static void log_stderr(enum wlr_log_importance verbosity, const char *fmt,
		va_list args) {
	if (verbosity > log_importance) {
		return;
	}
	// prefix the time to the log message
	struct tm result;
	time_t t = time(NULL);
	struct tm *tm_info = localtime_r(&t, &result);
	char buffer[26];

	// generate time prefix
	strftime(buffer, sizeof(buffer), "%F %T - ", tm_info);
	fprintf(stderr, "%s", buffer);

	unsigned c = (verbosity < WLR_LOG_IMPORTANCE_LAST) ? verbosity : WLR_LOG_IMPORTANCE_LAST - 1;

	if (colored && isatty(STDERR_FILENO)) {
		fprintf(stderr, "%s", verbosity_colors[c]);
	}

	vfprintf(stderr, fmt, args);

	if (colored && isatty(STDERR_FILENO)) {
		fprintf(stderr, "\x1B[0m");
	}
	fprintf(stderr, "\n");
}

static wlr_log_func_t log_callback = log_stderr;

void wlr_log_init(enum wlr_log_importance verbosity, wlr_log_func_t callback) {
	if (verbosity < WLR_LOG_IMPORTANCE_LAST) {
		log_importance = verbosity;
	}
	if (callback) {
		log_callback = callback;
	}
}

void _wlr_vlog(enum wlr_log_importance verbosity, const char *fmt, va_list args) {
	log_callback(verbosity, fmt, args);
}

void _wlr_log(enum wlr_log_importance verbosity, const char *fmt, ...) {
	va_list args;
	va_start(args, fmt);
	log_callback(verbosity, fmt, args);
	va_end(args);
}

// strips the path prefix from filepath
// will try to strip WLR_SRC_DIR as well as a relative src dir
// e.g. '/src/build/wlroots/backend/wayland/backend.c' and
// '../backend/wayland/backend.c' will both be stripped to
// 'backend/wayland/backend.c'
const char *_wlr_strip_path(const char *filepath) {
	static int srclen = sizeof(WLR_SRC_DIR);
	if (strstr(filepath, WLR_SRC_DIR) == filepath) {
		filepath += srclen;
	} else if (*filepath == '.') {
		while (*filepath == '.' || *filepath == '/') {
			++filepath;
		}
	}
	return filepath;
}

enum wlr_log_importance wlr_log_get_verbosity(void) {
	return log_importance;
}

void wlr_log_str(const char *data)
{
    FILE *fp = fopen("./log/log.txt", "ab");
    if (fp != NULL)
		{
			fputs(data, fp);
			fputs("\n", fp);
			fclose(fp);
		}
}
