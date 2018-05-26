package ro.ciacob.desktop.data {
	import flash.utils.ByteArray;

	public interface IDataElement {

		/**

		 */
		function addDataChild(child:IDataElement):void;

		/**

		 */
		function addDataChildAt(child:IDataElement, atIndex:int):void;

		/**

		 */
		function get canHaveChildren():Boolean;

		/**

		 */
		function get dataParent():IDataElement;

		/**

		 */
		function empty():void;

		/**

		 */
		function exportToFormat(format:String, resources:* = null):*;

		/**

		 */
		function fromSerialized(serialized:ByteArray):void;

		/**

		 */
		function getContent(key:String):*;


		function getContentKeys():Array;


		function getContentMap():Object;


		function getDataChildAt(childIndex:int):IDataElement;


		function getElementByRoute(route:String):IDataElement;


		function getMetaKeys():Array;


		function getMetadata(key:String):*;

		/**

		 */
		function hasContentKey(keyName:String):Boolean;

		/**

		 */
		function importFromFormat(format:String, content:*):void;

		/**

		 */
		function get index():int;

		/**

		 */
		function get level():int;

		/**
		 * 
		 */
		function get numDataChildren():int;

		/**

		 */
		function populateWithDefaultData(details:* = null):void;

		/**

		 */
		function removeDataChild(child:IDataElement):void;

		/**

		 */
		function removeDataChildAt(atIndex:int):void;

		/**

		 */
		function get route():String;

		/**

		 */
		function setContent(key:String, content:*):void;


		/**

		 */
		function setMetadata(key:String, metadata:*):void;


		function toSerialized():ByteArray;

		/**
		 * Walks the element's tree of children, calling a given callback function on each
		 * one. The function will receive the <code>IDataElement</code> child as its lone
		 * argument.
		 */
		function walk(callback:Function):void;
		
		/**
		 * Tests for equality this element to another one. The two will be equal if:
		 * - they point to the same instance; OR
		 * - their serialized form is identical, byte per byte.
		 * @param	otherElement
		 * 			An element to test for equality
		 * @return	True if elements are equal, false otherwise.
		 */
		function isEqualTo(otherElement:IDataElement):Boolean;
		
		/**

		 */
		function isEquivalentTo (otherElement:IDataElement):Boolean;
	}
}
