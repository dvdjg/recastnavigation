package org.dave.objects 
{
	import flash.utils.getQualifiedClassName;
	/**
	 */
	public class ObjectPool
	{
		private static var _instances:Object = new Object;
		//private static var _instance:ObjectPool;

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

		public static function getInstance(objectClass:Class):ObjectPool{
			var qualifiedName:String = getQualifiedClassName(objectClass);
			if(!_instances[qualifiedName]){
				_instances[qualifiedName] = new ObjectPool(objectClass);
			} 
			return _instances[qualifiedName];
		}
	
		public function getNew():*
		{
			var object:* = null;
			if (_objects.length > 0)
				object = _objects.pop();
			else
				object = new _objectClass();
			return object;
		}
	
		public function disposeObject(OldObject:Object):void
		{
			_objects.push(OldObject);
		}
	}
}