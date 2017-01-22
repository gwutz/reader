cmake_minimum_required(VERSION 2.8)
project(reader C)
find_package(PkgConfig)
pkg_check_modules(GTK QUIET gtk+-3.0)
pkg_check_modules(WEBKITGTK QUIET webkit2gtk-4.0)


add_subdirectory(deps)
add_subdirectory(src)
