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

#ifndef RECASTSAMPLE_H
#define RECASTSAMPLE_H

#include "DetourStatus.h"
#include "Recast.h"


enum SamplePolyAreas
{
	SAMPLE_POLYAREA_GROUND,
	SAMPLE_POLYAREA_WATER,
	SAMPLE_POLYAREA_ROAD,
	SAMPLE_POLYAREA_DOOR,
	SAMPLE_POLYAREA_GRASS,
	SAMPLE_POLYAREA_JUMP,
};
enum SamplePolyFlags
{
	SAMPLE_POLYFLAGS_WALK		= 0x01,		// Ability to walk (ground, grass, road)
	SAMPLE_POLYFLAGS_SWIM		= 0x02,		// Ability to swim (water).
	SAMPLE_POLYFLAGS_DOOR		= 0x04,		// Ability to move through doors.
	SAMPLE_POLYFLAGS_JUMP		= 0x08,		// Ability to jump.
	SAMPLE_POLYFLAGS_DISABLED	= 0x10,		// Disabled polygon
	SAMPLE_POLYFLAGS_ALL		= 0xffff	// All abilities.
};

class Sample
{
protected:	
	class InputGeom* m_geom;
	class dtNavMesh* m_navMesh;
	class dtNavMeshQuery* m_navQuery;
	class dtCrowd* m_crowd;

	//unsigned char m_navMeshDrawFlags;

	rcContext* m_ctx;

public:

	double m_cellSize;
	double m_cellHeight;
	double m_agentHeight;
	double m_agentRadius;
	double m_agentMaxClimb;
	double m_agentMaxSlope;
	double m_regionMinSize;
	double m_regionMergeSize;
	bool m_monotonePartitioning;
	double m_edgeMaxLen;
	double m_edgeMaxError;
	double m_vertsPerPoly;
	double m_detailSampleDist;
	double m_detailSampleMaxError;



	Sample();
	virtual ~Sample();
	
	//void setContext(BuildContext* ctx) { m_ctx = ctx; }
	
	//void setTool(SampleTool* tool);
	//SampleToolState* getToolState(int type) { return m_toolStates[type]; }
	//void setToolState(int type, SampleToolState* s) { m_toolStates[type] = s; }
	
	virtual void handleSettings();
	//virtual void handleTools();
	//virtual void handleDebugMode();
	//virtual void handleClick(const double* s, const double* p, bool shift);
	//virtual void handleToggle();
	virtual void handleStep();
	//virtual void handleRender();
	//virtual void handleRenderOverlay(double* proj, double* model, int* view);
	virtual void handleMeshChanged(class InputGeom* geom);
	virtual bool handleBuild();
	virtual dtStatus handleUpdate(const double dt);

	void setContext(rcContext* ctx) { m_ctx = ctx; }

	virtual class InputGeom* getInputGeom() { return m_geom; }
	virtual class dtNavMesh* getNavMesh() { return m_navMesh; }
	virtual class dtNavMeshQuery* getNavMeshQuery() { return m_navQuery; }
	virtual class dtCrowd* getCrowd() { return m_crowd; }
	virtual double getAgentRadius() { return m_agentRadius; }
	virtual double getAgentHeight() { return m_agentHeight; }
	virtual double getAgentClimb() { return m_agentMaxClimb; }
	virtual const double* getBoundsMin();
	virtual const double* getBoundsMax();
	
	//inline unsigned char getNavMeshDrawFlags() const { return m_navMeshDrawFlags; }
	//inline void setNavMeshDrawFlags(unsigned char flags) { m_navMeshDrawFlags = flags; }

	//void updateToolStates(const double dt);
	//void initToolStates(Sample* sample);
	//void resetToolStates();
	//void renderToolStates();
	//void renderOverlayToolStates(double* proj, double* model, int* view);

	void resetCommonSettings();
	void handleCommonSettings();
};
#endif // RECASTSAMPLE_H
