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

#ifndef CHUNKYTRIMESH_H
#define CHUNKYTRIMESH_H

struct rcChunkyTriMeshNode
{
    double bmin[2], bmax[2];
	int i, n;
};

struct rcChunkyTriMesh
{
	inline rcChunkyTriMesh() : nodes(0), tris(0) {};
	inline ~rcChunkyTriMesh() { delete [] nodes; delete [] tris; }

	rcChunkyTriMeshNode* nodes;
	int nnodes;
	int* tris;
	int ntris;
	int maxTrisPerChunk;
};

/// Creates partitioned triangle mesh (AABB tree),
/// where each node contains at max trisPerChunk triangles.
bool rcCreateChunkyTriMesh(const double* verts, const int* tris, int ntris,
						   int trisPerChunk, rcChunkyTriMesh* cm);

/// Returns the chunk indices which overlap the input rectable.
int rcGetChunksOverlappingRect(const rcChunkyTriMesh* cm, const double bmin[2], const double bmax[2], int* ids, int maxIds);
inline int rcGetChunksOverlappingRectIn(const rcChunkyTriMesh* cm, double bmin1, double bmin2, double bmax1, double bmax2, int* ids, int maxIds)
{
    double bmin[2] = {bmin1, bmin2};
    double bmax[2] = {bmax1, bmax2};
    return rcGetChunksOverlappingRect(cm, bmin, bmax, ids, maxIds);
}

/// Returns the chunk indices which overlap the input segment.
int rcGetChunksOverlappingSegment(const rcChunkyTriMesh* cm, const double p[2], const double q[2], int* ids, int maxIds);
inline int rcGetChunksOverlappingSegmentIn(const rcChunkyTriMesh* cm, double p1, double p2, double q1, double q2, int* ids, int maxIds)
{
    double p[2] = {p1, p2};
    double q[2] = {q1, q2};
    return rcGetChunksOverlappingSegment(cm, p, q, ids, maxIds);
}


#endif // CHUNKYTRIMESH_H
