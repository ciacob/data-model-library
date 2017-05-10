package ro.ciacob.desktop.data2
{
	public interface IDatasetFilter
	{
		/**
		 * The key of a field; in 2.0 keys are expressed as an integers.
		 */
		function get key () : uint;
		function set key (value : uint) : void;
		
		/**
		 * The taxonomies associated to a field;  taxonomies are expressed as integers.
		 * NOTE: Taxonomies are optional.
		 */
		function get taxonomies () : Vector.<uint>;
		function set taxonomies (value : Vector.<uint>) : void;
		
		/**
		 * Field values; in 2.0 field values are strictly typed and uni-dimensional. One should use the
		 * hierarchic mechanism (`addSubset()` & friends) if multi-dimensionality is needed.
		 */
		function get $int () : int;
		function set $int (value : int) : void;
		
		function get $uint () : uint;
		function set $uint (value : uint) : void;
		
		function get $number () : Number;
		function set $number (value : Number) : void;
		
		function get $bool () : Boolean;
		function set $bool (value : Boolean) : void;
		
		function get $str () : String;
		function set $str (value : String) : void;
		
		function get $intVector () : Vector.<int>;
		function set $intVector (value : Vector.<int>) : void;
		
		function get $uintVector () : Vector.<uint>;
		function set $uintVector (value : Vector.<uint>) : void;
		
		function get $numberVector () : Vector.<Number>;
		function set $numberVector (value : Vector.<Number>) : void;
		
		function get $boolVector () : Vector.<Boolean>;
		function set $boolVector (value : Vector.<Boolean>) : void;
		
		function get $strVector () : Vector.<String>;
		function set $strVector (value : Vector.<String>) : void;
	}
}