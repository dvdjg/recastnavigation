TEMPLATE = app
CONFIG += console
CONFIG -= app_bundle
CONFIG -= qt
CONFIG -= exceptions rtti

DESTDIR=../../bin

CONFIG(debug, debug|release) : TARGET = $$member(TARGET, 0)d

INCLUDEPATH += \
    ../DebugUtils/Include \
    ../DetourCrowd/Include \
    ../DetourTileCache/Include \
    ../Recast/Include \
    ../RecastDemo/Include \
    ../Detour/Include \
    Contrib \
    Contrib/fastlz

SOURCES += \
    Source/ChunkyTriMesh.cpp \
    Source/ConvexVolumeTool.cpp \
    Source/CrowdTool.cpp \
    Source/Filelist.cpp \
    Source/imgui.cpp \
    Source/imguiRenderGL.cpp \
    Source/InputGeom.cpp \
    Source/main.cpp \
    Source/MeshLoaderObj.cpp \
    Source/NavMeshPruneTool.cpp \
    Source/NavMeshTesterTool.cpp \
    Source/OffMeshConnectionTool.cpp \
    Source/PerfTimer.cpp \
    Source/Sample.cpp \
    Source/Sample_Debug.cpp \
    Source/Sample_SoloMesh.cpp \
    Source/Sample_TempObstacles.cpp \
    Source/Sample_TileMesh.cpp \
    Source/SampleInterfaces.cpp \
    Source/SlideShow.cpp \
    Source/TestCase.cpp \
    Source/ValueHistory.cpp \
    Contrib/fastlz/fastlz.c

HEADERS += \
    Include/ChunkyTriMesh.h \
    Include/ConvexVolumeTool.h \
    Include/CrowdTool.h \
    Include/Filelist.h \
    Include/imgui.h \
    Include/imguiRenderGL.h \
    Include/InputGeom.h \
    Include/MeshLoaderObj.h \
    Include/NavmeshPruneTool.h \
    Include/NavMeshTesterTool.h \
    Include/OffMeshConnectionTool.h \
    Include/PerfTimer.h \
    Include/Sample.h \
    Include/Sample_Debug.h \
    Include/Sample_SoloMesh.h \
    Include/Sample_TempObstacles.h \
    Include/Sample_TileMesh.h \
    Include/SampleInterfaces.h \
    Include/SDLMain.h \
    Include/SlideShow.h \
    Include/TestCase.h \
    Include/ValueHistory.h \
    Contrib/stb_image.h \
    Contrib/stb_truetype.h \
    Contrib/fastlz/fastlz.h

LIBS += -lopengl32 -lglu32 -lmingw32 -lsdlmain -lsdl

CONFIG(debug, debug|release) {
    LIBS += -L../../lib -lDetourTileCached -lDebugUtilsd -lDetourCrowdd -lRecastd -lDetourd
#    PRE_TARGETDEPS += ../../lib/libDetourTileCached.a ../../lib/libDebugUtilsd.a ../../lib/libDetourCrowdd.a ../../lib/libRecastd.a ../../lib/libDetourd.a
    DEPENDPATH += ../../lib
} else {
    LIBS += -L../../lib -lDetourTileCache -lDebugUtils -lDetourCrowd -lRecast -lDetour
#    PRE_TARGETDEPS += ../../lib/libDetourTileCache.a ../../lib/libDebugUtils.a ../../lib/libDetourCrowd.a ../../lib/libRecast.a ../../lib/libDetour.a
    DEPENDPATH += ../../lib
}
