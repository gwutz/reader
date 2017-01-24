rss_glib_sources = [
    'rss-document.c',
    'rss-document.h',
    'rss-document-private.h',
    'rss-marshal.c',
    'rss-marshal.h',
    'rss-glib.h',
    'rss-item.c',
    'rss-item.h',
    'rss-item-private.h',
    'rss-parser.c',
    'rss-parser.h',
    'rss-parser-private.h',
    'rss-version.h'
]

include = include_directories('../libmrss')

rss_glib_lib = static_library('rss-glib', rss_glib_sources,
    link_with: mrss_lib,
    include_directories: include,
    dependencies: [glib, gobject],
    pic: true
)
