package ro.ciacob.desktop.data2 {
	
	/**
	 * Stores context information about a change in a dataset.
	 */
	public interface IDatasetReport {
		
		/**
		 * Optional description of what changed.
		 */
		function set description (value : String) : void;
		function get description () : String;
		
		/**
		 * Time when changed occured.
		 */
		function set timestamp (value : Number) : void;
		function get timestamp () : Number;
		
		/**
		 * Stores one change
		 */
		function addChangeRecord (change : IChangeRecord) : void;
		
		/**
		 * Stores an arbitrary number of changes
		 */
		function addChangeRecords (... changes) : void;
		
		/**
		 * Returns the list of changes stored with this report
		 */
		function get changes () : Vector.<IChangeRecord>;
	}
}