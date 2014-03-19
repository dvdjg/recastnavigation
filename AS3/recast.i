//these are the include files that will be inserted in the auto-generated wrapper class
%{
#include "AS3/AS3.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

//DebugUtils
#include "DebugDraw.h"
#include "DetourDebugDraw.h"
#include "RecastDebugDraw.h"
#include "RecastDump.h"

//Detour
#include "DetourAlloc.h"
#include "DetourAssert.h"
#include "DetourCommon.h"
#include "DetourNavMesh.h"
#include "DetourNavMeshBuilder.h"
#include "DetourNavMeshQuery.h"
#include "DetourNode.h"
#include "DetourStatus.h"

//Detour Crowd
#include "DetourCrowd.h"
#include "DetourLocalBoundary.h"
#include "DetourObstacleAvoidance.h"
#include "DetourPathCorridor.h"
#include "DetourPathQueue.h"
#include "DetourProximityGrid.h"

//DetourTileCache
#include "DetourTileCache.h"
#include "DetourTileCacheBuilder.h"
//Recast
#include "Recast.h"
#include "RecastAlloc.h"
#include "RecastAssert.h"

//demo
#include "AS3_rcContext.h"
#include "ChunkyTriMesh.h"
#include "MeshLoaderObj.h"
#include "InputGeom.h"
//#include "Filelist.h"
#include "Sample.h"
#include "Sample_TempObstacles.h"
//#include "Sample_TileMesh.h"
//#include "SampleInterfaces.h"
#include "fastlz.h"

//inline_as3("import flash.utils.ByteArray;\n");

//utility method for getting the navigation mesh triangles for debug rendering
void getTiles() __attribute__((used,
  annotate("as3sig:public function getTiles(samplePtr):Array"),
  annotate("as3package:org.recastnavigation.util")));

void getTiles() {

  Sample_TempObstacles* sample = ( Sample_TempObstacles* ) 0;
  AS3_GetScalarFromVar(sample, samplePtr);
  
  //AS3_Val result = AS3_Array("");
  inline_as3(
      "var result:Array = [];\n"
      : : 
  );

  const dtNavMesh* mesh = sample->getNavMesh();
  if( !mesh )
    AS3_Trace("nav mesh not defined");

  for (int i = 0; i < mesh->getMaxTiles(); ++i)
  {
    const dtMeshTile* tile = mesh->getTile(i);
    if (!tile->header) continue;
    dtPolyRef base = mesh->getPolyRefBase(tile);


    AS3_DeclareVar(vertCount, int);
    AS3_CopyScalarToVar(vertCount, tile->header->vertCount);

    inline_as3(
        "var as3polys:Array = [];\n"
        "var as3tileverts:Array = [];"
        "var as3Tile:Object = {polys: as3polys, vertCount: vertCount};\n"
        : : 
    );
    for( int l=0; l < tile->header->vertCount*3; l+=3)
    {
      AS3_DeclareVar(x, Number);
      AS3_CopyScalarToVar(x, tile->verts[l]);

      AS3_DeclareVar(y, Number);
      AS3_CopyScalarToVar(y, tile->verts[l+1]);

      AS3_DeclareVar(z, Number);
      AS3_CopyScalarToVar(z, tile->verts[l+2]);

      inline_as3(
          "var pos:Object = {x: x, y: y, z: z};\n"
          "as3tileverts.push(pos);\n"
          : : 
      );

    }

    inline_as3(
          "as3Tile.verts = as3tileverts;\n"
          "result.push(as3Tile);\n"
          : : 
      );

    for (int j = 0; j < tile->header->polyCount; ++j)
    {
      
      const dtPoly* poly = &tile->polys[j];
      inline_as3(
          "var as3verts:Array = [];\n"
          : : 
      );
      
      const unsigned int ip = (unsigned int)(poly - tile->polys);
      const dtPolyDetail* pd = &tile->detailMeshes[ip];
     
      for (int i = 0; i < pd->triCount; ++i)
      {
        const unsigned char* t = &tile->detailTris[(pd->triBase+i)*4];
        for (int j = 0; j < 3; ++j)
        {
          double* v;
          if (t[j] < poly->vertCount)
            v = &tile->verts[poly->verts[t[j]]*3];//dd->vertex(&tile->verts[poly->verts[t[j]]*3], c);
          else
            v = &tile->detailVerts[(pd->vertBase+t[j]-poly->vertCount)*3]; //dd->vertex(&tile->detailVerts[(pd->vertBase+t[j]-poly->vertCount)*3], c);
            
          
          AS3_DeclareVar(v0, Number);
          AS3_CopyScalarToVar(v0, v[0]);

          AS3_DeclareVar(v1, Number);
          AS3_CopyScalarToVar(v1, v[1]);

          AS3_DeclareVar(v2, Number);
          AS3_CopyScalarToVar(v2, v[2]);
          //TODO - this should get the index of the value in tile->verts, rather than creating duplicate verts.
          inline_as3(
              "as3verts.push(v0);\n"
              "as3verts.push(v1);\n"
              "as3verts.push(v2);\n"
              : : 
          );

        }
      }

     // AS3_Val as3poly = AS3_Object("triCount: IntType, verts: AS3ValType", pd->triCount, as3verts);
     // AS3_Set(as3polys, AS3_Int(j), as3poly);

      AS3_DeclareVar(triCount, int);
      AS3_CopyScalarToVar(triCount, pd->triCount);
      inline_as3(
          "var as3poly:Object = {triCount: triCount, verts: as3verts};\n"
          "as3polys.push(as3poly);\n"
          : : 
      );
    }
  }


 // return result;
  AS3_ReturnAS3Var(result);
}

%}

// djg
%as3import("flash.utils.ByteArray,org.dave.objects.ObjectPool");

%apply unsigned int{unsigned char};
%apply unsigned int{unsigned short};
%apply unsigned int{size_t};
//%apply unsigned int{dtPolyRef, dtTileRef, dtPathQueueRef, dtObstacleRef, dtCompressedTileRef};

