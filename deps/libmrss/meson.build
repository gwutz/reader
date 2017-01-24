mrss_sources = [
    'mrss.h',
    'mrss_download.c',
    'mrss_edit.c',
    'mrss_free.c',
    'mrss_generic.c',
    'mrss_internal.h',
    'mrss_options.c',
    'mrss_parser.c',
    'mrss_search.c',
    'mrss_write.c'
]

include = include_directories('../libnxml')

mrss_lib = static_library('mrss', mrss_sources,
    link_with: nxml_lib,
    include_directories: include,
    pic: true)
