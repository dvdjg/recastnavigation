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
    Source/DetourCrowd.cpp \
    Source/DetourLocalBoundary.cpp \
    Source/DetourObstacleAvoidance.cpp \
    Source/DetourPathCorridor.cpp \
    Source/DetourPathQueue.cpp \
    Source/DetourProximityGrid.cpp

HEADERS += \
    Include/DetourCrowd.h \
    Include/DetourLocalBoundary.h \
    Include/DetourObstacleAvoidance.h \
    Include/DetourPathCorridor.h \
    Include/DetourPathQueue.h \
    Include/DetourProximityGrid.h