%typemap(astype) void * "int /**< $1_ltype */";
// , dtPolyRef *, dtTileRef *, dtPathQueueRef *, dtObstacleRef *, dtCompressedTileRef *
//%typemap(astype) dtPolyRef, dtTileRef, dtPathQueueRef, dtObstacleRef, dtCompressedTileRef "uint /**< $1_ltype */";
//%typemap(astype) SWIGTYPE *             "int /**< {$*1_ltype} */";
// sed -rn 's@^\s*(struct|class)\s+(\w+).*@\2 \*,@p' ../*/Include/*.h | sort -u > recastStructs.i
%typemap(astype) BuildContext *,
ConvexVolume *,
ConvexVolumeTool *,
CrowdTool *,
CrowdToolParams *,
CrowdToolState *,
DebugDrawGL *,
dtBVNode *,
dtCompressedTile *,
dtCrowd *,
dtCrowdAgent *,
dtCrowdAgentAnimation *,
dtCrowdAgentDebugInfo *,
dtCrowdAgentParams *,
dtCrowdNeighbour *,
dtLink *,
dtLocalBoundary *,
dtMeshHeader *,
dtMeshTile *,
dtNavMesh *,
dtNavMeshCreateParams *,
dtNavMeshParams *,
dtNavMeshQuery *,
dtNode *,
dtNodePool *,
dtNodeQueue *,
dtObstacleAvoidanceDebugData *,
dtObstacleAvoidanceParams *,
dtObstacleAvoidanceQuery *,
dtObstacleCircle *,
dtObstacleSegment *,
dtOffMeshConnection *,
dtPathCorridor *,
dtPathQueue *,
dtPoly *,
dtPolyDetail *,
dtProximityGrid *,
dtQueryFilter *,
dtTileCache *,
dtTileCacheAlloc *,
dtTileCacheCompressor *,
dtTileCacheContour *,
dtTileCacheContourSet *,
dtTileCacheLayer *,
dtTileCacheLayerHeader *,
dtTileCacheMeshProcess *,
dtTileCacheObstacle *,
dtTileCacheParams *,
dtTileCachePolyMesh *,
duDebugDraw *,
duDisplayList *,
duFileIO *,
FileIO *,
FileList *,
GraphParams *,
imguiGfxCmd *,
imguiGfxLine *,
imguiGfxRect *,
imguiGfxText *,
InputGeom *,
NavMeshPruneTool *,
NavMeshTesterTool *,
OffMeshConnectionTool *,
rcChunkyTriMesh *,
rcChunkyTriMeshNode *,
rcCompactCell *,
rcCompactHeightfield *,
rcCompactSpan *,
rcConfig *,
rcContext *,
rcContour *,
rcContourSet *,
rcHeightfield *,
rcHeightfieldLayer *,
rcHeightfieldLayerSet *,
rcIntArray *,
rcMeshLoaderObj *,
rcPolyMesh *,
rcPolyMeshDetail *,
rcSpan *,
rcSpanPool *,
Sample *,
Sample_Debug *,
Sample_SoloMesh *,
Sample_TempObstacles *,
Sample_TileMesh *,
SampleTool *,
SampleToolState *,
SlideShow *,
TestCase *,
ValueHistory *
 "int /**< {$*1_ltype} */";

//%typemap(astype) dtCrowdAgentParams*, dtCrowdAgentParams& "Object /**< dtCrowdAgentParams */";
//%typemap(astype) dtCrowdAgent*, dtCrowdAgent& "Object /**< dtCrowdAgent */";
//%typemap(astype) dtTileCacheContourSet*, dtTileCacheContourSet& "Object /**< dtTileCacheContourSet */";
//%typemap(astype) dtTileCachePolyMesh*, dtTileCachePolyMesh& "Object /**< dtTileCachePolyMesh */";
//%typemap(astype) dtCrowdNeighbour*, dtCrowdNeighbour& "Object /**< dtCrowdNeighbour */";
//%typemap(astype) dtCrowdAgentAnimation*, dtCrowdAgentAnimation& "Object /**< dtCrowdAgentAnimation */";
//%typemap(astype) dtCrowdAgentDebugInfo*, dtCrowdAgentDebugInfo& "Object /**< dtCrowdAgentDebugInfo */";
//%typemap(astype) dtObstacleCircle*, dtObstacleCircle& "Object /**< dtObstacleCircle */";
//%typemap(astype) dtObstacleSegment*, dtObstacleSegment& "Object /**< dtObstacleSegment */";
//%typemap(astype) dtObstacleAvoidanceParams*, dtObstacleAvoidanceParams& "Object /**< dtObstacleAvoidanceParams */";
//
//%typemap(in) dtCrowdAgentParams* {
//	inline_as3("%0 = $input.swigCPtr;\n": "=r"($1));
//};
//
//%apply dtCrowdAgentParams*{
//	dtCrowdAgentParams&,
//	dtCrowdAgent*, dtCrowdAgent&,
//	dtCrowdAgentAnimation*, dtCrowdAgentAnimation&,
//	dtCrowdAgentDebugInfo*, dtCrowdAgentDebugInfo&,
//	dtTileCacheContourSet*, dtTileCacheContourSet&,
//	dtTileCachePolyMesh*, dtTileCachePolyMesh&,
//	dtCrowdNeighbour*, dtCrowdNeighbour&,
//	dtObstacleCircle*, dtObstacleCircle&,
//	dtObstacleSegment*, dtObstacleSegment&,
//	dtObstacleAvoidanceParams*, dtObstacleAvoidanceParams&
//	};

//%typemap(out) const dtCrowdAgentParams* {
//	inline_as3("var $result:dtCrowdAgentParams = new dtCrowdAgentParams;\n");
//    inline_as3("$result.swigCPtr = %0;\n": : "r"(result));
//};
//

// (\bdouble\s*\*\s*\w+\s*,\s*)const +(int +\w+)
%typemap(astype) (const double** ppVerts, int *pVertCount) "Vector.<Number>";

// Inside this typemap block you have a few variables that SWIG supplies:
//
// $1 - the first parameter that the C function is expecting
// $2 - the second parameter that the C function is expecting
//
// $input - the actual input from ActionScript.  It's an ActionScript object
//		    so it's only useful within an inline_as3() block.  This is the object
//   		we need to bring into the C world by populating values for $1 and $2
//
%typemap(in) (const double** ppVerts, int *pVertCount) (double* pVerts, int vertCount) {
	%#ifdef _BUG_$1
	%#undef _BUG_$1
	%#endif 
	%#define _BUG_$1 "$input"
	$1 = ($1_ltype) &pVerts;
	$2 = ($2_ltype) &vertCount;
}

// Bug? $input doesn't work here
%typemap(argout) (const double** ppVerts, int *pVertCount) {
	AS3_DeclareVar(len$1, int);
	AS3_CopyScalarToVar(len$1, *$2);
    AS3_DeclareVar(ptr$1, int);
	AS3_CopyScalarToVar(ptr$1, *$1);
    // Now pull that Vector into flascc memory// Workaround to a SWIG bug: Can't access input.
    inline_as3(_BUG_$1".length = len$1 * 3;\n");
    inline_as3("for (var i:int = 0; i < "_BUG_$1".length; i++){\n");
    inline_as3("	"_BUG_$1"[i] = CModule.readDouble(ptr$1 + 8*i);\n");
    inline_as3("}\n");
}

%typemap(astype) (const int** ppTris, int * pTriCount) "Vector.<int>";

%typemap(in) (const int** ppTris, int * pTriCount) (int* pTris, int triCount){
	%#ifdef _BUG_$1
	%#undef _BUG_$1
	%#endif 
	%#define _BUG_$1 "$input"
	$1 = ($1_ltype) &pTris;
	$2 = ($2_ltype) &triCount;
}

