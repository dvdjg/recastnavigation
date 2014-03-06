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
    Source/Recast.cpp \
    Source/RecastAlloc.cpp \
    Source/RecastArea.cpp \
    Source/RecastContour.cpp \
    Source/RecastFilter.cpp \
    Source/RecastLayers.cpp \
    Source/RecastMesh.cpp \
    Source/RecastMeshDetail.cpp \
    Source/RecastRasterization.cpp \
    Source/RecastRegion.cpp

HEADERS += \
    Include/Recast.h \
    Include/RecastAlloc.h \
    Include/RecastAssert.h

