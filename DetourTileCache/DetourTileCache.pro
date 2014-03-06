TEMPLATE = lib
CONFIG += staticlib
CONFIG -= app_bundle
CONFIG -= qt
CONFIG -= exceptions rtti

DESTDIR=../../lib

CONFIG(debug, debug|release) : TARGET = $$member(TARGET, 0)d

INCLUDEPATH += \
    ../DebugUtils/Include \
    ../DetourCrowd/Include \
    ../DetourTileCache/Include \
    ../Recast/Include \
    ../RecastDemo/Include \
    ../Detour/Include

SOURCES += \
    Source/DetourTileCache.cpp \
    Source/DetourTileCacheBuilder.cpp

HEADERS += \
    Include/DetourTileCache.h \
    Include/DetourTileCacheBuilder.h