// Bug? $input doesn't work here
%typemap(argout) (const int** ppTris, int * pTriCount) {
	AS3_DeclareVar(len$1, int);
	AS3_CopyScalarToVar(len$1, *$2);
    AS3_DeclareVar(ptr$1, int);
	AS3_CopyScalarToVar(ptr$1, *$1);
    // Now pull that Vector into flascc memory// Workaround to a SWIG bug: Can't access input.
    inline_as3(_BUG_$1".length = len$1 * 3;\n");
    inline_as3("for (var i:int = 0; i < "_BUG_$1".length; i++){\n");
    inline_as3("	"_BUG_$1"[i] = CModule.read32(ptr$1 + 4*i);\n");
    inline_as3("}\n");
}

// Bug? $input doesn't work here
%typemap(argout) (const int** ppInt, int * pIntCount) {
	AS3_DeclareVar(len$1, int);
	AS3_CopyScalarToVar(len$1, *$2);
    AS3_DeclareVar(ptr$1, int);
	AS3_CopyScalarToVar(ptr$1, *$1);
    // Now pull that Vector into flascc memory// Workaround to a SWIG bug: Can't access input.
    inline_as3(_BUG_$1".length = len$1;\n");
    inline_as3("for (var i:int = 0; i < "_BUG_$1".length; i++){\n");
    inline_as3("	"_BUG_$1"[i] = CModule.read32(ptr$1 + 4*i);\n");
    inline_as3("}\n");
}

%apply (const int** ppTris, int * pTriCount) {
	(const int** ppInt, int * pIntCount)
};

%typemap(astype) (unsigned char** data, int* dataSize) "ByteArray";

%typemap(in) (unsigned char** data, int* dataSize) (unsigned char* p, int c){
	%#ifdef _BUG_$1
	%#undef _BUG_$1
	%#endif 
	%#define _BUG_$1 "$input"
	$1 = ($1_ltype) &p;
	$2 = ($2_ltype) &c;
}

// Bug? $input doesn't work here
%typemap(argout) (unsigned char** data, int* dataSize) {
	AS3_DeclareVar(len$1, int);
	AS3_CopyScalarToVar(len$1, *$2);
    AS3_DeclareVar(ptr$1, int);
	AS3_CopyScalarToVar(ptr$1, *$1);

	// Now pull that Vector into flascc memory// Workaround to a SWIG bug: Can't access input.
    inline_as3("if(ptr$1 && "_BUG_$1" != null) {\n  "
				_BUG_$1".length=len$1;\n  "
				_BUG_$1".position = 0;\n");
	inline_as3("CModule.readBytes(ptr$1, len$1, "_BUG_$1");\n"
				"}\n");
}

%apply (unsigned char** data, int* dataSize) {
	(unsigned char**, int*)
};

%typemap(astype) (const double* p, int n), double[ANY] "Vector.<Number>";

// Inside this typemap block you have a few variables that SWIG supplies:
//
// $1 - the first parameter that the C function is expecting
// $2 - the second parameter that the C function is expecting
//
// $input - the actual input from ActionScript.  It's an ActionScript object
//		    so it's only useful within an inline_as3() block.  This is the object
//   		we need to bring into the C world by populating values for $1 and $2
//
%typemap(in) (const double* p, int n) {
	// Pass the number of triangles to other typemaps
	%#ifdef _TRI_NUMBER_
	%#undef _TRI_NUMBER_
	%#endif 
	%#define _TRI_NUMBER_ $2
	// For 10 vertices, the Vector must have 30 Numbers.
	//  @param[in]		verts		The vertices of the polygon [Form: (x, y, z) * @p nverts]
	//  @param[in]		nverts		The number of vertices in the polygon.
	
    // setup some new C variables that we're going to modify from within our inline ActionScript
    double* newBuffer;
    int newBufferSize = 0;

    inline_as3("var ptr$1:int = ($input == null) ? 0 : CModule.malloc($input.length*8);\n"); // 8 bytes per double
    inline_as3("%0 = ptr$1;\n": "=r"(newBuffer));

    inline_as3("if(ptr$1) {\n");
	inline_as3("%0 = $input.length;\n": "=r"(newBufferSize));

    // Now push that Vector into flascc memory
    inline_as3("for (var i:int = 0; i < $input.length; i++){\n");
    inline_as3("	CModule.writeDouble(ptr$1 + 8*i, $input[i]);\n");
    inline_as3("}\n}\n");

    // Finally assign the parameters that C is expecting to our new values
    $1 = newBuffer;
    $2 = newBufferSize/3;
}

// Free the memory that we CModule.malloc'd in the equivalent typemap(in)
%typemap(freearg) (const double* p, int n) {
	inline_as3("if(%0) CModule.free(%0);\n": : "r"($1));
};

// const double* pts, int npts, double* areas
%typemap(astype) double* areas "Vector.<Number>";

%typemap(in) double* areas {
	%#ifdef _BUG_$1
	%#undef _BUG_$1
	%#endif 
	%#define _BUG_$1 "$input"
    // setup some new C variables that we're going to modify from within our inline ActionScript
    double* newBuffer;

    inline_as3("var triNumber:int = %0;\n": : "r"(_TRI_NUMBER_));
	inline_as3("var ptr$1:int = ($input == null) ? 0 : CModule.malloc(triNumber*8);\n"); // 8 bytes per double
    inline_as3("%0 = ptr$1;\n": "=r"(newBuffer));

    inline_as3("if(ptr$1) {\n");
	inline_as3("$input.length = triNumber;\n}\n");

    // Finally assign the parameters that C is expecting to our new values
    $1 = newBuffer;
}

// Free the memory that we CModule.malloc'd in the equivalent typemap(in)
%typemap(freearg) double* areas {
	inline_as3("if(%0) CModule.free(%0);\n": : "r"($1));
};

%typemap(argout) double* areas {
    // Now pull that Vector into flascc memory// Workaround to a SWIG bug: Can't access input.
    inline_as3("for (var i:int = 0; i < "_BUG_$1".length; i++){\n");
    inline_as3("	"_BUG_$1"[i] = CModule.readDouble(ptr$1 + 8*i);\n");
    inline_as3("}\n");
}

// const int* tris, const double* normals, int ntris
%apply (const double* p, int n) {
	(const double* normals, int ntris),
	(const double* verts, int nverts),
	(const double* verts, int nv),
	(const double* pts, int npts),
	(const double* polya, int npolya),
	(const double* polyb, int npolyb)
};


%typemap(in) double[ANY] (double temp[$1_dim0]) {
    inline_as3("var ptr$1:int = %0;\n": : "r"(temp));
	inline_as3("var size$1:int = %0;\n": : "r"($1_dim0));

    inline_as3("if($input != null) {\n");
	inline_as3("$input.length = size$1;\n");
	
    // Now push that Vector into flascc memory
    inline_as3("for (var i:int = 0; i < size$1 ; i++){\n");
    inline_as3("	CModule.writeDouble(ptr$1 + 8*i, $input[i]);\n");
    inline_as3("}\n}\n");
	$1 = temp;
}

