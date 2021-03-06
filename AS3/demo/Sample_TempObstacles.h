//
// Copyright (c) 2009-2010 Mikko Mononen memon@inside.org
//
// This software is provided 'as-is', without any express or implied
// warranty.  In no event will the authors be held liable for any damages
// arising from the use of this software.
// Permission is granted to anyone to use this software for any purpose,
// including commercial applications, and to alter it and redistribute it
// freely, subject to the following restrictions:
// 1. The origin of this software must not be misrepresented; you must not
//    claim that you wrote the original software. If you use this software
//    in a product, an acknowledgment in the product documentation would be
//    appreciated but is not required.
// 2. Altered source versions must be plainly marked as such, and must not be
//    misrepresented as being the original software.
// 3. This notice may not be removed or altered from any source distribution.
//

#ifndef RECASTSAMPLETEMPOBSTACLE_H
#define RECASTSAMPLETEMPOBSTACLE_H

#include "Sample.h"
#include "DetourNavMesh.h"
#include "DetourTileCache.h"
#include "Recast.h"
#include "ChunkyTriMesh.h"

#include "DetourTileCacheBuilder.h"


class Sample_TempObstacles : public Sample
{
protected:
	bool m_keepInterResults;

	struct LinearAllocator* m_talloc;
	struct FastLZCompressor* m_tcomp;
	struct MeshProcess* m_tmproc;

	class dtTileCache* m_tileCache;
	
	double m_cacheBuildTimeMs;
	int m_cacheCompressedSize;
	int m_cacheRawSize;
	int m_cacheLayerCount;
	int m_cacheBuildMemUsage;
	
	
	int m_maxTiles;
	int m_maxPolysPerTile;
	
	
public:
	Sample_TempObstacles();
	virtual ~Sample_TempObstacles();
	
	virtual void handleSettings();
	virtual void handleMeshChanged(class InputGeom* geom);
	virtual bool handleBuild();
	virtual dtStatus handleUpdate(const double dt);

	void getTilePos(const double* pos, int& tx, int& ty);

	int getObstacleCount();
	dtObstacleRef addTempObstacle(const double* pos, const double radius, const double height );
	void removeTempObstacleById(dtObstacleRef id);
	void removeTempObstacle(const double* sp, const double* sq);
	dtObstacleRef hitTempObstacle(const double* sp, const double* sq);
	void clearAllTempObstacles();
	double m_tileSize;
	double m_maxObstacles;
};

bool isectSegAABB(const double* sp, const double* sq,
						 const double* amin, const double* amax,
						 double& tmin, double& tmax);
int calcLayerBufferSize(const int gridWidth, const int gridHeight);

class InputGeom;
struct MeshProcess : public dtTileCacheMeshProcess
{
	InputGeom* m_geom;

	MeshProcess();

	void init(InputGeom* geom);

	virtual void process(struct dtNavMeshCreateParams* params,
						 unsigned char* polyAreas, unsigned short* polyFlags);
};

#endif // RECASTSAMPLETEMPOBSTACLE_H
