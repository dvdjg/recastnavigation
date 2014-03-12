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

#ifndef MESHLOADER_OBJ
#define MESHLOADER_OBJ

class rcMeshLoaderObj
{
public:
	rcMeshLoaderObj();
	~rcMeshLoaderObj();
	
	bool load(const char* fileName);

	
    inline void getVertsVal(const double** ppVerts, int *pVertCount) const { *ppVerts = m_verts; *pVertCount = m_vertCount; }
    inline void getNormalsVal(const double** ppVerts, int * pVertCount) const { *ppVerts = m_normals; *pVertCount = m_vertCount; }
    inline void getTrisVal(const int** ppTris, int * pTriCount) const { *ppTris = m_tris; *pTriCount = m_triCount; }

    inline const double* getVert(int i) const { return m_verts + i * 3; }
    inline const double* getNormal(int i) const { return m_normals + i * 3; }
    inline const int* getTri(int i) const { return m_tris + i * 3; }
	
	inline const double* getVerts() const { return m_verts; }
	inline const double* getNormals() const { return m_normals; }
	inline const int* getTris() const { return m_tris; }
	inline int getVertCount() const { return m_vertCount; }
	inline int getTriCount() const { return m_triCount; }
	inline const char* getFileName() const { return m_filename; }

private:
	
	void addVertex(double x, double y, double z, int& cap);
	void addTriangle(int a, int b, int c, int& cap);
	
	char m_filename[260];
	
	double* m_verts;
	int* m_tris;
	double* m_normals;
	int m_vertCount;
	int m_triCount;
};

#endif // MESHLOADER_OBJ