%typemap(out) double[ANY] {
	inline_as3("var $result:Vector.<Number>;\nvar ptrRet:int = %0;\n": : "r"(result));
    inline_as3("var sizeRet:int = %0;\n": : "r"($1_dim0));
	inline_as3("var ret:Vector.<Number> = new Vector.<Number>;\n");
    // Now pull that Vector into flascc memory// Workaround to a SWIG bug: Can't access input.
	inline_as3("for (var i:int = 0; i < sizeRet ; i++)\n");
    inline_as3("  ret[i] = CModule.readDouble(ptrRet + 8*i);\n");
	inline_as3("$result = ret;\n");
}

%typemap(astype) (const int* tris, int nt) "Vector.<int>";

// Inside this typemap block you have a few variables that SWIG supplies:
//
// $1 - the first parameter that the C function is expecting
// $2 - the second parameter that the C function is expecting
//
// $input - the actual input from ActionScript.  It's an ActionScript object
//		    so it's only useful within an inline_as3() block.  This is the object
//   		we need to bring into the C world by populating values for $1 and $2
//
%typemap(in) (const int* tris, int nt) {
    // setup some new C variables that we're going to modify from within our inline ActionScript
    int* newBuffer;
    int newBufferSize = 0;

    // Use the inline_as3() function that is defined in AS3.h to write the ActionScript code
    // that will convert the Vector into something C can use.  Notice that we are using $input
    // inside this inline_as3() call.
    inline_as3("var ptr$1:int = ($input == null) ? 0 : CModule.malloc($input.length*4);\n"); // 4 bytes per int

    // Similarly we'll pass the value of the ptr$1 variable in ActionScript to the C newBuffer variable
    inline_as3("%0 = ptr$1;\n": "=r"(newBuffer));

    inline_as3("if(ptr$1) {\n");
	// This next inline call is a little more complicated.  Here we use the %0 flag to pass
    // the value of the ActionScript $input.length variable to the C variable named newBufferSize.
    inline_as3("%0 = $input.length;\n": "=r"(newBufferSize));

    // Now push that Vector into flascc memory
    inline_as3("CModule.writeIntVector(ptr$1, $input);\n");
    inline_as3("}\n");
	
    // Finally assign the parameters that C is expecting to our new values
    $1 = newBuffer;
    $2 = newBufferSize/3;
}

// Free the memory that we CModule.malloc'd in the equivalent typemap(in)
%typemap(freearg) (const int* tris, int nt) {
    inline_as3("if(%0) CModule.free(%0);\n": : "r"($1));
};

%apply (const int* tris, int nt) {
	(const int* verts, int nverts),
	(const int* tris, int ntris),
	(const int* edges, int nedges)
};


%typemap(astype) (const int* tris) "Vector.<int>";

// Inside this typemap block you have a few variables that SWIG supplies:
//
// $1 - the first parameter that the C function is expecting
// $2 - the second parameter that the C function is expecting
//
// $input - the actual input from ActionScript.  It's an ActionScript object
//		    so it's only useful within an inline_as3() block.  This is the object
//   		we need to bring into the C world by populating values for $1 and $2
//
%typemap(in) (const int* tris) {
    // setup some new C variables that we're going to modify from within our inline ActionScript
    int* newBuffer;
	
    inline_as3("var ptr$1:int = ($input == null) ? 0 : CModule.malloc($input.length*4);\n"); // 4 bytes per int
    inline_as3("%0 = ptr$1;\n": "=r"(newBuffer));

    inline_as3("if(ptr$1) {\n");
	// Now push that Vector into flascc memory
    inline_as3("for (var i:int = 0; i < $input.length; i++){\n");
    inline_as3("	CModule.write32(ptr$1 + 4*i, $input[i]); // Also: writeIntVector\n");
    inline_as3("}\n}\n");

    // Finally assign the parameters that C is expecting to our new values
    $1 = newBuffer;
}

// Free the memory that we CModule.malloc'd in the equivalent typemap(in)
%typemap(freearg) (const int* tris) {
    inline_as3("if(%0) CModule.free(%0);\n": : "r"($1));
};


%typemap(astype) (const unsigned short* idx, int nidx) "Vector.<uint>";

// Inside this typemap block you have a few variables that SWIG supplies:
//
// $1 - the first parameter that the C function is expecting
// $2 - the second parameter that the C function is expecting
//
// $input - the actual input from ActionScript.  It's an ActionScript object
//		    so it's only useful within an inline_as3() block.  This is the object
//   		we need to bring into the C world by populating values for $1 and $2
//
%typemap(in) (const unsigned short* idx, int nidx) {
    // setup some new C variables that we're going to modify from within our inline ActionScript
    unsigned short* newBuffer;
    int newBufferSize = 0;

    // Use the inline_as3() function that is defined in AS3.h to write the ActionScript code
    // that will convert the Vector into something C can use.  Notice that we are using $input
    // inside this inline_as3() call.
    inline_as3("var ptr$1:int = ($input == null) ? 0 : CModule.malloc($input.length*2);\n"); // 2 bytes per unsigned short

    // Similarly we'll pass the value of the ptr$1 variable in ActionScript to the C newBuffer variable
    inline_as3("%0 = ptr$1;\n": "=r"(newBuffer));

    inline_as3("if(ptr$1) {\n");
	// This next inline call is a little more complicated.  Here we use the %0 flag to pass
    // the value of the ActionScript $input.length variable to the C variable named newBufferSize.
    inline_as3("%0 = $input.length;\n": "=r"(newBufferSize));

    // Now push that Vector into flascc memory
    inline_as3("for (var i:int = 0; i < $input.length; i++){\n");
    inline_as3("	CModule.write16(ptr$1 + 2*i, $input[i]);\n");
    inline_as3("}\n}\n");

    // Finally assign the parameters that C is expecting to our new values
    $1 = newBuffer;
    $2 = newBufferSize/3;
}

// Free the memory that we CModule.malloc'd in the equivalent typemap(in)
%typemap(freearg) (const unsigned short* idx, int nidx) {
    inline_as3("if(%0) CModule.free(%0);\n": : "r"($1));
};

%apply (const unsigned short* idx, int nidx) {
	(const unsigned short* p, int nvp)
};

%typemap(astype) (unsigned short* ids, int maxIds) "Vector.<uint>";

