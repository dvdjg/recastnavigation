# Makefile to compile the Recast And Detour library to swc for use it with AS3.
# David Jurado González, 2014

ifndef config
  config=release
endif
export config

ifeq ($(config),debug)
  OBJDIR     = obj/Debug/RecastDemo
  TARGETDIR  = ../RecastDemo/Bin
  TARGET     = $(TARGETDIR)/Recastd.swc
  CPPFLAGS  += -MMD -MP $(DEFINES) $(INCLUDES)
  CFLAGS    += $(CPPFLAGS) $(ARCH) -Wall -ffast-math -g -O4
  CXXFLAGS  += $(CFLAGS) 
  ALL_ARCHIVES = -Llib/Debug -lRecastDemoLite -lDebugUtils -lDetourCrowd -lDetourTileCache -lDetour -lRecast
endif

ifeq ($(config),release)
  OBJDIR     = obj/Release/RecastDemo
  TARGETDIR  = ../RecastDemo/Bin
  TARGET     = $(TARGETDIR)/Recast.swc
  CPPFLAGS  += -MMD -MP $(DEFINES) $(INCLUDES)
  CFLAGS    += $(CPPFLAGS) $(ARCH) -Wall -ffast-math -O4
  CXXFLAGS  += $(CFLAGS) -fno-exceptions -fno-rtti
  ALL_ARCHIVES = -Llib/Release -lRecastDemoLite -lDebugUtils -lDetourCrowd -lDetourTileCache -lDetour -lRecast
endif
  
RECAST_INC=-I../Recast/Include
DETOUR_INC=-I../Detour/Include -I../DetourCrowd/Include -I../DetourTileCache/Include
DEBUG_INC=-I../DebugUtils/Include
DEMO_INC=-I../RecastDemo/Include -I../RecastDemo/Contrib/fastlz
DEMOLITE_INC=-Idemo ${DEMO_INC}

ALL_INCS=${RECAST_INC} ${DETOUR_INC} ${DEBUG_INC} ${DEMOLITE_INC}

PROJECTS := DebugUtils Detour DetourCrowd DetourTileCache Recast RecastDemoLite

.PHONY: all clean help 

all: $(TARGET)

# From all headers
# Changed: ^(struct\s+((dt|rc)\w+)\s*\{)
# To: \1\n\t/// Helper copy operator\n\tvoid copyFrom\(const \2& source\) { *this = source; }\n

build/Recast_wrap.o: recast.i $(PROJECTS) Makefile
	
	# swig from recast.i file
	# Generate the SWIG wrappers
	mkdir -p build
	swig -as3 -package org.recastnavigation -c++ $(ALL_INCS) -module Recast recast.i 2>&1 | tee build/swig.log
	
	# Use the ObjectPool
	sed -r 's@(import flash.utils.ByteArray;)@\1\nimport org.dave.objects.ObjectPool;\n\n@g' Recast.as > RecastTmp.as
	sed -r 's@var ([^_]\w+):?\w* = new (\w+)\(\)@var \1:\2 = ObjectPool.getInstance(\2).getNew()@g' RecastTmp.as > Recast.as
	
	# Avoid the use of pointers when AS3 objects can be used
	sed -rn '1h;1!H;$${;g;s@\):int /\*\*< \{(\w+)\} \*/( +\{)[^\}]*return ([^\n]+)@\): \1\2\n\t\tvar _retPtr_:int = \3\n\t\tif(!_retPtr_)\n\t\t\treturn null;\n\t\tvar _ret_:\1 = ObjectPool.getInstance(\1).getNew();\n\t\t_ret_.swigCPtr = _retPtr_;\n\t\treturn _ret_;@g;p;}' Recast.as > RecastTmp.as
	sed -r 's@([(,]) ?(\w+):int /\*\*< \{(\w+)\} \*/(.+)@\1\2Ref:\3\4\n\t\tvar \2:int = \2Ref ? \2Ref.swigCPtr : 0;@g' RecastTmp.as > Recast.as
	sed -r 's@([(,]) ?(\w+):int /\*\*< \{(\w+)\} \*/(.+)@\1\2Ref:\3\4\n\t\tvar \2:int = \2Ref ? \2Ref.swigCPtr : 0;@g' Recast.as > RecastTmp.as
	sed -r 's@([(,]) ?(\w+):int /\*\*< \{(\w+)\} \*/(.+)@\1\2Ref:\3\4\n\t\tvar \2:int = \2Ref ? \2Ref.swigCPtr : 0;@g' RecastTmp.as > Recast.as
	
	# Use get and set functions
	sed -r 's@^(\s*public\s+function\s+get)([A-Z]\w*\s*\(\s*\)\s*:\s*)@\1 \l\2@g' Recast.as > RecastTmp.as
	sed -r 's@^(\s*public\s+function\s+set)([A-Z]\w*\s*\([^),]+\)\s*:\s*void)@\1 \l\2@g' RecastTmp.as > Recast.as
	
	mv Recast_wrap.cxx build
	mv Recast.as build
	rm RecastTmp.as
	
	# Compile the SWIG AS3 wrapper
	java -jar "C:\Crossbridge\sdk\usr\lib\asc2.jar" -import "C:\Crossbridge\sdk\usr\lib\builtin.abc" -import "C:\Crossbridge\sdk\usr\lib\playerglobal.abc" build/Recast.as
	
	# Compile the ObjectPool helper class
	java -jar "C:\Crossbridge\sdk\usr\lib\asc2.jar" -import "C:\Crossbridge\sdk\usr\lib\builtin.abc" -import "C:\Crossbridge\sdk\usr\lib\playerglobal.abc" ObjectPool.as
	mv ObjectPool.abc build
	
	# Compile the SWIG C++ wrappers
	g++ $(BASE_CFLAGS) $(CXXFLAGS) $(ALL_INCS) build/Recast_wrap.cxx -c 2>&1 | tee build/swig_wrapper.log
	mv Recast_wrap.o build
	
