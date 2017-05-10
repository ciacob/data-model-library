package ro.ciacob.desktop.data {

	/**
	 * @inheritDoc
	 */
	public class DataChangeDetail implements IDataChangeDetail {

		/**
		 * Defines the action of adding a child IDataElement.
		 */
		public static const ADD:String = 'add';

		/**
		 * Defines the action of changing the data a child carries, rather than the
		 * child itself (or its children).
		 */
		public static const CHANGE:String = 'change';

		/**
		 * Defines actions, that deal with altering the content of elements, or their
		 * hierarchical structure.
		 */
		public static const MODEL_CONTENT_CHANGED:String = 'modelContentChanged';

		/**
		 * Defines actions, that deal with altering the elements' metadata only.
		 */
		public static const MODEL_METADATA_CHANGED:String =
			'modelMetadataChanged';
		/**
		 * Defines the action of rebuilding the entire data structure.
		 */
		public static const REFRESH:String = 'refresh';
		/**
		 * Defines the action of removing a child IDataElement.
		 */
		public static const REMOVE:String = 'remove';

		/**
		 * Defines the data format for notifications broadcasted by
		 * <code>IDataElement</code>s.
		 * @param 	changeType
		 * 			The type of change that has occured. Use one of the constants
		 * 			defined in the DataChangeDetail:
		 * 			<ul>
		 * 	  			<li> DataChangeDetail.ADD </li>
		 *    			<li> DataChangeDetail.REMOVE </li>
		 *    			<li> DataChangeDetail.REFRESH </li>
		 * 			</ul>
		 *
		 * @param 	changedElement
		 * 			The IDataElement which has undergone the change. If
		 * 			<code>changeType</code> is <code>DataChangeDetails.REFRESH</code>,
		 * 			this should be null.
		 *
		 * @param 	originator
		 * 			The IDataElement which has broadcasted this notification.
		 *
		 */
		public function DataChangeDetail(changeType:String,
			changedElement:IDataElement, originator:IDataElement) {
		}

		/**
		 * @inheritDoc
		 */
		public function get changeType():String {
			return null;
		}

		/**
		 * @inheritDoc
		 */
		public function get changedElement():IDataElement {
			return null;
		}

		/**
		 * @inheritDoc
		 */
		public function get originator():IDataElement {
			return null;
		}
	}
}
