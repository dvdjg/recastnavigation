package  
{
	import flash.geom.Vector3D;
	import flash.text.TextField;
	import flash.utils.ByteArray;
	import org.dave.interfaces.IInitDestroy;
	import org.dave.objects.ObjectPool;
	import org.recastnavigation.dtObstacleAvoidanceParams;
	
	import org.recastnavigation.AS3_rcContext;
	import org.recastnavigation.CModule;
	import org.recastnavigation.InputGeom;
	import org.recastnavigation.Recast;
	import org.recastnavigation.Sample_TempObstacles;
	import org.recastnavigation.dtCrowd;
	import org.recastnavigation.dtCrowdAgent;
	import org.recastnavigation.dtCrowdAgentParams;
	import org.recastnavigation.dtNavMeshQuery;
	import org.recastnavigation.rcMeshLoaderObj;

	/**
	 * Example manager class for Recast Detour Path finding
	 */
	public class RecastManager implements IInitDestroy
	{	
		public var poolObject:ObjectPool = ObjectPool.objectPoolInstance;
		public var scale:Vector3D = new Vector3D(1, 1, 1); //the scale of the nav mesh to the world
		public var maxAgents:int = 60;
		public var maxAgentRadius:Number= 4;
		public var captureState:Boolean = false;
		public var restoreState:Boolean = false;
		public var capturedStates:Array = new Array;
		
		public var  m_cellSize:Number = 0.3,
					m_cellHeight:Number = 0.2,
					m_agentHeight:Number = 3.0,
					m_agentRadius:Number = 0.32,
					m_agentMaxClimb:Number = 2.9,
					m_agentMaxSlope:Number = 45.0,
					m_regionMinSize:Number = 8,
					m_regionMergeSize:Number = 20,
					m_edgeMaxLen:Number = 12.0,
					m_edgeMaxError:Number = 1.3,
					m_vertsPerPoly:Number = 6.0,
					m_detailSampleDist:Number = 6.0,
					m_detailSampleMaxError:Number = 1.0,
					m_tileSize:int = 48,
					m_maxObstacles:int = 1024;
		public var _mainAgentId:int = -1;
		public var _mainAgentX:Number;
		public var _mainAgentY:Number;

		protected var _agentPtr:dtCrowdAgent = new dtCrowdAgent;
		protected var _agentParamsPtr:dtCrowdAgentParams = new dtCrowdAgentParams;
		protected var _agentParams:dtCrowdAgentParams = dtCrowdAgentParams.create();
		protected var _agentParamsArray:Vector.<dtCrowdAgentParams> = new Vector.<dtCrowdAgentParams>;
		
		public function init():void
		{
			var agentParamsDef:dtCrowdAgentParams = dtCrowdAgentParams.create();
			_agentParamsArray.push(agentParamsDef);
		}

		public function destroy():void
		{
			
		}

		public function loadMesh(filename:String, obj:ByteArray):void
		{
			//load the mesh file into recast
			CModule.vfs.addFile(filename, obj );
			
			CModule.startAsync(this);
			
			var as3LogContext:AS3_rcContext = AS3_rcContext.create();
			_sample = Sample_TempObstacles.create();
			geom = InputGeom.create();
			
			var loadResult:Boolean = geom.loadMesh(as3LogContext, filename);

			//update mesh settings
			sample.m_cellSize = m_cellSize;
			sample.m_cellHeight = m_cellHeight;
			sample.m_agentHeight = m_agentHeight;
			sample.m_agentRadius = m_agentRadius;
			sample.m_agentMaxClimb = m_agentMaxClimb;
			sample.m_agentMaxSlope = m_agentMaxSlope;
			sample.m_regionMinSize = m_regionMinSize;
			sample.m_regionMergeSize = m_regionMergeSize;
			sample.m_edgeMaxLen = m_edgeMaxLen;
			sample.m_edgeMaxError = m_edgeMaxError;
			sample.m_vertsPerPoly = m_vertsPerPoly;
			sample.m_detailSampleDist = m_detailSampleDist;
			sample.m_detailSampleMaxError = m_detailSampleMaxError;
			sample.m_tileSize = m_tileSize;
			sample.m_maxObstacles = m_maxObstacles;
			
			//build mesh
			sample.setContext(as3LogContext);
			sample.handleMeshChanged(geom);
			sample.handleSettings();
			
			var startTime:Number = new Date().valueOf();
			var buildSuccess:Boolean = sample.handleBuild();
			trace("Build=" + buildSuccess, ". Build time", new Date().valueOf() - startTime, "ms");
			
			var oid:int = addObstacle(new Vector3D(22, 33, 44), 55, 11);
			initCrowd();
		}
		
		protected function initCrowd():void
		{
			crowd = sample.getCrowd();
			crowd.init(maxAgents, maxAgentRadius, sample.getNavMesh() );
			
			// Make polygons with 'disabled' flag invalid.
			crowd.getEditableFilter().setExcludeFlags(Recast.SAMPLE_POLYFLAGS_DISABLED);
			
			// Setup local avoidance params to different qualities.
			var params:dtObstacleAvoidanceParams = dtObstacleAvoidanceParams.create();
			
			// Use mostly default settings, copy from dtCrowd.
			params.copyFrom(crowd.getObstacleAvoidanceParams(0));
			
			// Low (11)
			params.velBias = 0.5;
			params.adaptiveDivs = 5;
			params.adaptiveRings = 2;
			params.adaptiveDepth = 1;
			crowd.setObstacleAvoidanceParams(0, params);
			
			// Medium (22)
			params.velBias = 0.5;
			params.adaptiveDivs = 5; 
			params.adaptiveRings = 2;
			params.adaptiveDepth = 2;
			crowd.setObstacleAvoidanceParams(1, params);
			
			// Good (45)
			params.velBias = 0.5;
			params.adaptiveDivs = 7;
			params.adaptiveRings = 2;
			params.adaptiveDepth = 3;
			crowd.setObstacleAvoidanceParams(2, params);
			
			// High (66)
			params.velBias = 0.5;
			params.adaptiveDivs = 7;
			params.adaptiveRings = 3;
			params.adaptiveDepth = 3;
			
			crowd.setObstacleAvoidanceParams(3, params);
		}
		
		public function captureStates():void
		{
			capturedStates.length = 0;
			var totalAgents:int = crowd.getAgentCount();
			for (var nAgent:int = 0; nAgent < totalAgents; ++nAgent)
			{
				if (crowd.getAgentActiveState(nAgent))
				{
					var agentPtr:dtCrowdAgent = crowd.getAgent(nAgent);
					var agentParamsPtr:dtCrowdAgentParams = agentPtr.params;
					var rad:Number = agentParamsPtr.radius;
					var pos:Object = crowd.getAgentPosition(nAgent);
					var vel:Object = crowd.getAgentActualVelocity(nAgent);
					var agent:Object = { i:nAgent, p:pos, v:vel, r:rad, 
						targetRef:agentPtr.targetRef, targetPos:agentPtr.targetPos};
					capturedStates.push(agent);
				}
			}
		}
		
		public function restoreStates():void
		{
			_agentParams.copyFrom(_agentParams);
			crowd.removeAllAgents();
			var totalAgents:int = capturedStates.length;
			for (var nAgent:int = 0; nAgent < totalAgents; ++nAgent)
			{
				var agent:Object = capturedStates[nAgent];
				_agentParams.radius = agent.r;
				crowd.addAgent(agent.p, _agentParams, agent.i);
				crowd.setAgentActualVelocity(agent.i, agent.v);
				if (agent.targetRef) {
					crowd.requestMoveTarget(agent.i, agent.targetRef, agent.targetPos);
				} else {
					crowd.requestMoveVelocity(agent.i, agent.targetPos);
				}
			}
			_agentParams.destroy();
		}
		
		var mainPos:Object = { x:0, y:0, z:0 };
		var pos:Object = { x:0, y:0, z:0 };
		public function advanceTime(deltaTime:Number):void
		{
			if( crowd ) {
				if (restoreState) {
					restoreStates();
					restoreState = false;
				}
				//crowd.update(deltaTime, crowdDebugPtr);
				crowd.updateComputeDesiredPosition(deltaTime, null); // crowdDebugPtr
				//crowd.updateHandleCollisions();
				//var pos:Object = ObjectPool.objectPoolInstance.getNew();
				pos.x = _mainAgentX  / scale.x;
				pos.y = -22 / scale.y;
				pos.z = _mainAgentY / scale.z;
				
				crowd.setAgentPosition(_mainAgentId, pos);
				mainPos.x = pos.x - mainPos.x;
				mainPos.y = pos.y - mainPos.y;
				mainPos.z = pos.z - mainPos.z;
				crowd.setAgentDesiredVelocity(_mainAgentId, mainPos);
				crowd.setAgentActualVelocity(_mainAgentId, mainPos);
				mainPos.x = pos.x;
				mainPos.y = pos.y;
				mainPos.z = pos.z;
				//ObjectPool.objectPoolInstance.reuseObject(pos);
				
				crowd.updateReinsertToNavmesh(deltaTime);
				
				if (captureState) {
					captureStates();
					captureState = false;
				}
			}
			var res:int = sample.handleUpdate(deltaTime); //update the tileCache
			//var re:Boolean = Recast.dtStatusSucceed(res);
			//re = !re;
		}
		
		//todo - this should take 2 params, position, and dtCrowdAgentParams
		public function addAgentNear(
			scenePosition:Vector3D, 
			radius:Number = 1.0, 
			height:Number = 2.0, 
			maxAccel:Number = 8.5, 
			maxSpeed:Number = 4.5, 
			collisionQueryRange:Number = 4, 
			pathOptimizationRange:Number=30 ):int
		{
			var navPosition:Vector3D = new Vector3D(scenePosition.x / scale.x, scenePosition.y / scale.y, scenePosition.z / scale.z );
			_agentParams.radius  = radius / scale.x;
			_agentParams.height  = height / scale.y;
			_agentParams.maxAcceleration = maxAccel;
			_agentParams.maxSpeed = maxSpeed;
			_agentParams.collisionQueryRange = collisionQueryRange;
			_agentParams.pathOptimizationRange = pathOptimizationRange;
			_agentParams.separationWeight = 20;
			_agentParams.obstacleAvoidanceType = 3; // High (66)
			
			var updateFlags:uint = 0;
			//todo - need to add class for enum 
			updateFlags |= Recast.DT_CROWD_ANTICIPATE_TURNS;
			updateFlags |= Recast.DT_CROWD_OPTIMIZE_VIS;
			updateFlags |= Recast.DT_CROWD_OPTIMIZE_TOPO;
			updateFlags |= Recast.DT_CROWD_OBSTACLE_AVOIDANCE;
			updateFlags |= Recast.DT_CROWD_SEPARATION;
			_agentParams.updateFlags = updateFlags; //since updateFlags is stored as a char in recast, need to save the string as the char code value
			
			var idx:int = crowd.addAgent(navPosition, _agentParams, -1 );
			
			var navquery:dtNavMeshQuery  = sample.getNavMeshQuery();

			var targetRef:Object = {};
			var targetPos:Object = ObjectPool.objectPoolInstance.getNew();
			var queryExtents:Object = crowd.getQueryExtents();
			
			var statusPtr:int = navquery.findNearestPoly(navPosition, queryExtents, crowd.getFilter(), targetRef, targetPos);
			if (Recast.dtStatusFailed(statusPtr)) {
				trace("Error");
			}
			trace("addAgentNear: navPosition={", navPosition.x, navPosition.y, navPosition.z, "} targetPos={", targetPos.x, targetPos.y, targetPos.z,"}");
			
			if (targetRef.value != 0)
				crowd.requestMoveTarget(idx, targetRef.value, targetPos);
				
			ObjectPool.objectPoolInstance.reuseObject(targetPos);
			
			return idx;
		}
		
		
		public function moveAgentNear(idx:int, scenePosition:Vector3D):void
		{
			var navPosition:Vector3D = new Vector3D(scenePosition.x / scale.x, scenePosition.y / scale.y, scenePosition.z / scale.z );
			
			var navquery:dtNavMeshQuery  = sample.getNavMeshQuery();
			
			var targetRef:Object = {};
			var targetPos:Object = ObjectPool.objectPoolInstance.getNew();
			var queryExtents:Object = crowd.getQueryExtents();
			
			var status:int = navquery.findNearestPoly(navPosition, queryExtents, crowd.getFilter(), targetRef, targetPos);
		
			if ( targetRef.value != 0)
				crowd.requestMoveTarget(idx, targetRef.value, targetPos);
				
			ObjectPool.objectPoolInstance.reuseObject(queryExtents);
			ObjectPool.objectPoolInstance.reuseObject(targetPos);
		}
		
		public function addObstacle(scenePosition:Vector3D, obstacleRadius:Number, obstacleHeight:Number):int
		{
			var navPosition:Vector3D = new Vector3D(scenePosition.x / scale.x, scenePosition.y / scale.y, scenePosition.z / scale.z );
			//var obj:Object = sample.getBoundsMax();
			var obstacleRef:int;
			//obstacleRef = sample.addTempObstacleDumb(obstacleRadius / scale.x, obstacleHeight * scale.y);
			obstacleRef = sample.addTempObstacle(navPosition, obstacleRadius / scale.x, obstacleHeight * scale.y);
			return obstacleRef;
		}
		
		public function removeObstalce(oid:int):void
		{
			sample.removeTempObstacleById(oid);
		}
		
		public function get geomerty():InputGeom
		{
			return geom;
		}
		
		/**
		 * get the X position of the agent in world space
		 * @param	idx
		 * @return
		 */
		public function getAgentPos(idx:int):Object
		{
			var count:int = crowd.getAgentCount();
			var desired:Object = crowd.getAgentDesiredVelocity(idx);
			var pos:Object = crowd.getAgentPosition(idx);
			var ret:Object = poolObject.getNew();
			ret.x = pos.x * scale.x;
			ret.y = pos.y * scale.y;
			ret.z = pos.z * scale.z;
			ObjectPool.objectPoolInstance.reuseObject(desired);
			ObjectPool.objectPoolInstance.reuseObject(pos);
			return ret;
		}
		
		public function get sample():Sample_TempObstacles
		{
			return _sample;
		}
		
			//recast variables
		private var _sample:Sample_TempObstacles;
		private var geom:InputGeom;
		private var crowd:dtCrowd;
		private var crowdDebugPtr:int;
		private var mLastFrameTimestamp:Number;
		
	}

}