# GNU Make project makefile autogenerated by Premake
ifndef config
  config=debug
endif

ifndef verbose
  SILENT = @
endif

ifndef CC
  CC = gcc
endif

ifndef CXX
  CXX = g++
endif

ifndef AR
  AR = ar
endif

ifeq ($(config),debug)
  OBJDIR     = obj/Debug/RecastDemo
#  TARGETDIR  = lib/Debug
  TARGETDIR  = ../Bin
  TARGET     = $(TARGETDIR)/RecastDemo.exe
#  TARGET     = $(TARGETDIR)/RecastDemo.a
  DEFINES   += -DDEBUG
  INCLUDES  += -I../RecastDemo/Include -I../RecastDemo/Contrib -I../RecastDemo/Contrib/fastlz -I../DebugUtils/Include -I../Detour/Include -I../DetourCrowd/Include -I../DetourTileCache/Include -I../Recast/Include -I/cygdrive/c/Crossbridge/sdk/usr/include/SDL
  CPPFLAGS  += -MMD -MP $(DEFINES) $(INCLUDES)
  CFLAGS    += $(CPPFLAGS) $(ARCH) -Wall -ffast-math -g
  CXXFLAGS  += $(CFLAGS) -fno-exceptions -fno-rtti
  LDFLAGS   += -Llib/Debug
  LIBS      += -lDebugUtils -lDetour -lDetourCrowd -lDetourTileCache -lRecast -lRecast -lGL -lSDL -lSDLmain -lvgl
  RESFLAGS  += $(DEFINES) $(INCLUDES) 
  LDDEPS    += lib/Debug/libDebugUtils.a lib/Debug/libDetour.a lib/Debug/libDetourCrowd.a lib/Debug/libDetourTileCache.a lib/Debug/libRecast.a
  LINKCMD    = $(CXX) -o $(TARGET) $(OBJECTS) $(LDFLAGS) $(RESOURCES) $(ARCH) $(LIBS) -swf-version=22
  LINKFLS    = $(CXX) -o $(TARGET).swf $(OBJECTS) $(LDFLAGS) $(RESOURCES) $(ARCH) $(LIBS) -emit-swf -swf-version=22
 # LINKCMD    = $(AR) -rcs $(TARGET) $(OBJECTS)
  define PREBUILDCMDS
  endef
  define PRELINKCMDS
  endef
  define POSTBUILDCMDS
  endef
endif

ifeq ($(config),release)
  OBJDIR     = obj/Release/RecastDemo
  TARGETDIR  = ../Bin
#  TARGETDIR  = lib/Release
#  TARGET     = $(TARGETDIR)/RecastDemo.a
  TARGET     = $(TARGETDIR)/RecastDemo.exe
  DEFINES   += -DNDEBUG
  INCLUDES  += -I../RecastDemo/Include -I../RecastDemo/Contrib -I../RecastDemo/Contrib/fastlz -I../DebugUtils/Include -I../Detour/Include -I../DetourCrowd/Include -I../DetourTileCache/Include -I../Recast/Include -I/cygdrive/c/Crossbridge/sdk/usr/include/SDL
  CPPFLAGS  += -MMD -MP $(DEFINES) $(INCLUDES)
  CFLAGS    += $(CPPFLAGS) $(ARCH) -Wall -ffast-math -O4
  CXXFLAGS  += $(CFLAGS) -fno-exceptions -fno-rtti
  LDFLAGS   += -Llib/Release
  LIBS      += -lDebugUtils -lDetour -lDetourCrowd -lDetourTileCache -lRecast -lGL -lSDL -lSDLmain -lvgl
  RESFLAGS  += $(DEFINES) $(INCLUDES) 
  LDDEPS    += lib/Release/libDebugUtils.a lib/Release/libDetour.a lib/Release/libDetourCrowd.a lib/Release/libDetourTileCache.a lib/Release/libRecast.a
  LINKCMD    = $(CXX) -o $(TARGET) $(OBJECTS) $(LDFLAGS) $(RESOURCES) $(ARCH) $(LIBS) -swf-version=22
  LINKFLS    = $(CXX) -o $(TARGET).swf $(OBJECTS) $(LDFLAGS) $(RESOURCES) $(ARCH) $(LIBS) -emit-swf -swf-version=22
