subdir('rss-engine')

reader_sources = [
    'Reader.vala',
    'ReaderController.vala',
    'ReaderWindow.vala',
    'ReaderHeaderBar.vala',
    'ReaderContent.vala'
]

reader_deps = [
    glib, gobject, gtk, unity, webkit, gee, reader_engine
]

include = include_directories(meson.source_root() + '/deps/rss-glib/')

executable('reader', reader_sources,
  dependencies: reader_deps,
  install: true,
  link_with: [rss_glib_lib],
  include_directories: include,
  vala_args: ['--pkg=rss-glib-1.0', '--vapidir=' + meson.source_root() + '/vapi/']
)