// Inside this typemap block you have a few variables that SWIG supplies:
//
// $1 - the first parameter that the C function is expecting
// $2 - the second parameter that the C function is expecting
//
// $input - the actual input from ActionScript.  It's an ActionScript object
//		    so it's only useful within an inline_as3() block.  This is the object
//   		we need to bring into the C world by populating values for $1 and $2
//
%typemap(in) (unsigned short* ids, int maxIds) {
	%#ifdef _BUG_$1
	%#undef _BUG_$1
	%#endif 
	%#define _BUG_$1 "$input"
    // setup some new C variables that we're going to modify from within our inline ActionScript
    unsigned short* newBuffer;
    int newBufferSize = 0;

    // Use the inline_as3() function that is defined in AS3.h to write the ActionScript code
    // that will convert the Vector into something C can use.  Notice that we are using $input
    // inside this inline_as3() call.
    inline_as3("var ptr$1:int = ($input == null) ? 0 : CModule.malloc($input.length*2);\n"); // 2 bytes per unsigned short

    // Similarly we'll pass the value of the ptr$1 variable in ActionScript to the C newBuffer variable
    inline_as3("%0 = ptr$1;\n": "=r"(newBuffer));

    inline_as3("if(ptr$1) {\n");
	// This next inline call is a little more complicated.  Here we use the %0 flag to pass
    // the value of the ActionScript $input.length variable to the C variable named newBufferSize.
    inline_as3("%0 = $input.length;\n": "=r"(newBufferSize));

    // Now push that Vector into flascc memory
    //inline_as3("for (var i:int = 0; i < $input.length; i++){\n");
    //inline_as3("	CModule.write16(ptr$1 + 2*i, $input[i]);\n");
    inline_as3("}\n");

    // Finally assign the parameters that C is expecting to our new values
    $1 = newBuffer;
    $2 = newBufferSize;
}

// Free the memory that we CModule.malloc'd in the equivalent typemap(in)
%typemap(freearg) (unsigned short* ids, int maxIds) {
    inline_as3("if(%0) CModule.free(%0);\n": : "r"($1));
};

// Bug? $input doesn't work here
%typemap(argout) (unsigned short* ids, int maxIds) {
    // Now pull that Vector into flascc memory// Workaround to a SWIG bug: Can't access input.
    inline_as3("if(ptr$1) {\n");
	inline_as3("for (var i:int = 0; i < "_BUG_$1".length; i++){\n");
    inline_as3("	"_BUG_$1"[i] = CModule.read16(ptr$1 + 2*i);\n");
    inline_as3("}\n}\n");
}

//

%typemap(astype) (int* ids, int maxIds) "Vector.<int>";

// Inside this typemap block you have a few variables that SWIG supplies:
//
// $1 - the first parameter that the C function is expecting
// $2 - the second parameter that the C function is expecting
//
// $input - the actual input from ActionScript.  It's an ActionScript object
//		    so it's only useful within an inline_as3() block.  This is the object
//   		we need to bring into the C world by populating values for $1 and $2
//
%typemap(in) (int* ids, int maxIds) {
	%#ifdef _BUG_$1
	%#undef _BUG_$1
	%#endif 
	%#define _BUG_$1 "$input"
    // setup some new C variables that we're going to modify from within our inline ActionScript
    int* newBuffer;
    int newBufferSize = 0;

    // Use the inline_as3() function that is defined in AS3.h to write the ActionScript code
    // that will convert the Vector into something C can use.  Notice that we are using $input
    // inside this inline_as3() call.
    inline_as3("var ptr$1:int = ($input == null) ? 0 : CModule.malloc($input.length*4);\n"); // 4 bytes per int

    // Similarly we'll pass the value of the ptr$1 variable in ActionScript to the C newBuffer variable
    inline_as3("%0 = ptr$1;\n": "=r"(newBuffer));

    inline_as3("if(ptr$1) {\n");
	// This next inline call is a little more complicated.  Here we use the %0 flag to pass
    // the value of the ActionScript $input.length variable to the C variable named newBufferSize.
    inline_as3("%0 = $input.length;\n": "=r"(newBufferSize));

    // Now push that Vector into flascc memory
    //inline_as3("for (var i:int = 0; i < $input.length; i++){\n");
    //inline_as3("	CModule.write32(ptr$1 + 4*i, $input[i]);\n");
    inline_as3("}\n");

    // Finally assign the parameters that C is expecting to our new values
    $1 = newBuffer;
    $2 = newBufferSize;
}

// Free the memory that we CModule.malloc'd in the equivalent typemap(in)
%typemap(freearg) (int* ids, int maxIds) {
    inline_as3("if(%0) CModule.free(%0);\n": : "r"($1));
};

// Bug? $input doesn't work here
%typemap(argout) (int* ids, int maxIds) {
    // Now pull that Vector into flascc memory// Workaround to a SWIG bug: Can't access input.
    inline_as3("for (var i:int = 0; i < "_BUG_$1".length; i++){\n");
    inline_as3("	"_BUG_$1"[i] = CModule.read32(ptr$1 + 4*i);\n");
    inline_as3("}\n");
}

//%apply (unsigned short* idx, int nidx) {
//	(unsigned short* p, int nvp)
//};

%typemap(astype) (const unsigned char* p, int n) "ByteArray";

// Inside this typemap block you have a few variables that SWIG supplies:
//
// $1 - the first parameter that the C function is expecting
// $2 - the second parameter that the C function is expecting
//
// $input - the actual input from ActionScript.  It's an ActionScript object
//		    so it's only useful within an inline_as3() block.  This is the object
//   		we need to bring into the C world by populating values for $1 and $2
//
%typemap(in) (const unsigned char* p, int n) {
    // setup some new C variables that we're going to modify from within our inline ActionScript
    unsigned char* newBuffer;
    int newBufferSize = 0;

    // Use the inline_as3() function that is defined in AS3.h to write the ActionScript code
    // that will convert the Vector into something C can use.  Notice that we are using $input
    // inside this inline_as3() call.
    inline_as3("$input.position=0;\nvar ptr$1:int = ($input == null) ? 0 : CModule.malloc($input.length);\n"); 

    // Similarly we'll pass the value of the ptr$1 variable in ActionScript to the C newBuffer variable
    inline_as3("%0 = ptr$1;\n": "=r"(newBuffer));

    inline_as3("if(ptr$1) {\n");
	// This next inline call is a little more complicated.  Here we use the %0 flag to pass
    // the value of the ActionScript $input.length variable to the C variable named newBufferSize.
    inline_as3("%0 = $input.length;\n": "=r"(newBufferSize));

    // Now push that Vector into flascc memory
    inline_as3("CModule.writeBytes(ptr$1, $input.bytesAvailable, $input);\n");
    inline_as3("}\n");
    
    // Finally assign the parameters that C is expecting to our new values
    $1 = newBuffer;
    $2 = newBufferSize;
}

// Free the memory that we CModule.malloc'd in the equivalent typemap(in)
%typemap(freearg) (const unsigned char* p, int n) {
    inline_as3("if(%0) CModule.free(%0);\n": : "r"($1));
};

