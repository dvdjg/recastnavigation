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

#include <stdio.h>
#define _USE_MATH_DEFINES
#include <math.h>
#include "SDL.h"
#include "SDL_opengl.h"
#include "imgui.h"
#include "imguiRenderGL.h"
#include "Recast.h"
#include "RecastDebugDraw.h"
#include "InputGeom.h"
#include "TestCase.h"
#include "Filelist.h"
#include "SlideShow.h"

#include "Sample_SoloMesh.h"
#include "Sample_TileMesh.h"
#include "Sample_TempObstacles.h"
#include "Sample_Debug.h"

#ifdef WIN32
#	define snprintf _snprintf
#	define putenv _putenv
#endif

struct SampleItem
{
	Sample* (*create)();
	const char* name;
};

Sample* createSolo() { return new Sample_SoloMesh(); }
Sample* createTile() { return new Sample_TileMesh(); }
Sample* createTempObstacle() { return new Sample_TempObstacles(); }
Sample* createDebug() { return new Sample_Debug(); }

static SampleItem g_samples[] =
{
	{ createSolo, "Solo Mesh" },
	{ createTile, "Tile Mesh" },
	{ createTempObstacle, "Temp Obstacles" },
//	{ createDebug, "Debug" },
};
static const int g_nsamples = sizeof(g_samples)/sizeof(SampleItem); 


int main(int /*argc*/, char** /*argv*/)
{
    printf("Initializing...");

	// Init SDL
    if (SDL_Init(SDL_INIT_TIMER | SDL_INIT_VIDEO | SDL_INIT_AUDIO) != 0) // SDL_INIT_EVERYTHING
	{
        printf("Could not initialise SDL:\n%s", SDL_GetError());
		return -1;
	}
	
	// Center window
	char env[] = "SDL_VIDEO_CENTERED=1";
	putenv(env);

	// Init OpenGL
	SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
    SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 16);
    SDL_GL_SetAttribute(SDL_GL_RED_SIZE, 5);
    SDL_GL_SetAttribute(SDL_GL_GREEN_SIZE, 5);
    SDL_GL_SetAttribute(SDL_GL_BLUE_SIZE, 5);
    //SDL_GL_SetAttribute(SDL_GL_ALPHA_SIZE, 8);
//#ifndef WIN32
    //SDL_GL_SetAttribute(SDL_GL_MULTISAMPLEBUFFERS, 1);
    //SDL_GL_SetAttribute(SDL_GL_MULTISAMPLESAMPLES, 4);
