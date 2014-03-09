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
//#include "RecastDump.h"

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
#include "Sample.h"
#include "Sample_TempObstacles.h"

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

      // AS3_Val as3verts = AS3_Array("");
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
%as3import("flash.utils.ByteArray");

%apply int{size_t};
//%apply int{const int};
// (\bdouble\s*\*\s*\w+\s*,\s*)const +(int +\w+)
%typemap(astype) (const double* p, int n) "Vector.<Number>";

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
	// For 10 vertices, the Vector must have 30 Numbers.
	//  @param[in]		verts		The vertices of the polygon [Form: (x, y, z) * @p nverts]
	//  @param[in]		nverts		The number of vertices in the polygon.
	
    // setup some new C variables that we're going to modify from within our inline ActionScript
    double* newBuffer;
    int newBufferSize;

    // Use the inline_as3() function that is defined in AS3.h to write the ActionScript code
    // that will convert the Vector into something C can use.  Notice that we are using $input
    // inside this inline_as3() call.
    inline_as3("var ptr$1:int = CModule.malloc($input.length*8);\n"); // 8 bytes per double

    // This next inline call is a little more complicated.  Here we use the %0 flag to pass
    // the value of the ActionScript $input.length variable to the C variable named newBufferSize.
    inline_as3("%0 = $input.length;\n": "=r"(newBufferSize));

    // Similarly we'll pass the value of the ptr$1 variable in ActionScript to the C newBuffer variable
    inline_as3("%0 = ptr$1;\n": "=r"(newBuffer));

    // Now push that Vector into flascc memory
    inline_as3("for (var i:int = 0; i < $input.length; i++){\n");
    inline_as3("	CModule.writeDouble(ptr$1 + 8*i, $input[i]);\n");
    inline_as3("}\n");

    // Finally assign the parameters that C is expecting to our new values
    $1 = newBuffer;
    $2 = newBufferSize/3;
}

// Free the memory that we CModule.malloc'd in the equivalent typemap(in)
%typemap(freearg) (const double* p, int n) {
	inline_as3("CModule.free(%0);\n": : "r"($1));
};
// const int* tris, const double* normals, int ntris
%apply (const double* p, int n) {
	(const double* verts, int nverts),
	(const double* verts, int nv),
	(const double* pts, int npts),
	(const double* polya, int npolya),
	(const double* polyb, int npolyb)
};

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
    int newBufferSize;

    // Use the inline_as3() function that is defined in AS3.h to write the ActionScript code
    // that will convert the Vector into something C can use.  Notice that we are using $input
    // inside this inline_as3() call.
    inline_as3("var ptr$1:int = CModule.malloc($input.length*4);\n"); // 4 bytes per int

    // This next inline call is a little more complicated.  Here we use the %0 flag to pass
    // the value of the ActionScript $input.length variable to the C variable named newBufferSize.
    inline_as3("%0 = $input.length;\n": "=r"(newBufferSize));

    // Similarly we'll pass the value of the ptr$1 variable in ActionScript to the C newBuffer variable
    inline_as3("%0 = ptr$1;\n": "=r"(newBuffer));

    // Now push that Vector into flascc memory
    inline_as3("CModule.writeIntVector(ptr$1, $input);\n");
    
    // Finally assign the parameters that C is expecting to our new values
    $1 = newBuffer;
    $2 = newBufferSize/3;
}

// Free the memory that we CModule.malloc'd in the equivalent typemap(in)
%typemap(freearg) (const int* tris, int nt) {
    inline_as3("CModule.free(%0);\n": : "r"($1));
};

%apply (const int* tris, int nt) {
	(const int* verts, int nverts),
	(const int* tris, int ntris),
	(const int* edges, int nedges)
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
    int newBufferSize;

    // Use the inline_as3() function that is defined in AS3.h to write the ActionScript code
    // that will convert the Vector into something C can use.  Notice that we are using $input
    // inside this inline_as3() call.
    inline_as3("var ptr$1:int = CModule.malloc($input.length*2);\n"); // 2 bytes per unsigned short

    // This next inline call is a little more complicated.  Here we use the %0 flag to pass
    // the value of the ActionScript $input.length variable to the C variable named newBufferSize.
    inline_as3("%0 = $input.length;\n": "=r"(newBufferSize));

    // Similarly we'll pass the value of the ptr$1 variable in ActionScript to the C newBuffer variable
    inline_as3("%0 = ptr$1;\n": "=r"(newBuffer));

    // Now push that Vector into flascc memory
    inline_as3("for (var i:int = 0; i < $input.length; i++){\n");
    inline_as3("	CModule.write16(ptr$1 + 2*i, $input[i]);\n");
    inline_as3("}\n");

    // Finally assign the parameters that C is expecting to our new values
    $1 = newBuffer;
    $2 = newBufferSize/3;
}

// Free the memory that we CModule.malloc'd in the equivalent typemap(in)
%typemap(freearg) (const unsigned short* idx, int nidx) {
    inline_as3("CModule.free(%0);\n": : "r"($1));
};