%apply (const unsigned char* p, int n) {
	(unsigned char* data, int dataSize),
	(const void* input, int length),
	(const unsigned char* buffer, int bufferSize),
	(const unsigned char* compressed, int compressedSize),
	(const unsigned char* data, int maxDataSize),
	(const unsigned char* buf, int bufSize)
};

%typemap(astype) (unsigned char* surfaces) "ByteArray";

%typemap(in) unsigned char* surfaces {
    // Workaround to a SWIG bug. Pass the AS3 argument name to the %typemap(argout) '$1' $input
	%#ifdef _BUG_$1
	%#undef _BUG_$1
	%#endif 
	%#define _BUG_$1 "$input"
	unsigned char * newBuffer;
	inline_as3("var ptr$1:int = ($input == null) ? 0 : CModule.malloc($input.length);\n"); 
    // Similarly we'll pass the value of the ptr$1 variable in ActionScript to the C newBuffer variable
    inline_as3("%0 = ptr$1;\n": "=r"(newBuffer));
	inline_as3("var ba$1:ByteArray = $input;\n");
	
	// Finally assign the parameters that C is expecting to our new values
    $1 = newBuffer;
} 

// Bug? $input doesn't work here
%typemap(argout) unsigned char* surfaces {
    // Now pull that Vector into flascc memory// Workaround to a SWIG bug: Can't access input.
    inline_as3("if(ptr$1) {\n");
	inline_as3(_BUG_$1".position = 0;\nCModule.readBytes(ptr$1, "_BUG_$1".length,ba$1); // _BUG_$1 is the same object as ba$1\n");
    inline_as3("}\n");
}

%apply (unsigned char* surfaces) {
	(void* output)
};

// Bug? $input doesn't work here
%typemap(argout) void* output {
    AS3_DeclareVar(asres, int); // The final asresult variable is not set at this point
    AS3_CopyScalarToVar(asres, result);
    // Now pull that Vector into flascc memory// Workaround to a SWIG bug: Can't access input.
    inline_as3("if(asres && "_BUG_$1" != null) {\n  "_BUG_$1".length=asres;\n  "_BUG_$1".position = 0;\n");
	inline_as3("CModule.readBytes(ptr$1, asres, ba$1); // _BUG_$1 is the same object as ba$1\n}\n");
}


%typemap(astype) double*, double[3], const int*, int[3], short* tx "Object /**< {x,y,z} */";

%typemap(in) double* out (double dVector[3]) {
    // Workaround to a SWIG bug. Pass the AS3 argument name to the %typemap(argout) '$1' $input
	%#ifdef _BUG_$1
	%#undef _BUG_$1
	%#endif 
	%#define _BUG_$1 "$input"

	inline_as3("var ptr$1:int = %0;\n": : "r"(dVector));
	// Finally assign the parameters that C is expecting to our new values
    $1 = dVector;
} 

// Used for:
//  [in] const double*
//  [in,out] double*
%typemap(in) const double* (double dVectorOut[3]) {
    // Workaround to a SWIG bug. Pass the AS3 argument name to the %typemap(argout) '$1' $input
	%#ifdef _BUG_$1
	%#undef _BUG_$1
	%#endif 
	%#define _BUG_$1 "$input"
	inline_as3("var ptr$1:int = ($input == null) ? 0 : %0;\n": : "r"(dVectorOut));

    inline_as3("if(ptr$1) {\n");
	// Now push that Vector into flascc memory
    inline_as3("CModule.writeDouble(ptr$1 + 8*0, $input.x);\n");
    inline_as3("CModule.writeDouble(ptr$1 + 8*1, $input.y);\n");
    inline_as3("CModule.writeDouble(ptr$1 + 8*2, $input.z);\n");
    // Finally assign the parameters that C is expecting to our new values
    $1 = dVectorOut;
    inline_as3("}\n");
}

// Bug? $input doesn't work here
%typemap(argout) double* out, double[3] {
    // Now pull that Vector into flascc memory// Workaround to a SWIG bug: Can't access input.
    inline_as3("if(ptr$1) {\n");
	inline_as3(_BUG_$1".x = CModule.readDouble(ptr$1 + 8*0); // Return to _BUG_$1, $input, $result, $symname, $0, $1\n");
    inline_as3(_BUG_$1".y = CModule.readDouble(ptr$1 + 8*1);\n");
    inline_as3(_BUG_$1".z = CModule.readDouble(ptr$1 + 8*2);\n");
    inline_as3("}\n");
};

%typemap(in) short* tx (short dVector[3]) {
    // Workaround to a SWIG bug. Pass the AS3 argument name to the %typemap(argout) '$1' $input
	%#ifdef _BUG_$1
	%#undef _BUG_$1
	%#endif 
	%#define _BUG_$1 "$input"

	inline_as3("var ptr$1:int = %0;\n": : "r"(dVector));
	// Finally assign the parameters that C is expecting to our new values
    $1 = dVector;
} 

// Used for:
//  [in] const double*
//  [in,out] double*
%typemap(in) const short* tx (short dVectorOut[3]) {
    // Workaround to a SWIG bug. Pass the AS3 argument name to the %typemap(argout) '$1' $input
	%#ifdef _BUG_$1
	%#undef _BUG_$1
	%#endif 
	%#define _BUG_$1 "$input"
	inline_as3("var ptr$1:int = ($input == null) ? 0 : %0;\n": : "r"(dVectorOut));

    inline_as3("if(ptr$1) {\n");
	// Now push that Vector into flascc memory
    inline_as3("CModule.write16(ptr$1 + 2*0, $input.x);\n");
    inline_as3("CModule.write16(ptr$1 + 2*1, $input.y);\n");
    inline_as3("CModule.write16(ptr$1 + 2*2, $input.z);\n");
    // Finally assign the parameters that C is expecting to our new values
    $1 = dVectorOut;
    inline_as3("}\n");
}

%apply (short* ) {
	(short* )
};

// Bug? $input doesn't work here
%typemap(argout) short* tx, short[3] {
    // Now pull that Vector into flascc memory// Workaround to a SWIG bug: Can't access input.
    inline_as3("if(ptr$1) {\n");
	inline_as3(_BUG_$1".x = CModule.read16(ptr$1 + 2*0);\n");
    inline_as3(_BUG_$1".y = CModule.read16(ptr$1 + 2*1);\n");
    inline_as3(_BUG_$1".z = CModule.read16(ptr$1 + 2*2);\n");
    inline_as3("}\n");
};

%typemap(out) const double*, double[3] {
	inline_as3("var $result:Object;\nvar ptrRet:int = %0;\n": : "r"(result));
    inline_as3("if(ptrRet) {\n");
	inline_as3("var ret:Object = ObjectPool.getInstance(Object).getNew();\n");
    // Now pull that Vector into flascc memory
    inline_as3("ret.x = CModule.readDouble(ptrRet + 8*0);\n");
    inline_as3("ret.y = CModule.readDouble(ptrRet + 8*1);\n");
    inline_as3("ret.z = CModule.readDouble(ptrRet + 8*2);\n");
	inline_as3("$result = ret;\n");
    inline_as3("}\n");
};