#  LINKCMD    = $(AR) -rcs $(TARGET) $(OBJECTS)
  define PREBUILDCMDS
  endef
  define PRELINKCMDS
  endef
  define POSTBUILDCMDS
  endef
endif

ifeq ($(config),debug32)
  OBJDIR     = obj/x32/Debug/RecastDemo
  TARGETDIR  = ../Bin
  TARGET     = $(TARGETDIR)/RecastDemo
  DEFINES   += -DDEBUG
  INCLUDES  += -I../RecastDemo/Include -I../RecastDemo/Contrib -I../RecastDemo/Contrib/fastlz -I../DebugUtils/Include -I../Detour/Include -I../DetourCrowd/Include -I../DetourTileCache/Include -I../Recast/Include
  CPPFLAGS  += -MMD -MP $(DEFINES) $(INCLUDES)
  CFLAGS    += $(CPPFLAGS) $(ARCH) -Wall -ffast-math -g -m32
  CXXFLAGS  += $(CFLAGS) -fno-exceptions -fno-rtti
  LDFLAGS   += -m32 -L/usr/lib32 -Llib/Debug
  LIBS      += -lDebugUtils -lDetour -lDetourCrowd -lDetourTileCache -lRecast -lGL -lSDL -lSDLmain -lvgl
  RESFLAGS  += $(DEFINES) $(INCLUDES) 
  LDDEPS    += lib/Debug/libDebugUtils.a lib/Debug/libDetour.a lib/Debug/libDetourCrowd.a lib/Debug/libDetourTileCache.a lib/Debug/libRecast.a
  LINKCMD    = $(CXX) -o $(TARGET) $(OBJECTS) $(LDFLAGS) $(RESOURCES) $(ARCH) $(LIBS) -swf-version=22
  LINKFLS    = $(CXX) -o $(TARGET).swf $(OBJECTS) $(LDFLAGS) $(RESOURCES) $(ARCH) $(LIBS) -emit-swf  -swf-version=22
  define PREBUILDCMDS
  endef
  define PRELINKCMDS
  endef
  define POSTBUILDCMDS
  endef
endif

ifeq ($(config),release32)
  OBJDIR     = obj/x32/Release/RecastDemo
  TARGETDIR  = ../Bin
  TARGET     = $(TARGETDIR)/RecastDemo
  DEFINES   += -DNDEBUG
  INCLUDES  += -I../RecastDemo/Include -I../RecastDemo/Contrib -I../RecastDemo/Contrib/fastlz -I../DebugUtils/Include -I../Detour/Include -I../DetourCrowd/Include -I../DetourTileCache/Include -I../Recast/Include
  CPPFLAGS  += -MMD -MP $(DEFINES) $(INCLUDES)
  CFLAGS    += $(CPPFLAGS) $(ARCH) -Wall -ffast-math -O4 -m32
  CXXFLAGS  += $(CFLAGS) -fno-exceptions -fno-rtti
  LDFLAGS   += -m32 -L/usr/lib32 -Llib/Release
  LIBS      += -lDebugUtils -lDetour -lDetourCrowd -lDetourTileCache -lRecast -lGL -lSDL -lSDLmain -lvgl
  RESFLAGS  += $(DEFINES) $(INCLUDES) 
  LDDEPS    += lib/Release/libDebugUtils.a lib/Release/libDetour.a lib/Release/libDetourCrowd.a lib/Release/libDetourTileCache.a lib/Release/libRecast.a
  LINKCMD    = $(CXX) -o $(TARGET) $(OBJECTS) $(LDFLAGS) $(RESOURCES) $(ARCH) $(LIBS) -swf-version=22
  LINKFLS    = $(CXX) -o $(TARGET).swf $(OBJECTS) $(LDFLAGS) $(RESOURCES) $(ARCH) $(LIBS) -emit-swf -swf-version=22
  define PREBUILDCMDS
  endef
  define PRELINKCMDS
  endef
  define POSTBUILDCMDS
  endef
endif