%apply (const unsigned short* idx, int nidx) {
	(const unsigned short* p, int nvp)
};

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
    int newBufferSize;

    // Use the inline_as3() function that is defined in AS3.h to write the ActionScript code
    // that will convert the Vector into something C can use.  Notice that we are using $input
    // inside this inline_as3() call.
    inline_as3("$input.position=0;\nvar ptr$1:int = CModule.malloc($input.length);\n"); 

    // This next inline call is a little more complicated.  Here we use the %0 flag to pass
    // the value of the ActionScript $input.length variable to the C variable named newBufferSize.
    inline_as3("%0 = $input.length;\n": "=r"(newBufferSize));

    // Similarly we'll pass the value of the ptr$1 variable in ActionScript to the C newBuffer variable
    inline_as3("%0 = ptr$1;\n": "=r"(newBuffer));

    // Now push that Vector into flascc memory
    inline_as3("CModule.writeBytes(ptr$1, $input.bytesAvailable, $input);\n");
    
    // Finally assign the parameters that C is expecting to our new values
    $1 = newBuffer;
    $2 = newBufferSize;
}

// Free the memory that we CModule.malloc'd in the equivalent typemap(in)
%typemap(freearg) (const unsigned char* p, int n) {
    inline_as3("CModule.free(%0);\n": : "r"($1));
};

%apply (const unsigned char* p, int n) {
	(const unsigned char* buffer, int bufferSize),
	(const unsigned char* compressed, int compressedSize),
	(const unsigned char* data, int maxDataSize)
};

%typemap(astype) (unsigned char* surfaces) "ByteArray";

%typemap(in) unsigned char* surfaces {
    // Workaround to a SWIG bug. Pass the AS3 argument name to the %typemap(argout) '$1' $input
	%#ifdef _BUG_$1
	%#undef _BUG_$1
	%#endif 
	%#define _BUG_$1 "$input"
	unsigned char * newBuffer;
	inline_as3("var ptr$1:int = CModule.malloc($input.length);\n"); 
    // Similarly we'll pass the value of the ptr$1 variable in ActionScript to the C newBuffer variable
    inline_as3("%0 = ptr$1;\n": "=r"(newBuffer));

    // This next inline call is a little more complicated.  Here we use the %0 flag to pass
    // the value of the ActionScript $input.length variable to the C variable named newBufferSize.
    //inline_as3("%0 = $input.length;\n": "=r"(newBufferSize));
	
	inline_as3("var ba$1:ByteArray = $input;\n");
	
	// Finally assign the parameters that C is expecting to our new values
    $1 = newBuffer;
} 

// Bug? $input doesn't work here
%typemap(argout) unsigned char* surfaces {
    // Now pull that Vector into flascc memory// Workaround to a SWIG bug: Can't access input.
    inline_as3(_BUG_$1".position = 0;\nCModule.readBytes(ptr$1, "_BUG_$1".length,ba$1); // _BUG_$1 is the same object as ba$1\n");
}


%typemap(astype) (double*) "Object";

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
%typemap(in) double* (double dVectorOut[3]) {
    // Workaround to a SWIG bug. Pass the AS3 argument name to the %typemap(argout) '$1' $input
	%#ifdef _BUG_$1
	%#undef _BUG_$1
	%#endif 
	%#define _BUG_$1 "$input"
	inline_as3("var ptr$1:int = %0;\n": : "r"(dVectorOut));

    // Now push that Vector into flascc memory
    inline_as3("CModule.writeDouble(ptr$1 + 8*0, $input.x);\n");
    inline_as3("CModule.writeDouble(ptr$1 + 8*1, $input.y);\n");
    inline_as3("CModule.writeDouble(ptr$1 + 8*2, $input.z);\n");

    // Finally assign the parameters that C is expecting to our new values
    $1 = dVectorOut;
}

// Bug? $input doesn't work here
%typemap(argout) double* out {
    // Now pull that Vector into flascc memory// Workaround to a SWIG bug: Can't access input.
    inline_as3(_BUG_$1".x = CModule.readDouble(ptr$1 + 8*0); // Return to _BUG_$1, $input, $result, $symname, $0, $1\n");
    inline_as3(_BUG_$1".y = CModule.readDouble(ptr$1 + 8*1);\n");
    inline_as3(_BUG_$1".z = CModule.readDouble(ptr$1 + 8*2);\n");
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


%typemap(astype) int& "Object";

%typemap(in) int& (int vector[1]) {
    // Workaround to a SWIG bug. Pass the AS3 argument name to the %typemap(argout) '$1' $input
	%#ifdef _BUG_$1
	%#undef _BUG_$1
	%#endif 
	%#define _BUG_$1 "$input"

	inline_as3("var ptr$1:int = %0;\n": : "r"(vector));
	// Finally assign the parameters that C is expecting to our new values
    $1 = vector;
//	inline_as3("var ptr$1:Object = %0; // Alias of the input\n": : "r"($input));
} 


// Bug? $input doesn't work here
%typemap(argout) int& {
    // Now pull that Vector into flascc memory// Workaround to a SWIG bug: Can't access input.
    inline_as3(_BUG_$1"['value'] = CModule.read32(ptr$1);\n");
};


%typemap(astype) double& "Object";

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
%ignore  dtSwapEndian(int *);
//%ignore  dtSwapEndian(double 

%include "DetourAlloc.h"
%include "DetourAssert.h"

%ignore dtSwapEndian(double *);

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
%rename (valueAt) rcIntArray::operator[];
%ignore rcIntArray::operator [](int);
%include "RecastAlloc.h"
%include "RecastAssert.h"


//demo
%include "AS3_rcContext.h"
%include "ChunkyTriMesh.h"
%include "MeshLoaderObj.h"
%include "InputGeom.h"
%include "Sample.h"
//%ignore addTempObstacle(const double* pos);
%include "Sample_TempObstacles.h"