//#endif

	const SDL_VideoInfo* vi = SDL_GetVideoInfo();

	bool presentationMode = false;

	int width, height;
	SDL_Surface* screen = 0;
	
	if (presentationMode)
	{
		width = vi->current_w;
		height = vi->current_h;
		screen = SDL_SetVideoMode(width, height, 0, SDL_OPENGL|SDL_FULLSCREEN);
	}
	else
	{	
		width = vi->current_w - 20;
		height = vi->current_h - 80;
//        width = 800;
//        height = 600;
        screen = SDL_SetVideoMode(width, height, 0, SDL_OPENGL);
	}
	
	if (!screen)
	{
        printf("Could not initialise SDL opengl:\n%s", SDL_GetError());
		return -1;
	}

	glEnable(GL_MULTISAMPLE);

	SDL_WM_SetCaption("Recast Demo", 0);
	
	if (!imguiRenderGLInit("DroidSans.ttf"))
	{
		printf("Could not init GUI renderer.\n");
		SDL_Quit();
		return -1;
	}

    printf("Initialized renderer");
	
	double t = 0.0;
	double timeAcc = 0.0;
	Uint32 lastTime = SDL_GetTicks();
	int mx = 0, my = 0;
	double rx = 45;
	double ry = -45;
	double moveW = 0, moveS = 0, moveA = 0, moveD = 0;
	double camx = 0, camy = 0, camz = 0, camr = 1000;
	double origrx = 0, origry = 0;
	int origx = 0, origy = 0;
	double scrollZoom = 0;
	bool rotate = false;
	bool movedDuringRotate = false;
	double rays[3], raye[3]; 
	bool mouseOverMenu = false;
	bool showMenu = !presentationMode;
	bool showLog = false;
	bool showTools = true;
	bool showLevels = false;
	bool showSample = false;
	bool showTestCases = false;

	int propScroll = 0;
	int logScroll = 0;
	int toolsScroll = 0;
	
	char sampleName[64] = "Choose Sample..."; 
	
	FileList files;
	char meshName[128] = "Choose Mesh...";
	
	double mpos[3] = {0,0,0};
	bool mposSet = false;
	
	SlideShow slideShow;
	slideShow.init("slides/");
	
	InputGeom* geom = 0;
	Sample* sample = 0;
	TestCase* test = 0;

	BuildContext ctx;
	
	glEnable(GL_CULL_FACE);
	
    float fogCol[4] = { 0.32, 0.31, 0.30, 1.0 };
	glEnable(GL_FOG);
	glFogi(GL_FOG_MODE, GL_LINEAR);
	glFogf(GL_FOG_START, camr*0.1);
	glFogf(GL_FOG_END, camr*1.25);
	glFogfv(GL_FOG_COLOR, fogCol);
	
	glDepthFunc(GL_LEQUAL);
	
	bool done = false;
	while(!done)
	{
		// Handle input events.
		int mscroll = 0;
		bool processHitTest = false;
		bool processHitTestShift = false;
		SDL_Event event;
		
		while (SDL_PollEvent(&event))
		{
			switch (event.type)
			{
				case SDL_KEYDOWN:
					// Handle any key presses here.
					if (event.key.keysym.sym == SDLK_ESCAPE)
					{
						done = true;
					}
					else if (event.key.keysym.sym == SDLK_t)
					{
						showLevels = false;
						showSample = false;
						showTestCases = true;
						scanDirectory("Tests", ".txt", files);
					}
					else if (event.key.keysym.sym == SDLK_TAB)
					{
						showMenu = !showMenu;
					}
					else if (event.key.keysym.sym == SDLK_SPACE)
					{
						if (sample)
							sample->handleToggle();
					}
					else if (event.key.keysym.sym == SDLK_1)
					{
						if (sample)
							sample->handleStep();
					}
					else if (event.key.keysym.sym == SDLK_9)
					{
						if (geom)
							geom->save("geomset.txt");
					}
					else if (event.key.keysym.sym == SDLK_0)
					{
						delete geom;
						geom = new InputGeom;
						if (!geom || !geom->load(&ctx, "geomset.txt"))
						{
							delete geom;
							geom = 0;
							
							showLog = true;
							logScroll = 0;
							ctx.dumpLog("Geom load log %s:", meshName);
						}
						if (sample && geom)
						{
							sample->handleMeshChanged(geom);
						}
							
						if (geom || sample)
						{
							const double* bmin = 0;
							const double* bmax = 0;
							if (sample)
							{
								bmin = sample->getBoundsMin();
								bmax = sample->getBoundsMax();
							}
							else if (geom)
							{
								bmin = geom->getMeshBoundsMin();
								bmax = geom->getMeshBoundsMax();
							}
							// Reset camera and fog to match the mesh bounds.
							if (bmin && bmax)
							{
								camr = sqrtf(rcSqr(bmax[0]-bmin[0]) +
											 rcSqr(bmax[1]-bmin[1]) +
											 rcSqr(bmax[2]-bmin[2])) / 2;
								camx = (bmax[0] + bmin[0]) / 2 + camr;
								camy = (bmax[1] + bmin[1]) / 2 + camr;
								camz = (bmax[2] + bmin[2]) / 2 + camr;
								camr *= 3;
							}
							rx = 45;
							ry = -45;
							glFogf(GL_FOG_START, camr*0.2);
							glFogf(GL_FOG_END, camr*1.25);
						}
					}
					else if (event.key.keysym.sym == SDLK_RIGHT)
					{
						slideShow.nextSlide();
					}
					else if (event.key.keysym.sym == SDLK_LEFT)
					{
						slideShow.prevSlide();
					}
					break;
					
				case SDL_MOUSEBUTTONDOWN:
					if (event.button.button == SDL_BUTTON_RIGHT)
					{
						if (!mouseOverMenu)
						{
							// Rotate view
							rotate = true;
							movedDuringRotate = false;
							origx = mx;
							origy = my;
							origrx = rx;
							origry = ry;
						}
					}	
					else if (event.button.button == SDL_BUTTON_WHEELUP)
					{
						if (mouseOverMenu)
							mscroll--;
						else
							scrollZoom -= 1.0;
					}
					else if (event.button.button == SDL_BUTTON_WHEELDOWN)
					{
						if (mouseOverMenu)
							mscroll++;
						else
							scrollZoom += 1.0;
					}
					break;
					
				case SDL_MOUSEBUTTONUP:
					// Handle mouse clicks here.
					if (event.button.button == SDL_BUTTON_RIGHT)
					{
						rotate = false;
						if (!mouseOverMenu)
						{
							if (!movedDuringRotate)
							{
								processHitTest = true;
								processHitTestShift = true;
							}
						}
					}
					else if (event.button.button == SDL_BUTTON_LEFT)
					{
						if (!mouseOverMenu)
						{
							processHitTest = true;
							processHitTestShift = (SDL_GetModState() & KMOD_SHIFT) ? true : false;
						}
					}
					
					break;
					
				case SDL_MOUSEMOTION:
					mx = event.motion.x;
					my = height-1 - event.motion.y;
					if (rotate)
					{
						int dx = mx - origx;
						int dy = my - origy;
						rx = origrx - dy*0.25;
						ry = origry + dx*0.25;
						if (dx*dx+dy*dy > 3*3)
							movedDuringRotate = true;
					}
					break;
					
				case SDL_QUIT:
					done = true;
					break;
					
				default:
					break;
			}
		}

		unsigned char mbut = 0;
		if (SDL_GetMouseState(0,0) & SDL_BUTTON_LMASK)
			mbut |= IMGUI_MBUT_LEFT;
		if (SDL_GetMouseState(0,0) & SDL_BUTTON_RMASK)
			mbut |= IMGUI_MBUT_RIGHT;
		
		Uint32	time = SDL_GetTicks();
		double	dt = (time - lastTime) / 1000.0;
		lastTime = time;
		
		t += dt;


		// Hit test mesh.
		if (processHitTest && geom && sample)
		{
			double hitt;
			bool hit = geom->raycastMesh(rays, raye, hitt);
			
			if (hit)
			{
				if (SDL_GetModState() & KMOD_CTRL)
				{
					// Marker
					mposSet = true;
					mpos[0] = rays[0] + (raye[0] - rays[0])*hitt;
					mpos[1] = rays[1] + (raye[1] - rays[1])*hitt;
					mpos[2] = rays[2] + (raye[2] - rays[2])*hitt;
				}
				else
				{
					double pos[3];
					pos[0] = rays[0] + (raye[0] - rays[0])*hitt;
					pos[1] = rays[1] + (raye[1] - rays[1])*hitt;
					pos[2] = rays[2] + (raye[2] - rays[2])*hitt;
					sample->handleClick(rays, pos, processHitTestShift);
				}
			}
			else
			{
				if (SDL_GetModState() & KMOD_CTRL)
				{
					// Marker
					mposSet = false;
				}
			}
		}
		
		// Update sample simulation.
		const double SIM_RATE = 20;
		const double DELTA_TIME = 1.0/SIM_RATE;
		timeAcc = rcClamp(timeAcc+dt, -1.0, 1.0);
		int simIter = 0;
		while (timeAcc > DELTA_TIME)
		{
			timeAcc -= DELTA_TIME;
			if (simIter < 5)
			{
				if (sample)
					sample->handleUpdate(DELTA_TIME);
			}
			simIter++;
		}

		// Clamp the framerate so that we do not hog all the CPU.
		const double MIN_FRAME_TIME = 1.0/40.0;
		if (dt < MIN_FRAME_TIME)
		{
			int ms = (int)((MIN_FRAME_TIME - dt)*1000.0);
			if (ms > 10) ms = 10;
			if (ms >= 0)
				SDL_Delay(ms);
		}
		
		
		// Update and render
		glViewport(0, 0, width, height);
		glClearColor(0.3, 0.3, 0.32, 1.0);
		glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
		glEnable(GL_BLEND);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		glDisable(GL_TEXTURE_2D);
		
		// Render 3d
		glEnable(GL_DEPTH_TEST);
		glMatrixMode(GL_PROJECTION);
		glLoadIdentity();
		gluPerspective(50.0, (double)width/(double)height, 1.0, camr);
		glMatrixMode(GL_MODELVIEW);
		glLoadIdentity();
		glRotated(rx,1,0,0);
		glRotated(ry,0,1,0);
		glTranslated(-camx, -camy, -camz);
		
		// Get hit ray position and direction.
		GLdouble proj[16];
		GLdouble model[16];
		GLint view[4];
		glGetDoublev(GL_PROJECTION_MATRIX, proj);
		glGetDoublev(GL_MODELVIEW_MATRIX, model);
		glGetIntegerv(GL_VIEWPORT, view);
		GLdouble x, y, z;
		gluUnProject(mx, my, 0.0, model, proj, view, &x, &y, &z);
		rays[0] = (double)x; rays[1] = (double)y; rays[2] = (double)z;
		gluUnProject(mx, my, 1.0, model, proj, view, &x, &y, &z);
		raye[0] = (double)x; raye[1] = (double)y; raye[2] = (double)z;
		
		// Handle keyboard movement.
		Uint8* keystate = SDL_GetKeyState(NULL);
		moveW = rcClamp(moveW + dt * 4 * (keystate[SDLK_w] ? 1 : -1), 0.0, 1.0);
		moveS = rcClamp(moveS + dt * 4 * (keystate[SDLK_s] ? 1 : -1), 0.0, 1.0);
		moveA = rcClamp(moveA + dt * 4 * (keystate[SDLK_a] ? 1 : -1), 0.0, 1.0);
		moveD = rcClamp(moveD + dt * 4 * (keystate[SDLK_d] ? 1 : -1), 0.0, 1.0);
		
		double keybSpeed = 22.0;
		if (SDL_GetModState() & KMOD_SHIFT)
			keybSpeed *= 4.0;
		
		double movex = (moveD - moveA) * keybSpeed * dt;
		double movey = (moveS - moveW) * keybSpeed * dt;
		
		movey += scrollZoom * 2.0;
		scrollZoom = 0;
		
		camx += movex * (double)model[0];
		camy += movex * (double)model[4];
		camz += movex * (double)model[8];
		
		camx += movey * (double)model[2];
		camy += movey * (double)model[6];
		camz += movey * (double)model[10];

		glEnable(GL_FOG);

		if (sample)
			sample->handleRender();
		if (test)
			test->handleRender();
		
		glDisable(GL_FOG);
		
		// Render GUI
		glDisable(GL_DEPTH_TEST);
		glMatrixMode(GL_PROJECTION);
		glLoadIdentity();
		gluOrtho2D(0, width, 0, height);
		glMatrixMode(GL_MODELVIEW);
		glLoadIdentity();
		
		mouseOverMenu = false;
		
		imguiBeginFrame(mx,my,mbut,mscroll);
		
		if (sample)
		{
			sample->handleRenderOverlay((double*)proj, (double*)model, (int*)view);
		}
		if (test)
		{
			if (test->handleRenderOverlay((double*)proj, (double*)model, (int*)view))
				mouseOverMenu = true;
		}

		// Help text.
		if (showMenu)
		{
			const char msg[] = "W/S/A/D: Move  RMB: Rotate";
			imguiDrawText(280, height-20, IMGUI_ALIGN_LEFT, msg, imguiRGBA(255,255,255,128));
		}
		
		if (showMenu)
		{
			if (imguiBeginScrollArea("Properties", width-250-10, 10, 250, height-20, &propScroll))
				mouseOverMenu = true;

			if (imguiCheck("Show Log", showLog))
				showLog = !showLog;
			if (imguiCheck("Show Tools", showTools))
				showTools = !showTools;

			imguiSeparator();
			imguiLabel("Sample");
			if (imguiButton(sampleName))
			{
				if (showSample)
				{
					showSample = false;
				}
				else
				{
					showSample = true;
					showLevels = false;
					showTestCases = false;
				}
			}
			
			imguiSeparator();
			imguiLabel("Input Mesh");
			if (imguiButton(meshName))
			{
				if (showLevels)
				{
					showLevels = false;
				}
				else
				{
					showSample = false;
					showTestCases = false;
					showLevels = true;
					scanDirectory("Meshes", ".obj", files);
				}
			}
			if (geom)
			{
				char text[64];
				snprintf(text, 64, "Verts: %.1fk  Tris: %.1fk",
						 geom->getMesh()->getVertCount()/1000.0,
						 geom->getMesh()->getTriCount()/1000.0);
				imguiValue(text);
			}
			imguiSeparator();

			if (geom && sample)
			{
				imguiSeparatorLine();
				
				sample->handleSettings();

				if (imguiButton("Build"))
				{
					ctx.resetLog();
					if (!sample->handleBuild())
					{
						showLog = true;
						logScroll = 0;
					}
					ctx.dumpLog("Build log %s:", meshName);
					
					// Clear test.
					delete test;
					test = 0;
				}

				imguiSeparator();
			}
			
			if (sample)
			{
				imguiSeparatorLine();
				sample->handleDebugMode();
			}

			imguiEndScrollArea();
		}
		
		// Sample selection dialog.
		if (showSample)
		{
			static int levelScroll = 0;
			if (imguiBeginScrollArea("Choose Sample", width-10-250-10-200, height-10-250, 200, 250, &levelScroll))
				mouseOverMenu = true;

			Sample* newSample = 0;
			for (int i = 0; i < g_nsamples; ++i)
			{
				if (imguiItem(g_samples[i].name))
				{
					newSample = g_samples[i].create();
					if (newSample)
						strcpy(sampleName, g_samples[i].name);
				}
			}
			if (newSample)
			{
				delete sample;
				sample = newSample;
				sample->setContext(&ctx);
				if (geom && sample)
				{
					sample->handleMeshChanged(geom);
				}
				showSample = false;
			}

			if (geom || sample)
			{
				const double* bmin = 0;
				const double* bmax = 0;
				if (sample)
				{
					bmin = sample->getBoundsMin();
					bmax = sample->getBoundsMax();
				}
				else if (geom)
				{
					bmin = geom->getMeshBoundsMin();
					bmax = geom->getMeshBoundsMax();
				}
				// Reset camera and fog to match the mesh bounds.
				if (bmin && bmax)
				{
					camr = sqrtf(rcSqr(bmax[0]-bmin[0]) +
								 rcSqr(bmax[1]-bmin[1]) +
								 rcSqr(bmax[2]-bmin[2])) / 2;
					camx = (bmax[0] + bmin[0]) / 2 + camr;
					camy = (bmax[1] + bmin[1]) / 2 + camr;
					camz = (bmax[2] + bmin[2]) / 2 + camr;
					camr *= 3;
				}
				rx = 45;
				ry = -45;
				glFogf(GL_FOG_START, camr*0.1);
				glFogf(GL_FOG_END, camr*1.25);
			}
			
			imguiEndScrollArea();
		}
		
		// Level selection dialog.
		if (showLevels)
		{
			static int levelScroll = 0;
			if (imguiBeginScrollArea("Choose Level", width-10-250-10-200, height-10-450, 200, 450, &levelScroll))
				mouseOverMenu = true;
			
			int levelToLoad = -1;
			for (int i = 0; i < files.size; ++i)
			{
				if (imguiItem(files.files[i]))
					levelToLoad = i;
			}
			
			if (levelToLoad != -1)
			{
				strncpy(meshName, files.files[levelToLoad], sizeof(meshName));
				meshName[sizeof(meshName)-1] = '\0';
				showLevels = false;
				
				delete geom;
				geom = 0;
				
				char path[256];
				strcpy(path, "Meshes/");
				strcat(path, meshName);
				
				geom = new InputGeom;
				if (!geom || !geom->loadMesh(&ctx, path))
				{
					delete geom;
					geom = 0;
					
					showLog = true;
					logScroll = 0;
					ctx.dumpLog("Geom load log %s:", meshName);
				}
				if (sample && geom)
				{
					sample->handleMeshChanged(geom);
				}

				if (geom || sample)
				{
					const double* bmin = 0;
					const double* bmax = 0;
					if (sample)
					{
						bmin = sample->getBoundsMin();
						bmax = sample->getBoundsMax();
					}
					else if (geom)
					{
						bmin = geom->getMeshBoundsMin();
						bmax = geom->getMeshBoundsMax();
					}
					// Reset camera and fog to match the mesh bounds.
					if (bmin && bmax)
					{
						camr = sqrtf(rcSqr(bmax[0]-bmin[0]) +
									 rcSqr(bmax[1]-bmin[1]) +
									 rcSqr(bmax[2]-bmin[2])) / 2;
						camx = (bmax[0] + bmin[0]) / 2 + camr;
						camy = (bmax[1] + bmin[1]) / 2 + camr;
						camz = (bmax[2] + bmin[2]) / 2 + camr;
						camr *= 3;
					}
					rx = 45;
					ry = -45;
					glFogf(GL_FOG_START, camr*0.1);
					glFogf(GL_FOG_END, camr*1.25);
				}
			}
			
			imguiEndScrollArea();
			
		}
		
		// Test cases
		if (showTestCases)
		{
			static int testScroll = 0;
			if (imguiBeginScrollArea("Choose Test To Run", width-10-250-10-200, height-10-450, 200, 450, &testScroll))
				mouseOverMenu = true;

			int testToLoad = -1;
			for (int i = 0; i < files.size; ++i)
			{
				if (imguiItem(files.files[i]))
					testToLoad = i;
			}
			
			if (testToLoad != -1)
			{
				char path[256];
				strcpy(path, "Tests/");
				strcat(path, files.files[testToLoad]);
				test = new TestCase;
				if (test)
				{
					// Load the test.
					if (!test->load(path))
					{
						delete test;
						test = 0;
					}

					// Create sample
					Sample* newSample = 0;
					for (int i = 0; i < g_nsamples; ++i)
					{
						if (strcmp(g_samples[i].name, test->getSampleName()) == 0)
						{
							newSample = g_samples[i].create();
							if (newSample) strcpy(sampleName, g_samples[i].name);
						}
					}
					if (newSample)
					{
						delete sample;
						sample = newSample;
						sample->setContext(&ctx);
						showSample = false;
					}

					// Load geom.
					strcpy(meshName, test->getGeomFileName());
					meshName[sizeof(meshName)-1] = '\0';
					
					delete geom;
					geom = 0;
					
					strcpy(path, "Meshes/");
					strcat(path, meshName);
					
					geom = new InputGeom;
					if (!geom || !geom->loadMesh(&ctx, path))
					{
						delete geom;
						geom = 0;
						showLog = true;
						logScroll = 0;
						ctx.dumpLog("Geom load log %s:", meshName);
					}
					if (sample && geom)
					{
						sample->handleMeshChanged(geom);
					}

					// This will ensure that tile & poly bits are updated in tiled sample.
					if (sample)
						sample->handleSettings();

					ctx.resetLog();
					if (sample && !sample->handleBuild())
					{
						ctx.dumpLog("Build log %s:", meshName);
					}
					
					if (geom || sample)
					{
						const double* bmin = 0;
						const double* bmax = 0;
						if (sample)
						{
							bmin = sample->getBoundsMin();
							bmax = sample->getBoundsMax();
						}
						else if (geom)
						{
							bmin = geom->getMeshBoundsMin();
							bmax = geom->getMeshBoundsMax();
						}
						// Reset camera and fog to match the mesh bounds.
						if (bmin && bmax)
						{
							camr = sqrtf(rcSqr(bmax[0]-bmin[0]) +
										 rcSqr(bmax[1]-bmin[1]) +
										 rcSqr(bmax[2]-bmin[2])) / 2;
							camx = (bmax[0] + bmin[0]) / 2 + camr;
							camy = (bmax[1] + bmin[1]) / 2 + camr;
							camz = (bmax[2] + bmin[2]) / 2 + camr;
							camr *= 3;
						}
						rx = 45;
						ry = -45;
						glFogf(GL_FOG_START, camr*0.2);
						glFogf(GL_FOG_END, camr*1.25);
					}
					
					// Do the tests.
					if (sample)
						test->doTests(sample->getNavMesh(), sample->getNavMeshQuery());
				}
			}				
				
			imguiEndScrollArea();
		}

		
		// Log
		if (showLog && showMenu)
		{
			if (imguiBeginScrollArea("Log", 250+20, 10, width - 300 - 250, 200, &logScroll))
				mouseOverMenu = true;
			for (int i = 0; i < ctx.getLogCount(); ++i)
				imguiLabel(ctx.getLogText(i));
			imguiEndScrollArea();
		}
		
		// Tools
		if (!showTestCases && showTools && showMenu) // && geom && sample)
		{
			if (imguiBeginScrollArea("Tools", 10, 10, 250, height-20, &toolsScroll))
				mouseOverMenu = true;

			if (sample)
				sample->handleTools();
			
			imguiEndScrollArea();
		}
		
		slideShow.updateAndDraw(dt, (double)width, (double)height);
		
		// Marker
		if (mposSet && gluProject((GLdouble)mpos[0], (GLdouble)mpos[1], (GLdouble)mpos[2],
								  model, proj, view, &x, &y, &z))
		{
			// Draw marker circle
			glLineWidth(5.0);
			glColor4ub(240,220,0,196);
			glBegin(GL_LINE_LOOP);
			const double r = 25.0;
			for (int i = 0; i < 20; ++i)
			{
				const double a = (double)i / 20.0 * RC_PI*2;
				const double fx = (double)x + cosf(a)*r;
				const double fy = (double)y + sinf(a)*r;
				glVertex2d(fx,fy);
			}
			glEnd();
			glLineWidth(1.0);
		}
		
		imguiEndFrame();
		imguiRenderGLDraw();		
		
		glEnable(GL_DEPTH_TEST);
		SDL_GL_SwapBuffers();
	}
	
	imguiRenderGLDestroy();
	
	SDL_Quit();
	
	delete sample;
	delete geom;
	
	return 0;
}