OBJECTS := \
	$(OBJDIR)/ChunkyTriMesh.o \
	$(OBJDIR)/Filelist.o \
	$(OBJDIR)/InputGeom.o \
	$(OBJDIR)/MeshLoaderObj.o \
	$(OBJDIR)/PerfTimer.o \
	$(OBJDIR)/Sample.o \
	$(OBJDIR)/Sample_Debug.o \
	$(OBJDIR)/Sample_TempObstacles.o \
	$(OBJDIR)/ValueHistory.o \
	$(OBJDIR)/fastlz.o \
	$(OBJDIR)/main.o \
	$(OBJDIR)/imgui.o \
	$(OBJDIR)/imguiRenderGL.o \
	$(OBJDIR)/ConvexVolumeTool.o \
	$(OBJDIR)/CrowdTool.o \
	$(OBJDIR)/NavMeshPruneTool.o \
	$(OBJDIR)/NavMeshTesterTool.o \
	$(OBJDIR)/OffMeshConnectionTool.o \
	$(OBJDIR)/SampleInterfaces.o \
	$(OBJDIR)/Sample_SoloMesh.o \
	$(OBJDIR)/Sample_TileMesh.o \
	$(OBJDIR)/SlideShow.o \
	$(OBJDIR)/TestCase.o \
	$(OBJDIR)/gluProject.o \

RESOURCES := \

SHELLTYPE := msdos
ifeq (,$(ComSpec)$(COMSPEC))
  SHELLTYPE := posix
endif
ifeq (/bin,$(findstring /bin,$(SHELL)))
  SHELLTYPE := posix
endif

.PHONY: clean prebuild prelink

all: $(TARGETDIR) $(OBJDIR) prebuild prelink $(TARGET)
	@:

$(TARGET): $(GCH) $(OBJECTS) $(LDDEPS) $(RESOURCES)
	@echo Linking RecastDemo
	$(SILENT) $(LINKFLS)
	$(SILENT) $(LINKCMD)
	$(POSTBUILDCMDS)

$(TARGETDIR):
	@echo Creating $(TARGETDIR)
ifeq (posix,$(SHELLTYPE))
	$(SILENT) mkdir -p $(TARGETDIR)
else
	$(SILENT) mkdir $(subst /,\\,$(TARGETDIR))
endif

$(OBJDIR):
	@echo Creating $(OBJDIR)
ifeq (posix,$(SHELLTYPE))
	$(SILENT) mkdir -p $(OBJDIR)
else
	$(SILENT) mkdir $(subst /,\\,$(OBJDIR))
endif

clean:
	@echo Cleaning RecastDemo
ifeq (posix,$(SHELLTYPE))
	$(SILENT) rm -f  $(TARGET)
	$(SILENT) rm -rf $(OBJDIR)
else
	$(SILENT) if exist $(subst /,\\,$(TARGET)) del $(subst /,\\,$(TARGET))
	$(SILENT) if exist $(subst /,\\,$(OBJDIR)) rmdi../q $(subst /,\\,$(OBJDIR))
endif

prebuild:
	$(PREBUILDCMDS)

prelink:
	$(PRELINKCMDS)

ifneq (,$(PCH))
$(GCH): $(PCH)
	@echo $(notdir $<)
	-$(SILENT) cp $< $(OBJDIR)
	$(SILENT) $(CXX) $(CXXFLAGS) -o "$@" -c "$<"
endif

$(OBJDIR)/ChunkyTriMesh.o: ../RecastDemo/Source/ChunkyTriMesh.cpp
	@echo $(notdir $<)
	$(SILENT) $(CXX) $(CXXFLAGS) -o "$@" -c "$<"
$(OBJDIR)/ConvexVolumeTool.o: ../RecastDemo/Source/ConvexVolumeTool.cpp
	@echo $(notdir $<)
	$(SILENT) $(CXX) $(CXXFLAGS) -o "$@" -c "$<"
$(OBJDIR)/CrowdTool.o: ../RecastDemo/Source/CrowdTool.cpp
	@echo $(notdir $<)
	$(SILENT) $(CXX) $(CXXFLAGS) -o "$@" -c "$<"
$(OBJDIR)/Filelist.o: ../RecastDemo/Source/Filelist.cpp
	@echo $(notdir $<)
	$(SILENT) $(CXX) $(CXXFLAGS) -o "$@" -c "$<"
$(OBJDIR)/imgui.o: ../RecastDemo/Source/imgui.cpp
	@echo $(notdir $<)
	$(SILENT) $(CXX) $(CXXFLAGS) -o "$@" -c "$<"
$(OBJDIR)/imguiRenderGL.o: ../RecastDemo/Source/imguiRenderGL.cpp
	@echo $(notdir $<)
	$(SILENT) $(CXX) $(CXXFLAGS) -o "$@" -c "$<"
