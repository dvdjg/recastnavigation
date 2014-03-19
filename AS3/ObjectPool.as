package org.dave.objects 
{
	import flash.utils.getQualifiedClassName;
	/**
	 */
	public class ObjectPool
	{
		private static var _instances:Object = new Object;
		private static var _reusedCount:uint = 0;

		protected var _objects:Array;
		protected var _objectClass:Class;
	
		public function ObjectPool(objectClass:Class)
		{
			//if(_instance){
			//	throw new Error("Singleton... use getInstance()");
			//} 
			//_instance = this;
			_objectClass = objectClass;
			_objects = new Array();
		}

		public static function getInstance(objectClass:Class):ObjectPool
		{
			var qualifiedName:String = getQualifiedClassName(objectClass);
			if(!_instances[qualifiedName]){
				_instances[qualifiedName] = new ObjectPool(objectClass);
			} 
			return _instances[qualifiedName];
		}
		
		/** Releases the objects in the pool
		 */
		public static function releaseAllObjects():void
		{
			for (var className:String in _instances) {
				_instances[className].releaseObjects();
			}
			_reusedCount = 0;
		}
	
		public static function get countAllObjects():int
		{
			var ret:int = 0;
			for(var m:String in _instances) {
				if(_instances[m] is Object && _instances[m].hasOwnProperty("countObjects"))
					ret += _instances[m].countObjects;
			}
			return ret;
		}
		
		public static function get reusedCount():uint
		{
			return _reusedCount;
		}
		
		public function getNew():*
		{
			var object:* = null;
			if (_objects.length > 0) {
				object = _objects.pop(); // LIFO
				++_reusedCount; // Count the number of times a new allocation has been avoided.
			} else {
				object = new _objectClass();
			}
			return object;
		}
	
		public function reuseObject(oldObject:Object, bDispose:Boolean = false):void
		{
			if(bDispose)
				dispose(oldObject);
			_objects.push(oldObject); // LIFO
		}
		
		public function releaseObjects():void
		{
			_objects.length = 0;
		}
		
		public function get countObjects():int
		{
			return _objects.length;
		}
		
		public static function dispose(obj:*):*
        {
            if(obj == null) return obj;
            
            var i:int;
            var child:Object;
            
            var className:String = getQualifiedClassName(obj);
            if(className.indexOf("__AS3__.vec::Vector") == 0 || className == "Array")
            {
                var len:int = obj.length;
                
                for(i = 0; i < len; i++)
                {
                    cs.DisposeOf(obj[i]);
                    obj[i] = null;
                }
                if(obj.fixed == false) obj.length = 0;
                return obj;
            }
            if(className == "flash.utils::Dictionary")
            {
                //Get Keys from dictionary.
                var idVec:Vector.<Object> = new Vector.<Object>(0);
                for(var subobj:Object in obj){
                    idVec.push(subobj);
                }
                
                //Delete Keys from dictionary and clear from vector at same time.
                var vLen:int = idVec.length;
                for(var vi:int = 0; vi<vLen; vi++)
                {
                    cs.DisposeOf( obj[ idVec[vi] ]);
                    delete obj[ idVec[vi] ];
                    idVec[vi] = null;
                }
                
                idVec.length = 0;
                idVec = null;                
            }
                        
            if(obj.hasOwnProperty("numChildren") && obj.toString() != "[object TextField]")
            {
                while(obj.numChildren > 0) 
                {
                    child = obj.getChildAt(0);
                    if(child.hasOwnProperty("destroy")) 
                        cs.DisposeOf(child);
                    if(child.hasOwnProperty("parent") && child.parent != null) 
                        child.parent.removeChild(child);
                    
                    child = null;
                }
            }
            
            if(obj.hasOwnProperty("stop"))
                obj.stop();
            if(obj.hasOwnProperty("destroy")) 
                obj.destroy();
            if(obj.hasOwnProperty("bitmapData") && obj.bitmapData != null)
                obj.bitmapData.dispose();            
            if(obj.hasOwnProperty("parent") && obj.parent != null && obj.parent.hasOwnProperty("removeChild"))
                obj.parent.removeChild(obj);
            if(obj.hasOwnProperty("transform"))
                if(obj.transform != null) 
                    obj.transform.matrix = null;
            if(obj.hasOwnProperty("graphics")) 
                obj.graphics.clear();
            if(obj.hasOwnProperty("filters")) 
                obj.filters = [];
            if(obj.hasOwnProperty("dispose"))
                obj.dispose();
			if(obj.hasOwnProperty("clear"))
                obj.clear();

            return obj;
        }		
	}
}