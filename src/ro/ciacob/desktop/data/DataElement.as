package ro.ciacob.desktop.data {
	import flash.net.registerClassAlias;
	import flash.utils.ByteArray;
	import flash.utils.getQualifiedClassName;
	
	import mx.utils.ObjectUtil;
	
	import ro.ciacob.desktop.data.constants.DataKeys;
	import ro.ciacob.desktop.data.exporters.IExporter;
	import ro.ciacob.desktop.data.exporters.PlainObjectExporter;
	import ro.ciacob.utils.Arrays;
	import ro.ciacob.utils.ByteArrays;
	import ro.ciacob.utils.Objects;
	import ro.ciacob.utils.constants.CommonStrings;

	/**
	 * This is a generic data model that provides one the ability to:
	 *
	 * 		- represent both flat and hierarchical data structures;
	 * 		- define and load some default, hardcodded content into the structure;
	 * 		- serialize/deserialize the content into a proprietary, built-in format;
	 * 		- hooks to import/export the content from/into third party formats;
	 *
	 * @version 1.2
	 * @author ciacob
	 * @author Claudius Tiberiu Iacob
	 * @email claudius.iacob@gmail.com
	 */
	public class DataElement {

		private static const DATA_ELEMENT_ALIAS:String = getQualifiedClassName(DataElement);

		private static const READONLY_KEYS:Array = [DataKeys.CHILDREN, DataKeys.CONTENT, DataKeys.
			INDEX, DataKeys.LEVEL, DataKeys.METADATA, DataKeys.PARENT, DataKeys.ROUTE, DataKeys.
			SOURCE];



		/**
		 * @constructor
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
		 */
		public function DataElement(initialMetadata:Object = null, initialContent:Object = null) {
			if (initialMetadata != null) {
				_importInitialMetadata(initialMetadata);
			}
			if (initialContent != null) {
				_importInitialContent(initialContent);
			}
		}

		public var _children:Array = [];
		public var _content:Object = {};
		public var _metadata:Object = {};
		public var _ownFlatElementsMap:Object;

		/**
		 * Adds the provided element as a last child. If it was
		 * previously parented by some other element, it is first deleted there. If it is
		 * already a child of this element, nothing happens.
		 *
		 * @param	child
		 * 			The child to be added.
		 */
		public function addDataChild(child:DataElement):void {
			addDataChildAt(child, numDataChildren);
		}

		/**
		 * Adds the provided child to this element at the specified index. If the child
		 * was previously parented by some other element, it is first deleted there.
		 * If it is already a child of this element, nothing happens.
		 *
		 * @param	child
		 * 			The child to be added.
		 * @param	index
		 * 			The index to add the child at, zero based. The list of children cannot
		 * 			be sparse. If `index` is equal to the current number of
		 * 			children, an extra position will be appended for the new child.
		 * 			If `index` is greater than the current number of children,
		 * 			an error will be thrown.
		 *
		 */
		public function addDataChildAt(child:DataElement, atIndex:int):void {
			if (atIndex > numDataChildren) {
				throw(new Error('\nDataElement - addChildAt(): Cannot add a child at index ' +
					atIndex + '. Maximum allowed index is ' + numDataChildren + ', because the children list cannot be sparse.\n'));
			}
			var parentOfChild:DataElement = child.dataParent;
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
		 * Determines whether this element is allowed to have children. Default
		 * implementation always returns `true`, override to customize.
		 */
		public function get canHaveChildren():Boolean {
			return true;
		}

		/**
		 * Convenience method for quickly dupplicating an element.
		 * Cloned elements are orphaned (their `dataParent` field is `null`)
		 * and have identical (but unrelated, i.e., they point to different
		 * object instances) children to the original.
		 *
		 * @return	A clone of this element.
		 */
		public function clone():DataElement {
			return DataElement (ByteArrays.cloneObject (this));
		}

		/**
		 * Returns the parent of this element, or null if it has none.
		 * Root and orphaned elements will return `null`.
		 */
		public function get dataParent():DataElement {
			if (DataKeys.PARENT in _metadata) {
				return _metadata[DataKeys.PARENT];
			}
			return null;
		}

		/**
		 * Convenience way for erasing all children.
		 */
		public function empty():void {
			_children = [];
		}

		/**
		 * The default implementation does nothing. Override to implement this method,
		 * the way that it exports the current element into some third-party format, at
		 * your discretion.
		 *
		 * @param	format
		 * 			A name for the third-party format you export into (e.g., XML, JSON, etc).
		 *
		 * @param	resources
		 * 			This is just a handy way of injecting whatever data or functionality
		 * 			you need into your function, at run-time.
		 *
		 * @return	The exported output. The precise format is discretionary to your
		 * 			implementation.
		 */
		public function exportToFormat(format:String, resources:* = null):* {
			throw (new Error ('DataElement - exportToFormat(): Not implemented. You can implement this function by overriding it in your subclass.'));
		}

		/**
		 * DEPRECATED. Use DataElement.fromSerialized() instead.
		 * Populates this element from a value previously returned by the `toSerialized()`
		 * method.
		 *
		 * @deprecated Use DataElement.fromSerialized() instead.
		 * 
		 * @param	serialized
		 * 			The serialized value to populate the element from.
		 */
		public function _legacy_fromSerialized(serialized:ByteArray):DataElement {
			var ret : DataElement = _legacy_fromByteArray(ByteArray(serialized));
			resetIntrinsicMeta();
			return ret;
		}

		/**
		 * Gets the content corresponding to the given key.
		 *
		 * @param	key
		 * 			The key corresponding to the content to retrieve.
		 *
		 * @return	The content corresponding to the given key, or null.
		 */
		public function getContent(key:String):* {
			return _content[key];
		}

		/**
		 * Gets all content keys available.
		 *
		 * @return	An array containing strings, one for each key registered in the
		 * 			content realm. Keys are returned in alphabetical order.
		 */
		public function getContentKeys():Array {
			var keys:Array = Objects.getKeys(_content);
			keys.sort();
			return keys;
		}

		/**
		 * Returns a copy of this element's content values, indexed by their respective
		 * keys, in a value object.
		 */
		public function getContentMap():Object {
			return ObjectUtil.copy(_content);
		}

		/**
		 * Returns the child currently found at the specified index, or null if no child
		 * exists there.
		 */
		public function getDataChildAt(atIndex:int):DataElement {
			return _children[atIndex] as DataElement;
		}

		/**
		 * Returns an element, given its `route` property. The lookup include all
		 * descendants of this element, and the element itself.
		 *
		 * @param	route
		 * 			The route of an element to look up;
		 *
		 * @return	The element with the matching route, or null if none is found.
		 */
		public function getElementByRoute(route:String):DataElement {
			return parentFlatElementsMap[route];
		}

		/**
		 * Gets all metadata keys available.
		 *
		 * @return	An array containing strings, one for each key registered in the
		 * 			metadata realm. Keys are retrieven in alphabetical order.
		 */
		public function getMetaKeys():Array {
			var keys : Array = Objects.getKeys(_metadata);
			keys.sort();
			return keys;
		}

		/**
		 * Gets the metadata corresponding to the given key.
		 *
		 * @param	key
		 * 			A Key corresponding to some metadata to retrieve.
		 *
		 * @return	The metadata corresponding to the given key, or null if none is found.
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
		 * @return	True, if the key exists, false otherwise.
		 */
		public function hasContentKey(keyName:String):Boolean {
			if (keyName in _content) {
				return true;
			}
			return false;
		}

		/**
		 * Convenience batch job for setting content stored in a given object.
		 *
		 * @param	content
		 * 			The object to import from.
		 *
		 * @param	overwrite
		 * 			Whether to overwrite existing keys (true, default), or skip them.
		 */
		public function importContent(content:Object, overwrite:Boolean = true):void {
			for (var key:String in content) {
				var value:Object = content[key];
				if (!(key in _content) || overwrite) {
					_content[key] = value;
				}
			}
		}

		/**
		 * The default implementation does nothing. Override to implement this method,
		 * the way that  it populates the current element with content it parses from some
		 * third-party format, at your discretion.
		 * 
		 * @param	format
		 * 			A name for the third-party format you import from (e.g., XML, JSON, etc);
		 *
		 * @param	content
		 * 			The content that is to be parsed and imported.
		 */
		public function importFromFormat(format:String, content:*):void {
			throw(new Error('DataElement - importFromFormat(): Not implemented. You can implement this function by overriding it in your subclass.'));
		}

		/**
		 * Returns the current index of this element within his parent children list. Root and orphaned elements return -1.
		 */
		public function get index():int {
			if (DataKeys.INDEX in _metadata) {
				return _metadata[DataKeys.INDEX];
			}
			return -1;
		}

		/**
		 * Tests this element for equality to another one. The two will be equal if:
		 * - they point to the same instance, OR;
		 * - by serializing both as Objects, the resulting Objects compare as equal by
		 *   `ObjectUtil.compare()`.
		 *
		 * @param	otherElement
		 * 			An element to test for equality
		 *
		 * @return	True if elements are equal, false otherwise.
		 */
		public function isEqualTo(otherElement:DataElement):Boolean {
			if (otherElement === this) {
				return true;
			}
			var exporter:IExporter = new PlainObjectExporter;
			var selfAsObject:Object = exporter.export(this);
			var otherAsObject:Object = exporter.export(otherElement);
			return (ObjectUtil.compare(selfAsObject, otherAsObject) == 0);
		}

		/**
		 * Checks whether this element has exactly the same set of keys as 
		 * another one.
		 * 
		 * @param	otherElement
		 * 			An element to test for equivalence
		 * 
 		 * @return	True if elements are equivalent, false otherwise.
		 */
		public function isEquivalentTo(otherElement:DataElement):Boolean {
			var ownKeys:Array = getContentKeys();
			var testKeys:Array = otherElement.getContentKeys();
			return Arrays.sortAndTestForIdenticPrimitives(ownKeys, testKeys);
		}

		/**
		 * Returns the current nesting level of this element. Root and orphaned
		 * elements return 0. The level reported can be `-1`, if no such
		 * information was ever stored on this element.
		 */
		public function get level():int {
			if (DataKeys.LEVEL in _metadata) {
				return _metadata[DataKeys.LEVEL];
			}
			return -1;
		}

		/**
		 * Returns the current number of children of this element.
		 */
		public function get numDataChildren():int {
			return _children.length;
		}

		/**
		 * The default implementation does nothing. Override to implement this method,
		 * the way that it populates the current element with some default content.
		 */
		public function populateWithDefaultData(details:* = null):void {
			throw (new Error ('DataElement - populateWithDefaultContent(): You can implement this function by overriding it in your subclass.'));
		}


		/**
		 * Unsets a key's value and removes the key altogether.
		 *
		 * @param	key
		 * 			The key to remove content of.
		 */
		public function removeContent(key:String):void {
			if (key in _content) {
				_content[key] = null;
				delete _content[key];
			}
		}

		/**
		 * Deletes the provided child, shifting the indexes of all subsequent children
		 * in the list, if any.
		 *
		 * @param	child
		 * 			The child to be deleted. If it is not a child of this implementor, an
		 * 			error will the thrown.
		 */
		public function removeDataChild(child:DataElement):void {
			var childIndex:int = _children.indexOf(child);
			if (childIndex == -1) {
				throw(new Error('DataElement - removeChild(): element set to be removed is not a child of this parent.'));
			}
			delete parentFlatElementsMap[child.route];
			DataElement(child).enforceIndex(-1);
			DataElement(child).setParent(null);
			DataElement(child).setIntrinsicMetadata(DataKeys.LEVEL, -1);
			DataElement(child).setIntrinsicMetadata(DataKeys.ROUTE, '-1');
			_children.splice(childIndex, 1);
			resetIntrinsicMeta();
		}

		/**
		 * Deletes the child found at the specified index, shifting the indexes of all subsequent
		 * children in the list, if any.
		 *
		 * @param	index
		 * 			The index to delete the child at, zero based. If no child is to be found
		 * 			at the supplied index, an error will be thrown.
		 */
		public function removeDataChildAt(atIndex:int):void {
			var child:DataElement = DataElement(_children[atIndex]);
			removeDataChild(child);
		}

		/**
		 * Builds and returns a `route` to this element, by concatenating the
		 * local `index` of each ancestor, in turn.
		 *
		 * For example: The string `-1_0_1_3` is the route to the fourth child
		 * of the second child of the first child of a parentless element (possibly the
		 * root).
		 *
		 * Root and orphaned elements return the string `-1`.
		 */
		public function get route():String {
			if (DataKeys.ROUTE in _metadata) {
				return _metadata[DataKeys.ROUTE];
			}
			return null;
		}

		/**
		 * Sets the content corresponding to the given key.
		 *
		 * @param	key
		 * 			A key to associate with the new content to set.
		 * 
		 * @param	content
		 * 			The new content to be set. Must be AMF3 serializable, or
		 * 			an error will be thrown.
		 */
		public function setContent (key:String, content : *) : void {
			if (Objects.hasCustomType(content)) {
				throw (new Error ('DataElement - setContent(): content is not AMF3 serializable. Try to use primitives.'));
			}
			_content[key] = content;
		}

		/**
		 * Sets the metadata corresponding to the given key.
		 *
		 * @param	key
		 * 			A Key corresponding to some metadata to set.
		 *
		 * @param	metadata
		 * 			A value to associate to the metadata being set.
		 */
		public function setMetadata (key:String, metadata:*):void {
			if (READONLY_KEYS.indexOf(key) == -1) {
				_metadata[key] = metadata;
				resetIntrinsicMeta();
			}
		}

		/**
		 * Serializes this element, using the built-in format. The resulting
		 * value can be fed back into the `fromSerialized()` method to re-create
		 * the same data structure.
		 *
		 * The default implementation uses a compressed `ByteArray` as a serialization 
		 * medium.
		 *
		 * @return	The serialized form of this element.
		 */
		public function toSerialized():ByteArray {
			var srcClass : Class = (this as Object).constructor;
			var srcAlias : String = getQualifiedClassName(srcClass);
			registerClassAlias(srcAlias, srcClass);
			var b:ByteArray = new ByteArray();
			b.writeObject(this);
			b.position = 0;
			b.compress();
			return b;
		}

		/**
		 * Returns the qualified class name and route of this element.
		 */
		public function toString():String {
			return ('').concat('[', getQualifiedClassName(this), '] [', route, ']');
		}

		/**
		 * Walks the element's tree of children, calling a given callback function on each
		 * one of them. The function will receive each child in turn as its sole argument.
		 */
		public function walk (callback:Function):void {
			if (callback != null) {
				callback.apply({}, [this]);
			}
			for (var i:int = 0; i < numDataChildren; i++) {
				var child:DataElement = getDataChildAt(i);
				child.walk(callback);
			}
		}

		/**
		 * Returns the `index` of the given element, provided it is a child of this one.
		 * Returns `-1` if the given element is not in this element's children list.
		 */
		public function getChildIndex(child:DataElement):int {
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
		public function get parentFlatElementsMap():Object {
			if (dataParent != null) {
				return DataElement(dataParent).parentFlatElementsMap;
			}
			if (_ownFlatElementsMap == null) {
				_ownFlatElementsMap = {};
			}
			return _ownFlatElementsMap;
		}

		/**
		 * Recursivelly rebuilds the `index`, `route` and `level` for this element and its
		 * descendants.
		 */
		public function resetIntrinsicMeta():void {

			if (this.dataParent != null) {
				
				// Index
				enforceIndex(DataElement(dataParent).getChildIndex(this));
				
				// Route
				var myRoute : String = DataElement(dataParent).route.concat(CommonStrings.UNDERSCORE, this.index);	
				setIntrinsicMetadata(DataKeys.ROUTE, myRoute);
				
				// Level
				var routeSegments:Array = myRoute.split(CommonStrings.UNDERSCORE);
				setIntrinsicMetadata(DataKeys.LEVEL, routeSegments.length - 1);
			} else {
				enforceIndex(-1);
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
		 * Sets the `index` of this element to the given value.
		 * 
		 * @param	An index to enforce on this element.
		 * 
		 * @param	doReorderSiblings
		 * 			Tells the parent to reorder its children so that the change in index becomes effective.
		 * 			Default false.
		 * 
		 * @param	sanitizeIndex
		 * 			Enforce legit boundaries on the given `newIndex` and avoids the situation where two children
		 * 			have the same index by shifting indices. Default false.
		 * 
		 * NOTE: despite the fact that both `doReorderSiblings` and `sanitizeIndex` should be TRUE to maintain data integrity
		 * at all time, they are FALSE by default for legacy reasons, this function being mostly used in loops (where the extra 
		 * checks incurs speed penalties). There is also a standalone `reorderSiblings()` function, that can be called after 
		 * indices are changed in batch. 
		 */
		public function enforceIndex (newIndex:int, doReorderSiblings : Boolean = false, sanitizeIndex : Boolean = false) : void {
			if (newIndex == index) {
				return;
			}
			if (sanitizeIndex) {
				
				// Ensure legit bounds
				if (newIndex < 0) {
					newIndex = 0;
				}
				if (dataParent) {
					if (newIndex > dataParent._children.length - 1) {
						newIndex = dataParent._children.length - 1;
					}
					
					// Shift indices if any overlapping occurs
					var shiftStep : int = ((newIndex - index) < 0)? 1 : ((newIndex - index) > 0)? -1 : 0;
					if (shiftStep) {
						var shiftStart : int = newIndex;
						var shiftEnd : int = index;
						if (dataParent._children[newIndex] !== undefined) {
							var i : int;
							var replacementIndex : int;
							
							// Shifting to left
							if (shiftStep > 0) {
								for (i = shiftStart; i < shiftEnd; i += shiftStep) {
									replacementIndex = (i + shiftStep);
									(dataParent._children[i] as DataElement).enforceIndex(replacementIndex);
								}
							}
							
							// Shifting to right
							else {
								for (i = shiftStart; i > shiftEnd; i += shiftStep) {
									replacementIndex = (i + shiftStep);
									(dataParent._children[i] as DataElement).enforceIndex(replacementIndex);
								}
							}
						}
					}
				}
			}
			setIntrinsicMetadata(DataKeys.INDEX, newIndex);
			if (doReorderSiblings) {
				reorderSiblings();
			}
		}
		
		/**
		 * Causes all the children of the parent of this element to be reordered based on their index.
		 */
		public function reorderSiblings () : void {
			if (dataParent) {
				dataParent._children.sort(_sortChildrenByIndex);
			}
		}

		/**
		 * Sets a metadata value, includding for reserved keys.
		 */
		public function setIntrinsicMetadata (key:String, metadata:*):void {
			_metadata[key] = metadata;
		}

		/**
		 * Sets the parent of this element to the given value.
		 */
		public function setParent(newParent:DataElement):void {
			setIntrinsicMetadata(DataKeys.PARENT, newParent);
		}
		
		/**
		 * Convenience way to get a hold of the root, from any leaf note that is connected to it.
		 * Orphaned elements will return `null`.
		 */
		public function get root () : DataElement {
			return (parentFlatElementsMap['-1'] as DataElement);
		}

		/**
		 * New, class agnostic method of producing a "live" instance from a serialized record. The serialization
		 * medium is the compressed ByteArray.
		 */
		public static function fromSerialized (serialized:ByteArray, cls : Class = null, fqn : String = null) : Object {
			if (cls && fqn) {
				registerClassAlias(fqn, cls);
			} else {
				registerClassAlias(DATA_ELEMENT_ALIAS, DataElement);
			}
			serialized.uncompress();
			serialized.position = 0;
			var srcData : Object = serialized.readObject() as Object;
			if (srcData is DataElement) {
				return srcData;
			}
			return null;
		}
		
		/*
		 * @deprecated
		 * TO BE REMOVED along with method `fromSerialized()`. Static method `DataElement.fromSerialized()` is to
		 * be used instead.
		 */
		private function _legacy_fromByteArray (byteArray:ByteArray, recurse:Boolean = true, mustCreate:Boolean = false):DataElement {
			var cls : Class = (this as Object).constructor;
			var fqn : String = getQualifiedClassName(cls);
			registerClassAlias(fqn, cls);
			try {
				byteArray.uncompress();
			} catch (e : Error) {
				// The byteArray might have already been uncompressed
			}
			byteArray.position = 0;
			var srcData : Object = byteArray.readObject();
			if (srcData is DataElement) {
				return srcData as DataElement;
			}
			var target:DataElement = mustCreate ? (new cls as DataElement) : this;
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
					var child:DataElement = _legacy_fromByteArray(serializedChild, true, true);
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
		
		private function _sortChildrenByIndex (childA : DataElement, childB : DataElement) : int {
			var a : int = childA.index;
			var b : int = childB.index;
			var ret : int = (a == -1 || b == -1)? 0 : a - b;
			return ret;
		}
	}
}