$(OBJDIR)/InputGeom.o: ../RecastDemo/Source/InputGeom.cpp
	@echo $(notdir $<)
	$(SILENT) $(CXX) $(CXXFLAGS) -o "$@" -c "$<"
$(OBJDIR)/main.o: ../RecastDemo/Source/main.cpp
	@echo $(notdir $<)
	$(SILENT) $(CXX) $(CXXFLAGS) -o "$@" -c "$<"
$(OBJDIR)/MeshLoaderObj.o: ../RecastDemo/Source/MeshLoaderObj.cpp
	@echo $(notdir $<)
	$(SILENT) $(CXX) $(CXXFLAGS) -o "$@" -c "$<"
$(OBJDIR)/NavMeshPruneTool.o: ../RecastDemo/Source/NavMeshPruneTool.cpp
	@echo $(notdir $<)
	$(SILENT) $(CXX) $(CXXFLAGS) -o "$@" -c "$<"
$(OBJDIR)/NavMeshTesterTool.o: ../RecastDemo/Source/NavMeshTesterTool.cpp
	@echo $(notdir $<)
	$(SILENT) $(CXX) $(CXXFLAGS) -o "$@" -c "$<"
$(OBJDIR)/OffMeshConnectionTool.o: ../RecastDemo/Source/OffMeshConnectionTool.cpp
	@echo $(notdir $<)
	$(SILENT) $(CXX) $(CXXFLAGS) -o "$@" -c "$<"
$(OBJDIR)/PerfTimer.o: ../RecastDemo/Source/PerfTimer.cpp
	@echo $(notdir $<)
	$(SILENT) $(CXX) $(CXXFLAGS) -o "$@" -c "$<"
$(OBJDIR)/Sample.o: ../RecastDemo/Source/Sample.cpp
	@echo $(notdir $<)
	$(SILENT) $(CXX) $(CXXFLAGS) -o "$@" -c "$<"
$(OBJDIR)/SampleInterfaces.o: ../RecastDemo/Source/SampleInterfaces.cpp
	@echo $(notdir $<)
	$(SILENT) $(CXX) $(CXXFLAGS) -o "$@" -c "$<"
$(OBJDIR)/Sample_Debug.o: ../RecastDemo/Source/Sample_Debug.cpp
	@echo $(notdir $<)
	$(SILENT) $(CXX) $(CXXFLAGS) -o "$@" -c "$<"
$(OBJDIR)/Sample_SoloMesh.o: ../RecastDemo/Source/Sample_SoloMesh.cpp
	@echo $(notdir $<)
	$(SILENT) $(CXX) $(CXXFLAGS) -o "$@" -c "$<"
$(OBJDIR)/Sample_TempObstacles.o: ../RecastDemo/Source/Sample_TempObstacles.cpp
	@echo $(notdir $<)
	$(SILENT) $(CXX) $(CXXFLAGS) -o "$@" -c "$<"
$(OBJDIR)/Sample_TileMesh.o: ../RecastDemo/Source/Sample_TileMesh.cpp
	@echo $(notdir $<)
	$(SILENT) $(CXX) $(CXXFLAGS) -o "$@" -c "$<"
$(OBJDIR)/SlideShow.o: ../RecastDemo/Source/SlideShow.cpp
	@echo $(notdir $<)
	$(SILENT) $(CXX) $(CXXFLAGS) -o "$@" -c "$<"
$(OBJDIR)/TestCase.o: ../RecastDemo/Source/TestCase.cpp
	@echo $(notdir $<)
	$(SILENT) $(CXX) $(CXXFLAGS) -o "$@" -c "$<"
$(OBJDIR)/ValueHistory.o: ../RecastDemo/Source/ValueHistory.cpp
	@echo $(notdir $<)
	$(SILENT) $(CXX) $(CXXFLAGS) -o "$@" -c "$<"
$(OBJDIR)/fastlz.o: ../RecastDemo/Contrib/fastlz/fastlz.c
	@echo $(notdir $<)
	$(SILENT) $(CC) $(CFLAGS) -o "$@" -c "$<"
$(OBJDIR)/gluProject.o: ./gluProject.c
	@echo $(notdir $<)
	$(SILENT) $(CC) $(CFLAGS) -o "$@" -c "$<"

-include $(OBJECTS:%.o=%.d)