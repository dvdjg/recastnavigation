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

#ifndef INPUTGEOM_H
#define INPUTGEOM_H

#include "ChunkyTriMesh.h"
#include "MeshLoaderObj.h"

static const int MAX_CONVEXVOL_PTS = 12;
struct ConvexVolume
{
	double verts[MAX_CONVEXVOL_PTS*3];
	double hmin, hmax;
	int nverts;
	int area;
};

class InputGeom
{
	rcChunkyTriMesh* m_chunkyMesh;
	rcMeshLoaderObj* m_mesh;
	double m_meshBMin[3], m_meshBMax[3];
	
	/// @name Off-Mesh connections.
	///@{
	static const int MAX_OFFMESH_CONNECTIONS = 256;
	double m_offMeshConVerts[MAX_OFFMESH_CONNECTIONS*3*2];
	double m_offMeshConRads[MAX_OFFMESH_CONNECTIONS];
	unsigned char m_offMeshConDirs[MAX_OFFMESH_CONNECTIONS];
	unsigned char m_offMeshConAreas[MAX_OFFMESH_CONNECTIONS];
	unsigned short m_offMeshConFlags[MAX_OFFMESH_CONNECTIONS];
	unsigned int m_offMeshConId[MAX_OFFMESH_CONNECTIONS];
	int m_offMeshConCount;
	///@}

	/// @name Convex Volumes.
	///@{
	static const int MAX_VOLUMES = 256;
	ConvexVolume m_volumes[MAX_VOLUMES];
	int m_volumeCount;
	///@}
	
public:
	InputGeom();
	~InputGeom();
	
	bool loadMesh(class rcContext* ctx, const char* filepath);
    bool loadMeshFromBuffer(rcContext* ctx, const unsigned char* buf, int bufSize);
	
	bool load(class rcContext* ctx, const char* filepath);
    bool loadFromBuffer(class rcContext* ctx, const unsigned char* buf, int bufSize); // djg
	bool save(const char* filepath);
	
	/// Method to return static mesh data.
	inline const rcMeshLoaderObj* getMesh() const { return m_mesh; }
	inline const double* getMeshBoundsMin() const { return m_meshBMin; }
	inline const double* getMeshBoundsMax() const { return m_meshBMax; }
	inline const rcChunkyTriMesh* getChunkyMesh() const { return m_chunkyMesh; }
	bool raycastMesh(double* src, double* dst, double& tmin);

	/// @name Off-Mesh connections.
	///@{
	int getOffMeshConnectionCount() const { return m_offMeshConCount; }
	const double* getOffMeshConnectionVerts() const { return m_offMeshConVerts; }
	const double* getOffMeshConnectionRads() const { return m_offMeshConRads; }
	const unsigned char* getOffMeshConnectionDirs() const { return m_offMeshConDirs; }
	const unsigned char* getOffMeshConnectionAreas() const { return m_offMeshConAreas; }
	const unsigned short* getOffMeshConnectionFlags() const { return m_offMeshConFlags; }
	const unsigned int* getOffMeshConnectionId() const { return m_offMeshConId; }
	void addOffMeshConnection(const double* spos, const double* epos, const double rad,
							  unsigned char bidir, unsigned char area, unsigned short flags);
	void deleteOffMeshConnection(int i);
	void drawOffMeshConnections(struct duDebugDraw* dd, bool hilight = false);
	///@}

	/// @name Box Volumes.
	///@{
	int getConvexVolumeCount() const { return m_volumeCount; }
	const ConvexVolume* getConvexVolumes() const { return m_volumes; }
	void addConvexVolume(const double* verts, int nverts,
						 const double minh, const double maxh, unsigned char area);
	void deleteConvexVolume(int i);
	void drawConvexVolumes(struct duDebugDraw* dd, bool hilight = false);
	///@}

    /// @name Access functions (avoids the use of rcMeshLoaderObj).
    ///@{
    inline void getVertsVector(const double** ppVerts, int *pVertCount) const { m_mesh->getVertsVector(ppVerts, pVertCount); }
    inline void getNormalsVector(const double** ppVerts, int * pVertCount) const { m_mesh->getNormalsVector(ppVerts, pVertCount); }
    inline void getTrisVector(const int** ppTris, int * pTriCount) const { m_mesh->getTrisVector(ppTris, pTriCount); }

    inline const double* getVertex(int i) const { return m_mesh->getVertex(i); }
    inline const double* getNormal(int i) const { return m_mesh->getNormal(i); }
    inline const int* getTriangle(int i) const { return m_mesh->getTriangle(i); }

    inline int getVertCount() const { return  m_mesh->getVertCount(); }
    inline int getTriCount() const { return m_mesh->getTriCount(); }
    ///@}
};

#endif // INPUTGEOM_H
