package ro.ciacob.desktop.data2 {
	import flash.utils.ByteArray;

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
		 * The respective offsets of changes.
		 * 
		 * NOTE: For instance, if an operation changes a contiguous sequence of 128 bytes starting at 
		 * ofset 348, `offsets` will point to a Vector with one integer, with the value of 348.
		 * Consequently, both `changedBytes` and `originalBytes` will point to Vectors with
		 * one ByteArray object each, and the ByteArrays will both have 128 bytes starting
		 * at offset `0`. Only the ByteArray pointed to by `changedBytes` will contain a copy of
		 * the new/changed bytes, and the other, of the old/original ones.
		 * 
		 * Where the operation produce sparse changes, an entry like the one described above will
		 * be includded for each contiguous sequence of bytes.
		 */
		function set offsets (value : Vector.<uint>) : void;
		function get offsets () : Vector.<uint>;
		
		/**
		 * The respective sequences of changed bytes.
		 */
		function set changedBytes (value : Vector.<ByteArray>) : void;
		function get changedBytes () : Vector.<ByteArray>;
		
		/**
		 * The respective sequences of original bytes.
		 */
		function set originalBytes (value : Vector.<ByteArray>) : void;
		function get originalBytes () : Vector.<ByteArray>;
		
	}
}