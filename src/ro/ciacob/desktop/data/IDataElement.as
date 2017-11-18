package ro.ciacob.desktop.data {
	import flash.utils.ByteArray;
	
	import ro.ciacob.desktop.signals.IObserver;

	public interface IDataElement extends IObserver {

		/**
		 * Adds the provided <code>IDataElement</code> as a last child. If it was
		 * previously parented by some other element, it is first deleted there. If it is
		 * already a child of this element, nothing happens.
		 *
		 * <p>
		 * <strong>NOTE:</strong>
		 * Broadcasts an <code>IObserver</code> <strong>notification</strong> named
		 * <code>DataChangeDetail.MODEL_CONTENT_CHANGED</code>; the following parameters
		 * will be passed to any callback that registers to it:
		 * </p>
		 * <table class="innertable">
		 * 		<tr>
		 * 			<th> index </th>
		 * 			<th> type </th>
		 * 			<th> value </th>
		 * 		</tr>
		 * 		<tr>
		 * 			<td> 0 </td>
		 * 			<td> IDataElement </td>
		 * 			<td> The element broadcasting the notification.
		 * 				 <strong> Deprecated, set for removal. </strong>
		 * 			</td>
		 * 		</tr>
		 * 		<tr>
		 * 			<td> 1 </td>
		 * 			<td> IDataChangeDetail </td>
		 * 			<td> Values contained are:
		 * 				<ul>
		 * 					<li> IDataChangeDetail.changeType = DataChangeDetail.ADD </li>
		 * 					<li> IDataChangeDetail.changedElement = the child element </li>
		 * 					<li> IDataChangeDetail.originator = the parent element </li>
		 * 				</ul>
		 * 			</td>
		 * 		</tr>
		 * </table>
		 *
		 * @param	child
		 * 			The child to be added.
		 */
		function addDataChild(child:IDataElement):void;

		/**
		 * Adds the provided child to this element at the specified index. If the child
		 * was previously parented by some other element, it is first deleted there.
		 * If it is already a child of this element, nothing happens.
		 *
		 * <p>
		 * <strong>NOTE:</strong>
		 * Broadcasts an <code>IObserver</code> <strong>notification</strong> named
		 * <code>DataChangeDetail.MODEL_CONTENT_CHANGED</code>; the following parameters
		 * will be passed to any callback that registers to it:
		 * </p>
		 * <table class="innertable">
		 * 		<tr>
		 * 			<th> index </th>
		 * 			<th> type </th>
		 * 			<th> value </th>
		 * 		</tr>
		 * 		<tr>
		 * 			<td> 0 </td>
		 * 			<td> IDataElement </td>
		 * 			<td> The element broadcasting the notification.
		 * 				 <strong> Deprecated, set for removal. </strong>
		 * 			</td>
		 * 		</tr>
		 * 		<tr>
		 * 			<td> 1 </td>
		 * 			<td> IDataChangeDetail </td>
		 * 			<td> Values contained are:
		 * 				<ul>
		 * 					<li> IDataChangeDetail.changeType = DataChangeDetail.ADD </li>
		 * 					<li> IDataChangeDetail.changedElement = the child element </li>
		 * 					<li> IDataChangeDetail.originator = the parent element </li>
		 * 				</ul>
		 * 			</td>
		 * 		</tr>
		 * </table>
		 *
		 * @param	child
		 * 			The child to be added.
		 * @param	index
		 * 			The index to add the child at, zero based. The list of children cannot
		 * 			be sparse. If <code>index</code> is equal to the current number of
		 * 			children, an extra position will be appended for the new child.
		 * 			If <code>index</code> is greater than the current number of children,
		 * 			an error will be thrown.
		 *
		 */
		function addDataChildAt(child:IDataElement, atIndex:int):void;

		/**
		 * Determines whether this element is allowed to have children. Default
		 * implementation always returns <code>true</code>, override to customize.
		 *
		 * Returns <code>true</code>, if this implementor is allowed to have children,
		 * <code>false</code> otherwise.
		 */
		function get canHaveChildren():Boolean;

		/**
		 * Returns the parent of this element, or null if it has none. This is also
		 * accessible as a metadata, via <code>getMetadata (DataKeys.PARENT)</code>.
		 *
		 * Root and orphaned elements will return <code>null</code>.
		 */
		function get dataParent():IDataElement;

		/**
		 * Convenience way for erasing all children (metadata and content stay, though).
		 *
		 * <p>
		 * <strong>NOTE:</strong>
		 * Broadcasts an <code>IObserver</code> <strong>notification</strong> named
		 * <code>DataChangeDetail.MODEL_CONTENT_CHANGED</code>; the following parameters
		 * will be passed to any callback that registers to it:
		 * </p>
		 * <table class="innertable">
		 * 		<tr>
		 * 			<th> index </th>
		 * 			<th> type </th>
		 * 			<th> value </th>
		 * 		</tr>
		 * 		<tr>
		 * 			<td> 0 </td>
		 * 			<td> IDataElement </td>
		 * 			<td> The element broadcasting the notification.
		 * 				 <strong> Deprecated, set for removal. </strong>
		 * 			</td>
		 * 		</tr>
		 * 		<tr>
		 * 			<td> 1 </td>
		 * 			<td> IDataChangeDetail </td>
		 * 			<td> Values contained are:
		 * 				<ul>
		 * 					<li> IDataChangeDetail.changeType = DataChangeDetail.REFRESH </li>
		 * 					<li> IDataChangeDetail.changedElement = null </li>
		 * 					<li> IDataChangeDetail.originator = the parent element </li>
		 * 				</ul>
		 * 			</td>
		 * 		</tr>
		 * </table>
		 *
		 */
		function empty():void;

		/**
		 * This method is a placeholder and implementing it is purely optional.
		 * <strong>The default implementation leaves this method out.</strong>
		 * You are responsible for implementing this method, the way that it exports
		 * the current element into some <strong>third-party</strong> format, at
		 * your discretion.
		 *
		 * If you are looking for a way of exporting this element into its
		 * <strong>built-in</strong>, serialized format, use the
		 * <code>toSerialized()</code> method, instead.
		 *
		 * @param	format
		 * 			A name for the third-party format you export into. This could allow
		 * 			this function to handle multiple formats (e.g., XML and JSON).
		 *
		 * @param	resources
		 * 			This is just a handy way of sending whatever data or functionality
		 * 			you need, into your function, <em>at run-time</em>.
		 *
		 * @return	The exported output. The precise format is discretionary to your
		 * 			implementation.
		 */
		function exportToFormat(format:String, resources:* = null):*;

		/**
		 * Populates this element from a value previously returned by the
		 * <code>toSerialized()</code> method. That method uses the element's
		 * <strong>built-in</strong> serialized format, to recursively store its metadata,
		 * content and children.
		 *
		 * The default implementation uses a compressed <code>ByteArray</code> as a
		 * serialization medium.
		 *
		 * @param	serialized
		 * 			Some serialized value to populate the element from.
		 *
		 * <p>
		 * <strong>NOTE:</strong>
		 * Broadcasts an <code>IObserver</code> <strong>notification</strong> named
		 * <code>DataChangeDetail.MODEL_CONTENT_CHANGED</code>; the following parameters
		 * will be passed to any callback that registers to it:
		 * </p>
		 * <table class="innertable">
		 * 		<tr>
		 * 			<th> index </th>
		 * 			<th> type </th>
		 * 			<th> value </th>
		 * 		</tr>
		 * 		<tr>
		 * 			<td> 0 </td>
		 * 			<td> IDataElement </td>
		 * 			<td> The element broadcasting the notification.
		 * 				 <strong> Deprecated, set for removal. </strong>
		 * 			</td>
		 * 		</tr>
		 * 		<tr>
		 * 			<td> 1 </td>
		 * 			<td> IDataChangeDetail </td>
		 * 			<td> Values contained are:
		 * 				<ul>
		 * 					<li> IDataChangeDetail.changeType = DataChangeDetail.REFRESH </li>
		 * 					<li> IDataChangeDetail.changedElement = null </li>
		 * 					<li> IDataChangeDetail.originator = the parent element </li>
		 * 				</ul>
		 * 			</td>
		 * 		</tr>
		 * </table>
		 */
		function fromSerialized(serialized:ByteArray):void;

		/**
		 * Gets the content corresponding to the given key.
		 *
		 * NOTE:
		 * Both <em>metadata</em> and <em>content</em> associate values with elements,
		 * however, <em>content</em> is intended to be extrinsic to elements.
		 *
		 * @param	key
		 * 			A key corresponding to some content to retrieve.
		 *
		 * @return	The content corresponding to the given key, or null.
		 */
		function getContent(key:String):*;

		/**
		 * Gets all content keys available.
		 *
		 * NOTE:
		 * Keys are retrieven in no particular order.
		 *
		 * @return	An array containing strings, one for each key registered in the
		 * 			content realm.
		 */
		function getContentKeys():Array;

		/**
		 * Returns a copy of this element's content values, indexed by their respective
		 * keys, in a value object.
		 * @return
		 */
		function getContentMap():Object;

		/**
		 * Returns the child currently found at the specified index, or null if no child
		 * is to be found there.
		 */
		function getDataChildAt(childIndex:int):IDataElement;

		/**
		 * Returns an element instance, given its route property. The lookup include
		 * all childrens of this element, and the element itself.
		 *
		 * @param	route
		 * 			The route of an element to loo up (see `get route`);
		 *
		 * @return	The element with the matching route, or null if none
		 * 			is to be found.
		 */
		function getElementByRoute(route:String):IDataElement;

		/**
		 * Gets all metadata keys available.
		 *
		 * NOTE:
		 * Keys are retrieven in no particular order.
		 *
		 * @return	An array containing strings, one for each key registered in the
		 * 			metadata realm.
		 */
		function getMetaKeys():Array;

		/**
		 * Gets the metadata corresponding to the given key.
		 *
		 * NOTE:
		 * Both <em>metadata</em> and <em>content</em> associate values with elements,
		 * however, <em>metadata</em> is intended to be intrinsic to elements.
		 *
		 * @param	key
		 * 			A Key corresponding to some metadata to retrieve.
		 *
		 * @return	The metadata corresponding to the given key, or null.
		 */
		function getMetadata(key:String):*;

		/**
		 * Determines whether a certain key exists in the "content" map of an
		 * element.
		 *
		 * @param	keyName
		 * 			The key to look up.
		 *
		 * @return	True, if the key exists, either with a value set or not.
		 */
		function hasContentKey(keyName:String):Boolean;

		/**
		 * This method is a placeholder and implementing it is purely optional.
		 * <strong>The default implementation leaves this method out.</strong>
		 * You are responsible for implementing this method, the way that it populates
		 * the current element with content it parses from some
		 * <strong>third-party</strong> format.
		 *
		 * If you are looking for a way of importing back the content you previously
		 * exported via <code>toSerialized()</code> &amp;mdash; which uses the serialization
		 * <strong>built-into</strong> this element &amp;mdash; use
		 * <code>fromSerialized()</code>, instead.
		 *
		 * @see fromSerialized()
		 *
		 * @param	format
		 * 			A name for the third-party format you import from. This could allow
		 * 			this function to handle multiple formats (e.g., XML and JSON).
		 *
		 * @param	content
		 * 			The content that is to be parsed and imported.
		 *
		 * <p>
		 * <strong>NOTE:</strong>
		 * Broadcasts an <code>IObserver</code> <strong>notification</strong> named
		 * <code>DataChangeDetail.MODEL_CONTENT_CHANGED</code>; the following parameters
		 * will be passed to any callback that registers to it:
		 * </p>
		 * <table class="innertable">
		 * 		<tr>
		 * 			<th> index </th>
		 * 			<th> type </th>
		 * 			<th> value </th>
		 * 		</tr>
		 * 		<tr>
		 * 			<td> 0 </td>
		 * 			<td> IDataElement </td>
		 * 			<td> The element broadcasting the notification.
		 * 				 <strong> Deprecated, set for removal. </strong>
		 * 			</td>
		 * 		</tr>
		 * 		<tr>
		 * 			<td> 1 </td>
		 * 			<td> IDataChangeDetail </td>
		 * 			<td> Values contained are:
		 * 				<ul>
		 * 					<li> IDataChangeDetail.changeType = DataChangeDetail.REFRESH </li>
		 * 					<li> IDataChangeDetail.changedElement = null </li>
		 * 					<li> IDataChangeDetail.originator = the parent element </li>
		 * 				</ul>
		 * 			</td>
		 * 		</tr>
		 * </table>
		 */
		function importFromFormat(format:String, content:*):void;

		/**
		 * Returns the current index of this element within his parent children list.
		 * This is also accessible as a metadata, via
		 * <code>getMetadata(DataKeys.INDEX)</code>.
		 *
		 * Root and orphaned elements will return -1.
		 */
		function get index():int;

		/**
		 * Returns the current nesting level of this element. Root and orphaned
		 * elements will be in level 0. This is also accessible as a metadata, via
		 * <code>getMetadata(DataKeys.LEVEL)</code>.
		 *
		 * Root and orphaned elements will return 0. The level reported will be -1,
		 * if it could not be computed (i.e., some error occured).
		 */
		function get level():int;

		/**
		 * Returns the current number of children of this element.
		 */
		function get numDataChildren():int;

		/**
		 * This method is a placeholder and implementing it is purely optional.
		 * <strong>The default implementation leaves this method out.</strong>
		 * You are responsible for implementing this method, the way that it populates
		 * the current element with some default, possibly hardcoded content.
		 *
		 *
		 * @param	details
		 * 			Optional. You can use this argument to finely tune the process.
		 * 			For instance, depending on the argument, you could generate diferent
		 * 			default content.
		 *
		 * <p>
		 * <strong>NOTE:</strong>
		 * Broadcasts an <code>IObserver</code> <strong>notification</strong> named
		 * <code>DataChangeDetail.MODEL_CONTENT_CHANGED</code>; the following parameters
		 * will be passed to any callback that registers to it:
		 * </p>
		 * <table class="innertable">
		 * 		<tr>
		 * 			<th> index </th>
		 * 			<th> type </th>
		 * 			<th> value </th>
		 * 		</tr>
		 * 		<tr>
		 * 			<td> 0 </td>
		 * 			<td> IDataElement </td>
		 * 			<td> The element broadcasting the notification.
		 * 				 <strong> Deprecated, set for removal. </strong>
		 * 			</td>
		 * 		</tr>
		 * 		<tr>
		 * 			<td> 1 </td>
		 * 			<td> IDataChangeDetail </td>
		 * 			<td> Values contained are:
		 * 				<ul>
		 * 					<li> IDataChangeDetail.changeType = DataChangeDetail.REFRESH </li>
		 * 					<li> IDataChangeDetail.changedElement = null </li>
		 * 					<li> IDataChangeDetail.originator = the parent element </li>
		 * 				</ul>
		 * 			</td>
		 * 		</tr>
		 * </table>
		 */
		function populateWithDefaultData(details:* = null):void;

		/**
		 * Deletes the provided child, un-shifting the indexes of all subsequent children
		 * in the list, if any.
		 *
		 * @param	child
		 * 			The child to be deleted. If it is not a child of this implementor, an
		 * 			error will the thrown.
		 *
		 * <p>
		 * <strong>NOTE:</strong>
		 * Broadcasts an <code>IObserver</code> <strong>notification</strong> named
		 * <code>DataChangeDetail.MODEL_CONTENT_CHANGED</code>; the following parameters
		 * will be passed to any callback that registers to it:
		 * </p>
		 * <table class="innertable">
		 * 		<tr>
		 * 			<th> index </th>
		 * 			<th> type </th>
		 * 			<th> value </th>
		 * 		</tr>
		 * 		<tr>
		 * 			<td> 0 </td>
		 * 			<td> IDataElement </td>
		 * 			<td> The element broadcasting the notification.
		 * 				 <strong> Deprecated, set for removal. </strong>
		 * 			</td>
		 * 		</tr>
		 * 		<tr>
		 * 			<td> 1 </td>
		 * 			<td> IDataChangeDetail </td>
		 * 			<td> Values contained are:
		 * 				<ul>
		 * 					<li> IDataChangeDetail.changeType = DataChangeDetail.REMOVE </li>
		 * 					<li> IDataChangeDetail.changedElement = the child deleted </li>
		 * 					<li> IDataChangeDetail.originator = the parent element </li>
		 * 				</ul>
		 * 			</td>
		 * 		</tr>
		 * </table>
		 */
		function removeDataChild(child:IDataElement):void;

		/**
		 * Deletes the child to be found at the specified index, un-shifting the indexes
		 * of all subsequent children in the list, if any.
		 *
		 * @param	child
		 * 			The child to be deleted.
		 *
		 * @param	index
		 * 			The index to delete a child at, zero based. If no child is to be found
		 * 			at the supplied index, an error will be thrown.
		 *
		 * <p>
		 * <strong>NOTE:</strong>
		 * Broadcasts an <code>IObserver</code> <strong>notification</strong> named
		 * <code>DataChangeDetail.MODEL_CONTENT_CHANGED</code>; the following parameters
		 * will be passed to any callback that registers to it:
		 * </p>
		 * <table class="innertable">
		 * 		<tr>
		 * 			<th> index </th>
		 * 			<th> type </th>
		 * 			<th> value </th>
		 * 		</tr>
		 * 		<tr>
		 * 			<td> 0 </td>
		 * 			<td> IDataElement </td>
		 * 			<td> The element broadcasting the notification.
		 * 				 <strong> Deprecated, set for removal. </strong>
		 * 			</td>
		 * 		</tr>
		 * 		<tr>
		 * 			<td> 1 </td>
		 * 			<td> IDataChangeDetail </td>
		 * 			<td> Values contained are:
		 * 				<ul>
		 * 					<li> IDataChangeDetail.changeType = DataChangeDetail.REMOVE </li>
		 * 					<li> IDataChangeDetail.changedElement = the child deleted </li>
		 * 					<li> IDataChangeDetail.originator = the parent element </li>
		 * 				</ul>
		 * 			</td>
		 * 		</tr>
		 * </table>
		 */
		function removeDataChildAt(atIndex:int):void;

		/**
		 * Builds and returns a <em>route</em> to this element, by concatenating the
		 * local <code>index</code> of each ancestor, in turn.
		 *
		 * For example: The string <code>-1_0_1_3</code> is the route to the fourth child
		 * of the second child of the first child of a parentless element (possibly the
		 * root).
		 *
		 * This is also accessible as a metadata, via
		 * <code>getMetadata(DataKeys.ROUTE)</code>.
		 *
		 * Root and orphaned elements will return the string "-1".
		 */
		function get route():String;

		/**
		 * Sets the content corresponding to the given key.
		 *
		 * @param	key
		 * 			A key to associate with the new content to set.
		 * @param	content
		 * 			The new content to be set.
		 *
		 * <p>
		 * <strong>NOTE:</strong>
		 * Broadcasts an <code>IObserver</code> <strong>notification</strong> named
		 * <code>DataChangeDetail.MODEL_CONTENT_CHANGED</code>; the following parameters
		 * will be passed to any callback that registers to it:
		 * </p>
		 * <table class="innertable">
		 * 		<tr>
		 * 			<th> index </th>
		 * 			<th> type </th>
		 * 			<th> value </th>
		 * 		</tr>
		 * 		<tr>
		 * 			<td> 0 </td>
		 * 			<td> IDataElement </td>
		 * 			<td> The element broadcasting the notification.
		 * 				 <strong> Deprecated, set for removal. </strong>
		 * 			</td>
		 * 		</tr>
		 * 		<tr>
		 * 			<td> 1 </td>
		 * 			<td> IDataChangeDetail </td>
		 * 			<td> Values contained are:
		 * 				<ul>
		 * 					<li> IDataChangeDetail.changeType = DataChangeDetail.CHANGE </li>
		 * 					<li> IDataChangeDetail.changedElement = the current element </li>
		 * 					<li> IDataChangeDetail.originator = the current element </li>
		 * 				</ul>
		 * 			</td>
		 * 		</tr>
		 * </table>
		 */
		function setContent(key:String, content:*):void;


		/**
		 * Sets the metadata corresponding to the given key.
		 *
		 * NOTE:
		 * Both <em>metadata</em> and <em>content</em> associate values with elements,
		 * however, metadata is intended to be intrinsic to elements.
		 *
		 * @param	key
		 * 			A Key corresponding to some metadata to set.
		 *
		 * @param	metadata
		 * 			A value to associate to the metadata being set.
		 *
		 * <p>
		 * <strong>NOTE:</strong>
		 * Broadcasts an <code>IObserver</code> <strong>notification</strong> named
		 * <code>DataChangeDetail.MODEL_METADATA_CHANGED</code>; the following parameters
		 * will be passed to any callback that registers to it:
		 * </p>
		 * <table class="innertable">
		 * 		<tr>
		 * 			<th> index </th>
		 * 			<th> type </th>
		 * 			<th> value </th>
		 * 		</tr>
		 * 		<tr>
		 * 			<td> 0 </td>
		 * 			<td> IDataElement </td>
		 * 			<td> The element broadcasting the notification.
		 * 				 <strong> Deprecated, set for removal. </strong>
		 * 			</td>
		 * 		</tr>
		 * 		<tr>
		 * 			<td> 1 </td>
		 * 			<td> IDataChangeDetail </td>
		 * 			<td> Values contained are:
		 * 				<ul>
		 * 					<li> IDataChangeDetail.changeType = DataChangeDetail.CHANGE </li>
		 * 					<li> IDataChangeDetail.changedElement = the current element </li>
		 * 					<li> IDataChangeDetail.originator = the current element </li>
		 * 				</ul>
		 * 			</td>
		 * 		</tr>
		 * </table>
		 */
		function setMetadata(key:String, metadata:*):void;

		/**
		 * Recursively serializes the metadata, content and children of this element,
		 * using the element's <strong>built-in</strong> serialized format.
		 *
		 * The resulting value can be fed back into the <code>fromSerialized()</code>
		 * method of this, or another element, to re-create the same data structure.
		 *
		 * N.B.: In the process, the tree of children is <strong>recreated</strong>
		 * instead of cloned, which involves reparenting the elements as needed at
		 * de-serialization time.
		 *
		 * The default implementation uses a compressed <code>ByteArray</code> as a
		 * serialization medium.
		 *
		 * @return	The serialized form of this element.
		 *
		 */
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
		 * Checks whether this element has exactly the same set of keys as 
		 * another one.
		 * 
		 * @param	otherElement
		 * 			An element to test for equivalence
		 * 
 		 * @return	True if elements are equivalen, false otherwise.
		 */
		function isEquivalentTo (otherElement:IDataElement):Boolean;
	}
}
