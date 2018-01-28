package ro.ciacob.desktop.data2
{
	/**
	 * Stores specific information about an atomic change in a dataset.
	 */
	public interface IChangeRecord
	{
		/**
		 * Used to store/retrieve the type of change that occured.
		 * 
		 * NOTE: The constants used shall mean, e.g., 'added', 'updated',
		 * 'deleted', 'location changed'. No change will be recorded for
		 * taxonomy changes.
		 */
		function set changeType (value : int) : void;
		function get changeType () : int;
		
		/**
		 * Used to store/retrieve the key that has been changed.
		 */
		function set key (value : int) : void;
		function get key () : int;
		
		/**
		 * Used to store/retrieve the type of the value that has been 
		 * changed.
		 * 
		 * NOTE: Supported types are listed in IDataset.as.
		 * NOTE: Will be `null` if "changeType" is "location changed".
		 */
		function set type (value : int) : void;
		function get type () : int;
		
		/**
		 * Used to store/retrieve the value AFTER change. 
		 * 
		 * NOTE: Only employed for primitive type values.
		 * NOTE: Will be `null` for deletions.
		 * NOTE: Will be `null` if "changeType" is "location changed".
		 */
		function set newValue (value : Object) : void;
		function get newValue () : Object;
		
		/**
		 * Used to store/retrieve the value BEFORE change.
		 * 
		 * NOTE: Will be `null` for additions.
		 * NOTE: Only employed for primitive type values.
		 * NOTE: Will be `null` if "changeType" is "location changed".
		 */
		function set oldValue (value : Object) : void;
		function get oldValue () : Object;
		
		/** 
		 * Used to store/retrieve the value AFTER change.
		 * NOTE: Will be `-1` for deletions.
		 * NOTE: Will be `-1` if "changeType" is "location changed".
		 * 
		 * NOTE: Only used for Vector type values. Vectors are handled transparently in v. 2.0,
		 * as contiguous sequences of row indices from a SQLite table. The main class
		 * assembles on-the-fly a proper AS3 Vector whenever requested a Vector type value,
		 * but there is no need to do that in a reporting facility, especially given that
		 * most reports will go unnoticed and unused during the application lifetime.
		 * Therefore, we store here just enough information to be able to redempt a 
		 * Vector from, if (ever) needed. 
		 */
		function set newVectorStartIndex (value : int) : void;
		function set newVectorEndIndex (value : int) : void;
		function get newVectorStartIndex () : int;
		function get newVectorEndIndex () : int;
		
		/** 
		 * Used to store/retrieve the value BEFORE change.
		 * NOTE: Will be `-1` for additions.
		 * NOTE: Will be `-1` if "changeType" is "location changed".
		 * NOTE: Only used for Vector type values. See explanation for 
		 * "set $newVectorStartIndex" & friends.
		 */
		function set oldVectorStartIndex (value : int) : void;
		function set oldVectorEndIndex (value : int) : void;
		function get oldVectorStartIndex () : int;
		function get oldVectorEndIndex () : int;
		
		/**
		 * Only used if the type of change is 'location changed'. Stores and retrieves
		 * the dataset's `depth` information AFTER change.
		 */
		function set newDepth (value : int) : void;
		function get newDepth () : int;
		
		/**
		 * Only used if the "changeType" is "location changed". Stores and retrieves
		 * the dataset's `depth` information BEFORE change.
		 */
		function set oldDepth (value : int) : void;
		function get oldDepth () : int;
		
		/**
		 * Only used if the the "changeType" is "location changed". Stores and retrieves
		 * the dataset's `ordinal` information AFTER change.
		 */
		function set newOrdinal (value : uint) : void;
		function get newOrdinal () : uint;
		
		/**
		 * Only used if the "changeType" is "location changed". Stores and retrieves
		 * the dataset's `ordinal` information BEFORE change.
		 */
		function set oldOrdinal (value : uint) : void;
		function get oldOrdinal () : uint;
	}
}