%typemap(out) const int*, int[3] {
	inline_as3("var $result:Object;\nvar ptrRet:int = %0;\n": : "r"(result));
	inline_as3("if(ptrRet) {\n");
	inline_as3("var ret:Object = ObjectPool.getInstance(Object).getNew();\n");
    // Now pull that Vector into flascc memory
    inline_as3("ret.x = CModule.read32(ptrRet + 4*0);\n");
    inline_as3("ret.y = CModule.read32(ptrRet + 4*1);\n");
    inline_as3("ret.z = CModule.read32(ptrRet + 4*2);\n");
	inline_as3("$result = ret;\n");
    inline_as3("}\n");
};

%apply (const double*) {
	(double[3])
};

// [out]
%apply (double* out) {
	(double* col),
	(double* res),
	(double* dest),
	(double* center),
	(double* closest),
	(double* startPos),
	(double* endPos),
	(double* nearestPt),
	(double* closest),
	(double* hitPos),
	(double* hitNormal),
	(double* randomPt),
	(double* cornerVerts),
	(double* nvel),
	(double* mn),
	(double* mx),
	(double* tc),
	(double* v)
};

// [in,out]
%apply (double* inout) {
	(double* v),
	(double* mn),
	(double* mx)
};


%typemap(astype) double* proj, double[ANY] "Vector.<Number>";

// Used for:
//  [in] const double*
//  [in,out] double*
%typemap(in) double* proj (double dVectorOut[16]) {
    // Workaround to a SWIG bug. Pass the AS3 argument name to the %typemap(argout) '$1' $input
	%#ifdef _BUG_$1
	%#undef _BUG_$1
	%#endif 
	%#define _BUG_$1 "$input"
	inline_as3("var ptr$1:int = ($input == null) ? 0 : %0;\n": : "r"(dVectorOut));
	inline_as3("if(ptr$1) {\n");
	inline_as3("$input.length = 16;\n");

    // Now push that Vector into flascc memory
	inline_as3("for (var i:int = 0; i < 16; i++){\n");
    inline_as3("	CModule.writeDouble(ptr$1 + 8*i, $input[i]);\n");
    inline_as3("}\n");

    // Finally assign the parameters that C is expecting to our new values
    $1 = dVectorOut;
    inline_as3("} else {\n");
    $1 = 0;
    inline_as3("}\n");
}

// Bug? $input doesn't work here
%typemap(argout) double* proj {
    // Now pull that Vector into flascc memory// Workaround to a SWIG bug: Can't access input.
	inline_as3("if(ptr$1) {\n");
	inline_as3("for (var i:int = 0; i < 16; i++){\n");
    inline_as3("	"_BUG_$1"[i] = CModule.readDouble(ptr$1 + 8*i);\n");
    inline_as3("}\n");	
    inline_as3("}\n");	
};

// [out]
%apply (double* proj) {
	(double* model)
};


%typemap(astype) int* view "Vector.<int>";

// Used for:
//  [in] const int*
//  [in,out] int*
%typemap(in) int* view (int dVectorOut[16]) {
    // Workaround to a SWIG bug. Pass the AS3 argument name to the %typemap(argout) '$1' $input
	%#ifdef _BUG_$1
	%#undef _BUG_$1
	%#endif 
	%#define _BUG_$1 "$input"
	inline_as3("var ptr$1:int = ($input == null) ? 0 : %0;\n": : "r"(dVectorOut));
	inline_as3("if(ptr$1) {\n");
	inline_as3("$input.length = 16;\n");

    // Now push that Vector into flascc memory
	inline_as3("for (var i:int = 0; i < 16; i++){\n");
    inline_as3("	CModule.write32(ptr$1 + 4*i, $input[i]);\n");
    inline_as3("}\n");

    // Finally assign the parameters that C is expecting to our new values
    $1 = dVectorOut;
    inline_as3("} else {\n");
    $1 = 0;
    inline_as3("}\n");
}

// Bug? $input doesn't work here
%typemap(argout) int* view {
    // Now pull that Vector into flascc memory// Workaround to a SWIG bug: Can't access input.
	inline_as3("if(ptr$1) {\n");
	inline_as3("for (var i:int = 0; i < 16; i++){\n");
    inline_as3("	"_BUG_$1"[i] = CModule.read32(ptr$1 + 4*i);\n");
    inline_as3("}\n");	
    inline_as3("}\n");	
};

// [out]
%apply (int* view) {
	(int* vista)
};

%typemap(astype) const unsigned short*, unsigned short [3] "Object /**< short {x,y,z} */";

// Used for:
//  [in] const int*
//  [in,out] int*
%typemap(in) const unsigned short* (unsigned short v[3]) {
    // Workaround to a SWIG bug. Pass the AS3 argument name to the %typemap(argout) '$1' $input
	%#ifdef _BUG_$1
	%#undef _BUG_$1
	%#endif 
	%#define _BUG_$1 "$input"
	inline_as3("var ptr$1:int = ($input == null) ? 0 : %0;\n": : "r"(v));

    inline_as3("if(ptr$1) {\n");
	// Now push that Vector into flascc memory
    inline_as3("CModule.write16(ptr$1 + 2*0, $input.x);\n");
    inline_as3("CModule.write16(ptr$1 + 2*1, $input.y);\n");
    inline_as3("CModule.write16(ptr$1 + 2*2, $input.z);\n");
    // Finally assign the parameters that C is expecting to our new values
    $1 = v;
    inline_as3("}\n");
}

%apply (const unsigned short*) {
	(unsigned short [3])
};
%typemap(astype) int& "Object /**< Reference int {value} */";

%typemap(in) int& (int vector[1]) {
    // Workaround to a SWIG bug. Pass the AS3 argument name to the %typemap(argout) '$1' $input
	%#ifdef _BUG_$1
	%#undef _BUG_$1
	%#endif 
	%#define _BUG_$1 "$input"

	inline_as3("var ptr$1:int = %0;\n": : "r"(vector));
	// Finally assign the parameters that C is expecting to our new values
    $1 = ($1_ltype) vector;
//	inline_as3("var ptr$1:Object = %0; // Alias of the input\n": : "r"($input));
} 


// Bug? $input doesn't work here
%typemap(argout) int& {
    // Now pull that Vector into flascc memory// Workaround to a SWIG bug: Can't access input.
    inline_as3(_BUG_$1"['value'] = CModule.read32(ptr$1);\n");
};

%apply (int&) {
	(dtPolyRef*),
	(dtPathQueueRef*),
	(dtObstacleRef*),
	(dtCompressedTileRef*),
	(int* tx),
	(int* ty)
};

%typemap(astype) double& "Object /**< Reference Number {value} */";

