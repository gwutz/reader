set(READER_SRC
    Reader.vala
    ReaderWindow.vala
    ReaderHeaderBar.vala
    ReaderWelcome.vala
    ReaderContent.vala

    ReaderController.vala
    ReaderDataManager.vala

    workerpool.vala
)

find_package(Vala REQUIRED)
include(ValaVersion)
ensure_vala_version("0.22.1" MINIMUM)
include(ValaPrecompile)

pkg_check_modules(DEPS REQUIRED
    granite
    unity
    gtk+-3.0
    glib-2.0
    gobject-2.0
    libcurl
    webkit2gtk-4.0
)

set(CFLAGS
    ${DEPS_CFLAGS}
)

set(LIB_PATHS ${DEPS_LIBRARY_DIRS})

set(READER_PACKAGES
    glib-2.0 gobject-2.0 granite gtk+-3.0 unity webkit2gtk-4.0
)

vala_precompile(READER_VALA_C ${CMAKE_PROJECT_NAME}
    ${READER_SRC}
PACKAGES
    ${READER_PACKAGES}
OPTIONS
    --target-glib=2.32
    --thread
CUSTOM_VAPIS
    ${CMAKE_SOURCE_DIR}/vapi/rss-glib-1.0.vapi
)

include_directories(${CMAKE_SOURCE_DIR}/deps/rss-glib/)
link_directories(${LIB_PATHS})
add_definitions(${CFLAGS})
add_executable(${CMAKE_PROJECT_NAME} ${READER_VALA_C})
target_link_libraries(${CMAKE_PROJECT_NAME} ${DEPS_LIBRARIES} curl
    rss-glib mrss nxml) 
