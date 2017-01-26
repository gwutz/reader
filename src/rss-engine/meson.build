reader_engine_sources = [
    'BackgroundJob.vala',
    'Fetcher.vala',
    'FetchRssJob.vala',
    'Workerpool.vala',
    'DataBase.vala',
    'model/Subscription.vala',
    'model/Item.vala'
]

reader_engine_deps = [
    glib, gobject, soup, sqlite
]

include = include_directories(meson.source_root() + '/deps/rss-glib/')

reader_engine_lib = static_library('reader-engine',
        reader_engine_sources,
        dependencies: reader_engine_deps,
        link_with: rss_glib_lib,
        include_directories: include,
        vala_args: ['--pkg=rss-glib-1.0', '--vapidir=' + meson.source_root() + '/vapi/']
    )

reader_engine = declare_dependency(link_with: reader_engine_lib,
                                   include_directories: include_directories('.')
                )
