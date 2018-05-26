package ro.ciacob.desktop.data {
	import flash.net.registerClassAlias;
	import flash.utils.ByteArray;
	import flash.utils.getQualifiedClassName;
	
	import mx.utils.ObjectUtil;
	
	import ro.ciacob.ciacob;
	import ro.ciacob.desktop.data.constants.DataKeys;
	import ro.ciacob.desktop.data.exporters.IExporter;
	import ro.ciacob.desktop.data.exporters.PlainObjectExporter;
	import ro.ciacob.utils.Arrays;
	import ro.ciacob.utils.ByteArrays;
	import ro.ciacob.utils.Objects;
	import ro.ciacob.utils.constants.CommonStrings;

	use namespace ciacob;

	/**
	 * This is a generic data model, very scalable, and covering a fairly
	 * large range of the real-world data storage requirements. This
	 * implementation provides you the ability to:
	 *
	 * <ul>
	 * 		<li>represent both flat and hierarchical data structures;</li>
	 *
	 * 		<li>define and load some default, hardcodded content into the structure;</li>
	 *
	 * 		<li>serialize/deserialize the content into a proprietary,
	 * 		<strong>built-in</strong> format;</li>
	 *
	 * 		<li>easily import/export the content from/into third party formats;</li>
	 *
	 * 		<li>optimize computationally intensive code by isolating changes,
	 * 		wherever applicable - e.g.: you get a <strong>specific notification</strong>
	 * 		that a child has been added or removed, as opposed to a generic notification
	 * 		that something has changed.</li>
	 * </ul>
	 *
	 * Note:
	 * This implementation relies on <code>IObserver</code> for registering and
	 * broadcasting notifications, instead of being an <code>IEventDispatcher</code>.
	 *
	 * @see IObserver
	 * @version 1.1
	 * @author Claudius Tiberiu Iacob
	 * @email claudius.iacob@gmail.com
	 *
	 * @author ciacob
	 */
	public class DataElement implements IDataElement {

		private static const DATA_ELEMENT_ALIAS:String = getQualifiedClassName(DataElement);

		private static const READONLY_KEYS:Array = [DataKeys.CHILDREN, DataKeys.CONTENT, DataKeys.
			INDEX, DataKeys.LEVEL, DataKeys.METADATA, DataKeys.PARENT, DataKeys.ROUTE, DataKeys.
			SOURCE];

		private static var _forcingNotification:Boolean;

		/**
		 * Default implementation for <code>IDataElement</code> - consult for more
		 * information.
		 *
		 * @param	initialMetadata
		 * 			Optional. Initial metadata to populate the element about to be created.
		 * 			Consult <code>PlainObjectImporter</code> for details about the
		 * 			expected data structure.
		 *
		 * @param	initialContent
		 * 			Optional. Initial content to populate the element about to be created.
		 * 			Consult <code>PlainObjectImporter</code> for details about the
		 * 			expected data structure.
		 *
		 * @see IDataElement
		 * @see ro.ciacob.desktop.data.importers.PlainObjectImporter
		 */
		public function DataElement(initialMetadata:Object = null, initialContent:Object =
			null) {
			//_observer = new Observer;
			if (initialMetadata != null) {
				_importInitialMetadata(initialMetadata);
			}
			if (initialContent != null) {
				_importInitialContent(initialContent);
			}
		}

//		public var _autoBroadcast:Boolean = true;
		public var _children:Array = [];
		public var _content:Object = {};
		public var _metadata:Object = {};
		//public var _observer:Observer;
		public var _ownFlatElementsMap:Object;

		/**
		 * @inheritDoc
		 */
		public function addDataChild(child:IDataElement):void {
			addDataChildAt(child, numDataChildren);
		}

		/**
		 * @inheritDoc
		 */
		public function addDataChildAt(child:IDataElement, atIndex:int):void {
			if (atIndex > numDataChildren) {
				throw(new Error('\nDataElement - addChildAt(): Cannot add a child at index ' +
					atIndex + '. Maximum allowed index is ' + numDataChildren + ', because the children list cannot be sparse.\n'));
			}
			var parentOfChild:IDataElement = child.dataParent;
			if (parentOfChild == this) {
				return;
			}
			if (parentOfChild != null) {
				parentOfChild.removeDataChild(child);
			}
			_children.splice(atIndex, 0, child);
			DataElement(child).setParent(this);
			resetIntrinsicMeta();
		}

		/**
		 * @inheritDoc
		 */
		public function get canHaveChildren():Boolean {
			return true;
		}

		/**
		 * Convenience method for quickly dupplicating an element.
		 * Cloned elements are orphaned (their `dataParent` field is `null`)
		 * and have identical (but unrelated, i.e., they point to different
		 * object instances) children to the original.

		 * @paramt	shallow
		 * 			If true, children of the element will be omitted from the
		 * 			cloned element. Default is false, which make children be
		 * 			includded.
		 *
		 * @return	A clone of this element.
		 */
		public function clone(shallow:Boolean = false):IDataElement {
//			var classDef:Class = Object(this).constructor;
//			var dupplicate:IDataElement = new classDef;
//			var serializedSelf:ByteArray = this.toSerialized();
//			dupplicate.fromSerialized(serializedSelf)
//			return dupplicate;
			
			return IDataElement (ByteArrays.cloneObject (this));
		}

		/**
		 * @inheritDoc
		 */
		public function get dataParent():IDataElement {
			if (DataKeys.PARENT in _metadata) {
				return _metadata[DataKeys.PARENT];
			}
			return null;
		}

		/**
		 * @inheritDoc
		 */
		public function empty():void {
			_children = [];
		}

		/**
		 * @inheritDoc
		 */
		public function exportToFormat(format:String, resources:* = null):* {
			throw(new Error('\nDataElement - exportToFormat(): You must implement this ' +
				'function by\noverriding it into your own subclass. Use either ' +
				'`getMetadata()`,\n`getContent()`, `getChildAt()`, or if you want the ' +
				'`toSerialized()`\nmethods to obtain the content that you\'ll then ' +
				'parse and export.\n'));
		}

		/**
		 * @inheritDoc
		 */
		public function fromSerialized(serialized:ByteArray):void {
			_fromByteArray(ByteArray(serialized));
			resetIntrinsicMeta();
		}

		/**
		 * @inheritDoc
		 */
		public function getContent(key:String):* {
			return _content[key];
		}

		public function getContentKeys():Array {
			var keys:Array = Objects.getKeys(_content);
			keys.sort();
			return keys;
		}

		public function getContentMap():Object {
			return ObjectUtil.copy(_content);
		}

		/**
		 * @inheritDoc
		 */
		public function getDataChildAt(atIndex:int):IDataElement {
			return _children[atIndex] as IDataElement;
		}

		/**
		 * @inheritDoc
		 */
		public function getElementByRoute(route:String):IDataElement {
			return parentFlatElementsMap[route];
		}

		public function getMetaKeys():Array {
			return Objects.getKeys(_metadata);
		}

		/**
		 * @inheritDoc
		 */
		public function getMetadata(key:String):* {
			return _metadata[key];
		}

		/**
		 * Determines whether a certain key exists in the "content" map of an
		 * element.
		 *
		 * @param	keyName
		 * 			The key to look up.
		 *
		 * @return	True, if the key exists, either with a value set or not.
		 */
		public function hasContentKey(keyName:String):Boolean {
			if (keyName in _content) {
				return true;
			}
			return false;
		}

		/**
		 * Convenience batch job for setting content stored in a given object. A single `change notification`
		 * will be triggered when the batch is completed, and that only if specifically requested.
		 *
		 * @param	content
		 * 			The object to import from.
		 *
		 * @param	overwrite
		 * 			Whether to overwrite existing keys (true, default), or skip them.
		 *
		 * @param	notifyWhenDone
		 * 			Whether to dispatch a notification when importing is done (dispatched, anyway,
		 * 			only if any changes actually took place). Defaults to false.
		 */
		public function importContent(content:Object, overwrite:Boolean = true, notifyWhenDone:Boolean =
			false):void {
			var madeChanges:Boolean = false;
			for (var key:String in content) {
				var value:Object = content[key];
				if (!(key in _content) || overwrite) {
					_content[key] = value;
					madeChanges = true;
				}
			}
			if (madeChanges && notifyWhenDone) {
				triggerNotification();
			}
		}

		/**
		 * @inheritDoc
		 */
		public function importFromFormat(format:String, content:*):void {
			throw(new Error('\nDataElement - importFromFormat(): You must implement this function by\noverriding it into your own subclass. Use `setContent()`,\n`addChild()`, `addChildAt()` to bring the data into the current\nelement after you imported and parsed it.\n'));
		}

		/**
		 * @inheritDoc
		 */
		public function get index():int {
			if (DataKeys.INDEX in _metadata) {
				return _metadata[DataKeys.INDEX];
			}
			return -1;
		}

		/**
		 * Tests for equality this element to another one. The two will be equal if:
		 * - they point to the same instance, OR;
		 * - their serialized form is identical.
		 *
		 * @param	otherElement
		 * 			An element to test for equality
		 *
		 * @return	True if elements are equal, false otherwise.
		 */
		public function isEqualTo(otherElement:IDataElement):Boolean {
			if (otherElement === this) {
				return true;
			}
			var exporter:IExporter = new PlainObjectExporter;
			var selfAsObject:Object = exporter.export(this);
			var otherAsObject:Object = exporter.export(otherElement);
			return (ObjectUtil.compare(selfAsObject, otherAsObject) == 0);
		}

		/**
		 * @inheritDoc
		 */
		public function isEquivalentTo(otherElement:IDataElement):Boolean {
			var ownKeys:Array = getContentKeys();
			var testKeys:Array = otherElement.getContentKeys();
			return Arrays.sortAndTestForIdenticPrimitives(ownKeys, testKeys);
		}

//		public function isObserving(changeType:String):Boolean {
//			return _observer.isObserving(changeType);
//		}

		/**
		 * @inheritDoc
		 */
		public function get level():int {
			if (DataKeys.LEVEL in _metadata) {
				return _metadata[DataKeys.LEVEL];
			}
			return -1;
		}

		/**
		 * @inheritDoc
		 */
//		public function notifyChange (changeType:String, ... details):void {
//			details.unshift(changeType);
//			if (_autoBroadcast || _forcingNotification) {
//				
//				// Broadcast on current level
//				_observer.notifyChange.apply(this, details);
//				
//				// Broadcast on higher levels
//				var parentElement:IDataElement = this.dataParent;
//				while (parentElement != null) {
//					parentElement.notifyChange.apply(parentElement, details);
//					parentElement = parentElement.dataParent;
//				}
//			}
//		}

		/**
		 * @inheritDoc
		 */
		public function get numDataChildren():int {
			return _children.length;
		}

		/**
		 * @inheritDoc
		 */
//		public function observe(changeType:String, callback:Function):void {
//			_observer.observe(changeType, callback);
//		}

		/**
		 * @inheritDoc
		 */
		public function populateWithDefaultData(details:* = null):void {
			throw(new Error('\nDataElement - populateWithDefaultContent(): You must implement this\nfunction by overriding it into your own subclass. Use `setContent()`,\n`addChild()`, `addChildAt()` to bring your default data into the\ncurrent element.\n'));
		}


		/**
		 * Unsets a key's value and removes the key altogether.
		 * TODO: add this to the IDataElement interface.
		 *
		 * @param	key
		 * 			The key to remove content of.
		 */
		public function removeContent(key:String, notify:Boolean = false):void {
			if (key in _content) {
				_content[key] = null;
				delete _content[key];
			}
			if (notify) {
				triggerNotification();
			}
		}

		/**
		 * @inheritDoc
		 */
		public function removeDataChild(child:IDataElement):void {
			var childIndex:int = _children.indexOf(child);
			if (childIndex == -1) {
				throw(new Error('\nDataElement - removeChild(): child set to be removed is not a child of this element.\n'));
			}
			delete parentFlatElementsMap[child.route];
			DataElement(child).setIndex(-1);
			DataElement(child).setParent(null);
			DataElement(child).setIntrinsicMetadata(DataKeys.LEVEL, -1);
			DataElement(child).setIntrinsicMetadata(DataKeys.ROUTE, '-1');
			_children.splice(childIndex, 1);
			resetIntrinsicMeta();
		}

		/**
		 * @inheritDoc
		 */
		public function removeDataChildAt(atIndex:int):void {
			var child:IDataElement = IDataElement(_children[atIndex]);
			removeDataChild(child);
		}

		/**
		 * @inheritDoc
		 */
		public function get route():String {
			if (DataKeys.ROUTE in _metadata) {
				return _metadata[DataKeys.ROUTE];
			}
			return null;
		}

		/**
		 * When set to false, notifications to the outer world will not be sent
		 * as the DataElement gets modified. Use `triggerNotification()` as an
		 * alternative.
		 *
		 */
//		public function setAutoBroadcastMode(mode:Boolean):void {
//			_autoBroadcast = mode;
//		}

//		public function getAutoBroadcastMode() : Boolean {
//			return _autoBroadcast;
//		}

		/**
		 * @inheritDoc
		 */
		public function setContent(key:String, content:*):void {
			if (Objects.hasCustomType(content)) {
				throw(new Error('\nDataElement - setContent(): you can only set primitives, arrays or simple objects, nested to any level.\n'));
			}
			_content[key] = content;
		}

		public function setMetadata(key:String, metadata:*):void {
			if (READONLY_KEYS.indexOf(key) == -1) {
				_metadata[key] = metadata;
				resetIntrinsicMeta();
			}
		}

		/**
		 * @inheritDoc
		 */
//		public function stopObserving(changeType:String = null, callback:Function = null):void {
//			_observer.stopObserving(changeType, callback);
//		}

		/**
		 * @inheritDoc
		 */
		public function toSerialized():ByteArray {
			return _toByteArray();
		}

		/**
		 * @inheritDoc
		 */
		public function toString():String {
			return ('').concat('[', getQualifiedClassName(this), '] [', route, ']');
		}

		/**
		 * Useful to manually trigger a notification when `autoBroadcast` is set
		 * to false.
		 */
		public function triggerNotification():void {
			_forcingNotification = true;
			_forcingNotification = false;
		}

		/**
		 * @inheritDoc
		 */
		public function walk(callback:Function):void {
			if (callback != null) {
				callback.apply({}, [this]);
			}
			for (var i:int = 0; i < numDataChildren; i++) {
				var child:IDataElement = getDataChildAt(i);
				child.walk(callback);
			}
		}

		/**
		 * @private
		 */
		ciacob function getChildIndex(child:DataElement):int {
			if (numDataChildren == 0) {
				return -1;
			}
			return _children.indexOf(child);
		}

		/**
		 * Holds a flat (i.e., not hierarchical) map of all children of this element,
		 * includding the element itself. This aims to speed up searching elements by
		 * their route.
		 */
		ciacob function get parentFlatElementsMap():Object {
			if (dataParent != null) {
				return DataElement(dataParent).parentFlatElementsMap;
			}
			if (_ownFlatElementsMap == null) {
				_ownFlatElementsMap = {};
			}
			return _ownFlatElementsMap;
		}

		/**
		 * @private
		 */
		ciacob function resetIntrinsicMeta():void {

			if (this.dataParent != null) {
				
				// Index
				setIndex(DataElement(dataParent).getChildIndex(this));
				
				// Route
				var myRoute : String = DataElement(dataParent).route.concat(CommonStrings.UNDERSCORE, this.index);	
				setIntrinsicMetadata(DataKeys.ROUTE, myRoute);
				
				// Level
				var routeSegments:Array = myRoute.split(CommonStrings.UNDERSCORE);
				setIntrinsicMetadata(DataKeys.LEVEL, routeSegments.length - 1);
			} else {
				setIndex(-1);
				setIntrinsicMetadata(DataKeys.ROUTE, -1);
				setIntrinsicMetadata(DataKeys.LEVEL, 0);
			}
			parentFlatElementsMap[route] = this;
			for (var i:int = 0; i < numDataChildren; i++) {
				var child:DataElement = DataElement(_children[i]);
				child.resetIntrinsicMeta();
			}
		}

		/**
		 * @private
		 */
		ciacob function setIndex(newIndex:int):void {
			setIntrinsicMetadata(DataKeys.INDEX, newIndex);
		}

		/**
		 * @private
		 */
		ciacob function setIntrinsicMetadata(key:String, metadata:*):void {
			_metadata[key] = metadata;
		}

		/**
		 * @private
		 */
		ciacob function setParent(newParent:IDataElement):void {
			setIntrinsicMetadata(DataKeys.PARENT, newParent);
		}

		/**
		 * Sets content without triggering any notification at all, not even the intrinsic
		 * ones. Especially suitable in loops, provided that "triggerNotification" is manually
		 * called at some point later, so the outer world does eventually know that something
		 * has been changed.
		 *
		 * Note:
		 * Having "resetIntrinsicMeta()" blindly be called in each and every run of "notifyChange"
		 * was a dreadful, and costly decision. There is no reason, for example, to reset index,
		 * level and route, when only the content of the object changes. This, and similar
		 * issues, call for a major re-engineering of this class.
		 */
		ciacob function silentlySetContent(key:String, content:*):void {
			_content[key] = content;
		}
		
		/**
		 * Sets metadata without triggering any notification at all, not even the intrinsic
		 * ones. See above.
		 */
		ciacob function silentlySetMetadata(key:String, meta:*):void {
			_metadata[key] = meta;
		}
		
		/**
		 * Convenience way to get a hold of the root, from any leaf note that is connected to it.
		 * Orphaned elements will return `null`.
		 */
		ciacob function get root () : IDataElement {
			return (parentFlatElementsMap['-1'] as IDataElement);
		}

		private function _fromByteArray(byteArray:ByteArray, recurse:Boolean = true, mustCreate:Boolean =
			false):IDataElement {
			var cls:Class = Object(this).constructor;
			var fqn:String = getQualifiedClassName(this);
			var target:IDataElement = mustCreate ? (new cls as IDataElement) : this;
			byteArray.uncompress();
			byteArray.position = 0;
			registerClassAlias(fqn, cls);
			var srcData:Object = byteArray.readObject();
			if (Objects.isEmpty(srcData)) {
				throw(new Error(fqn + '\n - fromByteArray(): deserializing given ByteArray produced an empty Object.\n'));
			}
			var srcMetadata:Object = srcData[DataKeys.METADATA];
			for (var metaKey:String in srcMetadata) {
				DataElement(target).setIntrinsicMetadata(metaKey, srcMetadata[metaKey]);
			}
			var srcContent:Object = srcData[DataKeys.CONTENT];
			for (var contentKey:String in srcContent) {
				target.setContent(contentKey, srcContent[contentKey]);
			}
			if (recurse) {
				var childrenList:Array = srcData[DataKeys.CHILDREN];
				for (var i:int = 0; i < childrenList.length; i++) {
					var serializedChild:ByteArray = childrenList[i] as ByteArray;
					var child:IDataElement = _fromByteArray(serializedChild, true, true);
					target.addDataChild(child);
				}
			}
			return target;
		}

		private function _importInitialContent(content:Object):void {
			for (var srcContentKey:String in content) {
				_content[srcContentKey] = content[srcContentKey];
			}
		}

		private function _importInitialMetadata(metadata:Object):void {
			for (var srcMetaKey:String in metadata) {
				_metadata[srcMetaKey] = metadata[srcMetaKey];
			}
		}

		private function _toByteArray(recurse:Boolean = true):ByteArray {
			var srcData:Object = {};
			srcData[DataKeys.METADATA] = ObjectUtil.copy(_metadata);
			delete srcData[DataKeys.METADATA][DataKeys.PARENT];
			delete srcData[DataKeys.METADATA][DataKeys.INDEX];
			delete srcData[DataKeys.METADATA][DataKeys.LEVEL];
			delete srcData[DataKeys.METADATA][DataKeys.ROUTE];
			srcData[DataKeys.CONTENT] = ObjectUtil.copy(_content);
			srcData[DataKeys.CHILDREN] = [];
			if (recurse) {
				var srcChildren:Array = _children.concat();
				for (var j:int = 0; j < srcChildren.length; j++) {
					var childItem:DataElement = DataElement(srcChildren[j]);
					var childItemSerialized:ByteArray = childItem._toByteArray(true);
					srcData['children'][j] = childItemSerialized;
				}
			}
			var byteArray:ByteArray = new ByteArray;
			registerClassAlias(DATA_ELEMENT_ALIAS, DataElement);
			byteArray.writeObject(srcData);
			byteArray.compress();
			return byteArray;
		}
	}
}
