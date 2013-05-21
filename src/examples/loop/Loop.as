package examples.loop 
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class Loop extends Sprite
	{
		
		private var _tasks:Array;
		private var	_tasknames:Array;
		
		public function Loop() 
		{
			_tasks = new Array();
			_tasknames = new Array();
			
			addEventListener(Event.ADDED_TO_STAGE, startUp);
			addEventListener(Event.REMOVED_FROM_STAGE, shutDown);
		}
		
		private function shutDown(e:Event):void 
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, shutDown);
			removeEventListener(Event.ENTER_FRAME, update);
		}
		
		private function startUp(e:Event):void 
		{
			addEventListener(Event.ENTER_FRAME, update);
			removeEventListener(Event.ADDED_TO_STAGE, startUp);
		}
	
		
		public function addTask(task:Function,taskID:String):void {
			_tasks.push(task);
			_tasknames.push(taskID);
		}
		public function removeTask(taskID:String):void {
			var target:int;
			
			for (var i:Number = _tasknames.length - 1; i >= 0; i--) {
				trace(taskID+"|"+taskID);
				if (_tasknames[i] == taskID) {
					trace("removing " + taskID + " at " + i);
					_tasks.splice(i, 1);
					_tasknames.splice(i, 1);	
				}
			}
			
			
			
		}
		
		private function update(e:Event):void {
			for (var i:Number = 0; i < _tasks.length; i++) {
				_tasks[i]();
				//trace(_tasknames[i]);
			}
		
		}
	}

}