package ro.ciacob.desktop.data {

	/**
	 * Defines the data format for notifications broadcasted by <code>IDataElement</code>s.
	 * @see IDataElement
	 */
	public interface IDataChangeDetail {

		/**
		 * The type of change that has occured. Should be one of the constants defined in
		 * the DataChangeDetail:
		 * <ul>
		 * 	  <li> DataChangeDetail.ADD </li>
		 *    <li> DataChangeDetail.REMOVE </li>
		 *    <li> DataChangeDetail.CHANGE </li>
		 *    <li> DataChangeDetail.REFRESH </li>
		 * </ul>
		 */
		function get changeType():String;
		
		/**
		 * The IDataElement which has undergone the change. If <code>changeType</code>
		 * is <code>DataChangeDetails.REFRESH</code>, this should be null.
		 */
		function get changedElement():IDataElement;
		
		/**
		 * The IDataElement which has broadcasted this notification.
		 */
		function get originator():IDataElement;
	}
}