Recast_wrapper.txt: build/Recast_wrap.o fixed_exports.txt Makefile
	cp fixed_exports.txt Recast_wrapper.txt
	@echo "-------- Symbols extraction --------"
	# "$(FLASCC)/usr/bin/g++" $(BASE_CFLAGS) $(OPT_CFLAGS) -I$(LIBDIR) -c Recast_wrapper.cpp
	# cat stdc++_wrapper.txt c_wrapper.txt >> Recast_wrapper.txt
	
	nm build/Recast_wrap.o | grep " T " | cut -d\  -f3 - | sed 's/__/_/' | sort -u >> Recast_wrapper.txt
	
$(TARGET): build/Recast_wrap.o $(PROJECTS) Recast_wrapper.txt Makefile

	# Link the final library
	g++ -jvmopt=-Xmx1G $(BASE_CFLAGS) $(ALL_INCS) swigmain.cpp ./build/Recast.abc ./build/ObjectPool.abc \
	./build/Recast_wrap.o \
	-Wl,--start-group -flto-api=Recast_wrapper.txt \
	-Wl,--end-group \
	-emit-swc=org.recastnavigation $(CFLAGS) $(EXTRA_OPTS) $(ALL_ARCHIVES) -swf-version=22 -o $(TARGET) 2>&1 | tee build/swc.log
	#-fllvm-llc-opt=-ascopt=-optimize -fllvm-llc-opt=-ascopt=-removedeadcode  \  -lGL
	#-emit-swc=org.recastnavigation $(CFLAGS) -flto-api=build/exports.txt $(EXTRA_OPTS) -o build/Recast.swc &> build/swc.log #with -flto option
	#-fllvm-llc-opt=-ascopt=-load-config+=airmobile-config.xml \
	cp $(TARGET) build
	
DebugUtils: 
	@echo "==== Building DebugUtils ($(config)) ===="
	@${MAKE} --no-print-directory -C . -f DebugUtils.make

Detour: 
	@echo "==== Building Detour ($(config)) ===="
	@${MAKE} --no-print-directory -C . -f Detour.make

DetourCrowd: 
	@echo "==== Building DetourCrowd ($(config)) ===="
	@${MAKE} --no-print-directory -C . -f DetourCrowd.make

DetourTileCache: 
	@echo "==== Building DetourTileCache ($(config)) ===="
	@${MAKE} --no-print-directory -C . -f DetourTileCache.make

Recast: 
	@echo "==== Building Recast ($(config)) ===="
	@${MAKE} --no-print-directory -C . -f Recast.make

RecastDemo: DebugUtils Detour DetourCrowd DetourTileCache Recast
	@echo "==== Building RecastDemo ($(config)) ===="
	@${MAKE} --no-print-directory -C . -f RecastDemo.make

RecastDemoLite: DebugUtils Detour DetourCrowd DetourTileCache Recast
	@echo "==== Building RecastDemoLite ($(config)) ===="
	@${MAKE} --no-print-directory -C . -f RecastDemoLite.make
	
clean:
	@${MAKE} --no-print-directory -C . -f DebugUtils.make clean
	@${MAKE} --no-print-directory -C . -f Detour.make clean
	@${MAKE} --no-print-directory -C . -f DetourCrowd.make clean
	@${MAKE} --no-print-directory -C . -f DetourTileCache.make clean
	@${MAKE} --no-print-directory -C . -f Recast.make clean
	@${MAKE} --no-print-directory -C . -f RecastDemo.make clean
	@${MAKE} --no-print-directory -C . -f RecastDemoLite.make clean

help:
	@echo "Usage: make [config=name] [target]"
	@echo ""
	@echo "CONFIGURATIONS:"
	@echo "   debug"
	@echo "   release"
	@echo "   debug32"
	@echo "   release32"
	@echo ""
	@echo "TARGETS:"
	@echo "   all (default)"
	@echo "   clean"
	@echo "   DebugUtils"
	@echo "   Detour"
	@echo "   DetourCrowd"
	@echo "   DetourTileCache"
	@echo "   Recast"
	@echo "   RecastDemo"
	@echo "   RecastDemoLite"
	@echo ""
	@echo "For more information, see http://industriousone.com/premake/quick-start"
