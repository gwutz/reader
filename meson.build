project('reader', ['vala', 'c'],
  version: '0.1.0',
  meson_version: '>= 0.36.0',
)

glib = dependency('glib-2.0')
gobject = dependency('gobject-2.0')
gtk = dependency('gtk+-3.0')
gee = dependency('gee-0.8')
unity = dependency('unity')
webkit = dependency('webkit2gtk-4.0')
curl = dependency('libcurl')
sqlite = dependency('sqlite3')
soup = dependency('libsoup-2.4')

subdir('deps')
subdir('src')
