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
    Source/DetourAlloc.cpp \
    Source/DetourCommon.cpp \
    Source/DetourNavMesh.cpp \
    Source/DetourNavMeshBuilder.cpp \
    Source/DetourNavMeshQuery.cpp \
    Source/DetourNode.cpp

HEADERS += \
    Include/DetourAlloc.h \
    Include/DetourAssert.h \
    Include/DetourCommon.h \
    Include/DetourMath.h \
    Include/DetourNavMesh.h \
    Include/DetourNavMeshBuilder.h \
    Include/DetourNavMeshQuery.h \
    Include/DetourNode.h \
    Include/DetourStatus.h