%typemap(in) double& (double vector[1]) {
    // Workaround to a SWIG bug. Pass the AS3 argument name to the %typemap(argout) '$1' $input
	%#ifdef _BUG_$1
	%#undef _BUG_$1
	%#endif 
	%#define _BUG_$1 "$input"

	inline_as3("var ptr$1:int = %0;\n": : "r"(vector));
	// Finally assign the parameters that C is expecting to our new values
    $1 = vector;
} 


// Bug? $input doesn't work here
%typemap(argout) double& {
    // Now pull that Vector into flascc memory// Workaround to a SWIG bug: Can't access input.
    inline_as3(_BUG_$1"['value'] = CModule.readDouble(ptr$1);\n");
};

%rename (vertexXYZ) duDebugDraw::vertex(const double x, const double y, const double z, unsigned int color);
%rename (vertexUV) duDebugDraw::vertex(const double* pos, unsigned int color, const double* uv);
%rename (vertexXYZUV) duDebugDraw::vertex(const double x, const double y, const double z, unsigned int color, const double u, const double v);

//DebugUtils
//ignore overloaded functions
%ignore duDebugDraw::begin(duDebugDrawPrimitives,double);
%ignore duIntToCol(int,double *);
%ignore duDisplayList::begin(duDebugDrawPrimitives,double);
%ignore duDebugDrawRegionConnections(duDebugDraw *,rcContourSet const &,double const);
%ignore duDebugDrawRawContours(duDebugDraw *,rcContourSet const &,double const);
%ignore duDebugDrawContours(duDebugDraw *,rcContourSet const &,double const);

%rename (equals) dtNodePool::operator=; //rename operate= to function equals()

%ignore dtNavMesh::init(unsigned char *,int const,int const);

%include "DebugDraw.h"
%include "DetourDebugDraw.h"

%ignore duDebugDrawRegionConnections(duDebugDraw *,rcContourSet const &);
%ignore duDebugDrawRawContours(duDebugDraw *,rcContourSet const &);
%ignore duDebugDrawContours(duDebugDraw *,rcContourSet const &);
%ignore duDebugDrawLayerContours(duDebugDraw* dd, const struct rcLayerContourSet& lcset);
%ignore duDebugDrawLayerPolyMesh(duDebugDraw* dd, const struct rcLayerPolyMesh& lmesh);
%ignore duDebugDrawHeightfieldLayersRegions(duDebugDraw* dd, const struct rcHeightfieldLayerSet& lset);
%include "RecastDebugDraw.h"

%ignore duLogBuildTimes(rcContext& ctx, const int totalTileUsec);
%include "RecastDump.h"  //commenting out for now. swig doesnt know what to do with duLogBuildTimes, even with it ignored


//Detour
%ignore dtAllocSetCustom(dtAllocFunc *allocFunc, dtFreeFunc *freeFunc);
%ignore dtAlloc(int size, dtAllocHint hint);
%ignore dtFree(void* ptr);

%ignore dtSwapEndian(unsigned short *);
%ignore dtSwapEndian(unsigned int *);
%ignore dtSwapEndian(short *);
%ignore dtSwapEndian(int *);
%ignore  dtSwapEndian(int *);
%ignore dtSwapEndian(double *);

%include "DetourAlloc.h"
%include "DetourAssert.h"


%include "DetourCommon.h"
%include "DetourNavMesh.h"
%include "DetourNavMeshBuilder.h"
// djg: This two functions generates link problems:
%ignore passFilter(const dtPolyRef ref, const dtMeshTile* tile, const dtPoly* poly) const;
%ignore getCost(const double* pa, const double* pb,
          const dtPolyRef prevRef, const dtMeshTile* prevTile, const dtPoly* prevPoly,
          const dtPolyRef curRef, const dtMeshTile* curTile, const dtPoly* curPoly,
          const dtPolyRef nextRef, const dtMeshTile* nextTile, const dtPoly* nextPoly) const;
%include "DetourNavMeshQuery.h"
%ignore dtNodePool::getNodeAtIdx(unsigned int) const;
%rename (equals) dtNodeQueue::operator=;
%include "DetourNode.h"
%include "DetourStatus.h"

//DetourCrowd
%include "DetourCrowd.h"
%include "DetourLocalBoundary.h"
//%ignore dtObstacleAvoidanceQuery::sampleVelocityGrid(double const *,double const,double const,double const *,double const *,double *,dtObstacleAvoidanceParams const *);
//%ignore dtObstacleAvoidanceQuery::sampleVelocityAdaptive(double const *,double const,double const,double const *,double const *,double *,dtObstacleAvoidanceParams const *);
%include "DetourObstacleAvoidance.h"
%include "DetourPathCorridor.h"
%include "DetourPathQueue.h"
%include "DetourProximityGrid.h"
//DetourTileCache
%include "DetourTileCache.h"
%include "DetourTileCacheBuilder.h"

//Recast
%ignore rcContext::rcContext();
%ignore rcRasterizeTriangle(rcContext *,double const *,double const *,double const *,unsigned char const,rcHeightfield &);
%ignore rcRasterizeTriangles(rcContext *,double const *,int const,int const *,unsigned char const *,int const,rcHeightfield &);
%ignore rcRasterizeTriangles(rcContext *,double const *,int const,unsigned short const *,unsigned char const *,int const,rcHeightfield &,int const);
%ignore rcRasterizeTriangles(rcContext *,double const *,int const,unsigned short const *,unsigned char const *,int const,rcHeightfield &);
%ignore rcRasterizeTriangles(rcContext *,double const *,unsigned char const *,int const,rcHeightfield &,int const);
%ignore rcRasterizeTriangles(rcContext *,double const *,unsigned char const *,int const,rcHeightfield &);
//%ignore rcBuildContours(rcContext *,rcCompactHeightfield &,double const,int const,rcContourSet &);

%include "Recast.h"

%ignore rcIntArray::rcIntArray(int);
//%rename (valueAt) rcIntArray::operator[];
%ignore rcIntArray::operator [](int);
%include "RecastAlloc.h"
%include "RecastAssert.h"


//demo
%include "AS3_rcContext.h"
%include "ChunkyTriMesh.h"

%ignore rcGetChunksOverlappingRect(const rcChunkyTriMesh* cm, const double bmin[2], const double bmax[2], int* ids, int maxIds);
%ignore rcGetChunksOverlappingSegment(const rcChunkyTriMesh* cm, const double p[2], const double q[2], int* ids, int maxIds);

%include "MeshLoaderObj.h"
%include "InputGeom.h"
//%include "Filelist.h"
%include "Sample.h"
//%ignore addTempObstacle(const double* pos);
%include "Sample_TempObstacles.h"
//%include "Sample_TileMesh.h"
//%include "SampleInterfaces.h"
%include "fastlz.h"

%ignore rcMeshLoaderObj::getVerts();
%ignore rcMeshLoaderObj::getNormals();
%ignore rcMeshLoaderObj::getTris();
