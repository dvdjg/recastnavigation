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
    Source/DebugDraw.cpp \
    Source/DetourDebugDraw.cpp \
    Source/RecastDebugDraw.cpp \
    Source/RecastDump.cpp

HEADERS += \
    Include/DebugDraw.h \
    Include/DetourDebugDraw.h \
    Include/RecastDebugDraw.h \
    Include/RecastDump.h

