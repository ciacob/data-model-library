package ro.ciacob.desktop.data2 {
	import flash.filesystem.File;
	import flash.utils.ByteArray;
	
	/**
	 * Version 2.0 of IDataElement, renamed as IDataset. Unlike the previous version, this one stores data internally
	 * dirrectly in a ByteArray, one sharing the internal structure with the file persisted on disk, which gives a
	 * number of benefits, such as low memory consumption, fast disk access times, fast cloning and filtering,
	 * built-in undo/redo capabilities, memory & disc-access optimization capabilities.
	 * 
	 * @see IDataElement
	 */
	public interface IDataset {
		
		// HIERARCHY
		
		/**
		 * New in 2.0. Will create an empty instance of the current class. Implementation will rely
		 * on avoiding hard-coupling to any specific IDataHolder implementor.
		 */
		function createDataSet () : IDataset;
		
		/**
		 * @see IDataElement.addDataChild
		 * @see IDataElement.addDataChildAt
		 * @deleted IDataElement.canHaveChildren
		 */
		function addSubset (dataset : IDataset, offset : int = -1) : void;
		
		/**
		 * @see IDataElement.removeDataChild
		 * @see IDataElement.removeDataChildAt
		 * 
		 * NOTE: you can bypass the first argument with `null`, in order to remove a subset by its offset.
		 */
		function removeSubset (dataset : IDataset = null, offset : int = -1) : void;
		
		
		// TRAVERSAL
		
		/**
		 * @see IDataElement.getDataChildAt()
		 */
		function getSubset (byIndex : int) : IDataset;
		
		/**
		 * @see IDataChildren.numDataChildren();
		 */
		function get numSubsets () : uint;
		
		/**
		 * @see IDataElement.dataParent
		 */
		function get $superset () : IDataset;

		/**
		 * New in 2.0. Provides direct access to the root in the hierarchical chain.
		 */
		function get $rootset () : IDataset;
		
		/**
		 * New in 2.0. Provides direct access to the folowing/previous sibling of the curent set, or
		 * the folowing/previous sibling of the current set's parent (and so forth). Makes traversal
		 * of the entire collection very fast and convenient.
		 * 
		 * @param crossSuper If set to false, will return `null` for the last sibling of the 
		 * 					 `current superset.
		 */
		function getNextSet (crossSuper : Boolean = true) : IDataset;
		function getPrevSet (crossSuper : Boolean = true) : IDataset;
		
		
		// INDEXING
		
		/**
		 * @see IDataElement.level
		 */
		function get depth () : int;
		
		/**
		 * @see IDataElement.index
		 */
		function get ordinal () : uint;
		
		/**
		 * @see IDataElement.route
		 */
		function get route () : Vector.<int>;
		
		
		// SEARCHING
		
		/**
		 * New in 2.0. Replaces and extends IDataElement.numDataChildren by adding optional
		 * parameters, which allow one to count also descendants, leave out the ones that do not match
		 * a number of filters, or confine the search to the boundaries of a given superset.
		 */
		function countSubSets (maxLevelsDeep : int = 1, filters : Vector.<IDatasetFilter> = null, within : IDataset = null) : uint;
		
		/**
		 * In 2.0, this type of search starts by default from the `$rootset`. A different
		 * starting point can be enforced by providing the second argument. If the second argument is given,
		 * a relative route is expected (i.e., one that does not start with `-1_`.
		 * @see IDataElement.getElementByRoute()
		 */
		function getSet (byRoute : String, within : IDataset = null) : IDataset;
		
		/**
		 * New in 2.0. Finds the subsets matching a list of filters, and returns them in a flat list.
		 * By default, the search is carried on at the `$rootset`, but one can confine it
		 * to the boundaries of a given superset, by providing the second argument.
		 */
		function findSets (filters : Vector.<IDatasetFilter>, within : IDataset = null) : Vector.<IDataset>;
		
		/**
		 * New in 2.0. Finds the fields that match a list of filters, and returns their keys in a list.
		 * By default, the search is carried on at the `$rootset`, but one can confine it to the boundaries
		 * of a given set, by providing the second argument.
		 */
		function findFields (filters : Vector.<IDatasetFilter>, within : IDataset = null) : Vector.<int>;
		
		/**
		 * New in 2.0. Intended to be used by methods that employ filters. The second argument
		 * should send values that `mean`: "all", "any", or "none" (negates all filters). Should default to "all".
		 */
		function matches (filters : Vector.<IDatasetFilter>, logicalOperator : int = -1) :Boolean;
		
		/**
		 * @see IDataElement.isEqualTo
		 */
		function equals (to : IDataset) : Boolean;
		
		/**
		 * @see IDataElement.isEquivalentTo
		 * By "keys", documentation of 1.1 refers to "(field) keys" in the current naming scheme.
		 */
		function similar (to : IDataset) : Boolean;
		
		/**
		 * New in 2.0. Creates filters that can be used to match sets that resemble the current
		 * one. By default, all keys and values of all fields are includded, but optional
		 * arguments can be provided to exclude one or more fields entirely, or only their values
		 * (the filter will match based on the mere existence of a given key).
		 */
		function toSearchCriteria (excludingFields : Vector.<uint> = null,
			excludingValuesOf : Vector.<uint> = null) : Vector.<IDatasetFilter>;
		
		/**
		 * @see IDataset.getContentKeys
		 */
		function get keys () : Vector.<uint>;
		
		
		// STORAGE
		
		/**
		 * New in 2.0. Strongly-typed setters and getters are expected to outperform their weakly-typed (varname : Object) or
		 * untyped (varname : *) version, both speed and memorywise. They are recommended in bulk operations (e.g., loops).
		 * 
		 * NOTE: version 2.0 DROPS support for dynamic and weakly-typed values (Object, Array), and, consequently, drops
		 * support for multi-dimensional values of arbitrary nesting (i.e., Arrays that contain Arrays or Objects, or viceversa).
		 * One can still represent these structures using `addSubset()` & friends (see above).
		 * 
		 * In an attempt to conserve memory, version 2.0 only accepts INTs as keys.
		 */
		function setInt (key : int, value : int, taxonomies : Vector.<uint> = null) : void;
		function setUint (key : int, value : uint, taxonomies : Vector.<uint> = null) : void;
		function setNumber (key : int, value : Number, taxonomies : Vector.<uint> = null) : void;
		function setBool (key : int, value : Boolean, taxonomies : Vector.<uint> = null) : void;
		function setStr (key : int, value : String, taxonomies : Vector.<uint> = null) : void;
		
		function getInt (key : int) : int;
		function getUint (key : int) : uint;
		function getNumber (key : int) : Number;
		function getBool (key : int) : Boolean;
		function getStr (key : int) : String;

		/**
		 * New to 2.0. Deletes associated value (if any), and removes the key.
		 */
		function $delete (key : int) : void;
		
		/**
		 * @see IDataElement.hasContentKey()
		 */
		function has (key : int) : Boolean;
		
		/**
		 * Version 2.0 dropped the binomial `content`-`metadata`, and replaced it with a basic taxonomical system,
		 * where an arbitrary number of optional tags can be attached to each defined field. They can be used later
		 * on for filtering and grouping fields, regardless of their type, name or value. Tags must
		 * always be represented as unsigned integers.
		 */
		function getTaxonomies (forKey : int) : Vector.<uint>;
		function setTaxonomies (forKey : int, to : Vector.<uint>) : void;
		
		/**
		 * Convenient method for quickly altering the taxonomies currently set for an existing key, by specifying what
		 * to remove (if found) and what to add (if missing). The second argument should be bypassable by null.
		 */
		function changeTaxonomies (forKey : int, byRemoving : Vector.<uint>, byAdding : Vector.<uint> = null) : void;
		
		/**
		 * Checks whether a field has the specified taxonomies. The third argument should send values that `mean`:
		 * "all", "any", or "none" (negates all filters). Should default to "all".
		 */
		function hasTaxonomies (key : int, list : Vector.<uint>, logicalOperator : int) : Boolean;
		
		
		// SERIALIZATION
		
		/**
		 * Version 2.0 dropped the distinction between `exporting` the data structure and `serializing` it. Consequently,
		 * it dropped the "importer" & "exporter" concepts, and the need for a subclass to reimplement the 
		 * serialization/deserialization methods in order to use various importers/exporters.
		 * 
		 * Instead, there will be two "stock" serialize/deserialize methods (supporting XML) and two generic 
		 * serialize/deserialize methods accepting a `Function` object that actually performs the 
		 * serialization/deserialization process.
		 *   
		 * @see `IDataElement.toSerialized()`
		 * @see `IDataElement.fromSerialized()`
		 * 
		 * @deleted `IDataElement.exportToFormat()`
		 * @deleted `IDataElement.importFromFormat()`
		 * @deleted `IDataElement.empty()`
		 * @deleted `IDataElement.populateWithDefaultData()`
		 * 
		 * Method `toXML()` serializes the current set into an XML document. The ability to omit certain subsets and/or fields is new to 2.0.
		 * 
		 * NOTE: fields set to be excludded will be omitted from rootset and all subsets, wherever they appear.
		 * 
		 * NOTE: XML is a lossy format. Data accuracy is not preserved during serialization to a XML:
		 * 	- (strong) typing is lost;
		 * 	- Vector values are turned into XMLLists;
		 * 	- subsets will be placed under an XML node, "children", which does not exist in the original dataset;
		 * 	- explicit hierarchical information (e.g., $superset, $rootset, depth) is lost.
		 * 
		 * In the de-serialization process, a best-effort, heuristic recovery strategy is employed, so "deserializing"
		 * XML documents that where not previously created by `toXML()` may fail.
		 * 
		 * NOTE: version 2.0 dropped any messaging/notification ability altogether. Therefore, since all the instances of the
		 * IDataset implementors are now inert, the method `empty()` was also dropped. If one needs to start fresh, simply
		 * trashing the current dataset, creating a new one in its place and calling `from...()` on it will do.
		 */
		function toXML (excludingSets:Vector.<IDataset> = null, excludingFields:Vector.<int> = null) : ByteArray;
		
		/**
		 * Populates the current set from given ByteArray. Overrides any matching fields, and adds any new subsets after
		 * existing ones.
		 */
		function fromXML (source : XML, excludingSets:Vector.<IDataset> = null, excludingFields:Vector.<int> = null) : void;
		
		/**
		 * NOTE: the second argument is meant to encourage reusing existing "formatter" functions via parameterizing (rather
		 * than writing custom serialization/deserialization code to handle even minor differeces). The function pointed to by the first
		 * argument will receive as arguments the current set and the "...Params" Object, provided it is not `null`.  
		 */
		function toCustomFormat (formatter : Function, formatterParams : Object = null) : Object;
		function fromCustomFormat (interpreter : Function, interpreterParams : Object = null) : void;
		
		/**
		 * Not present in IDataElement, but available "de facto" in the 1.1 implementation. Cloning a set creats an identical
		 * copy, or snapshot of it at the cloning time. 
		 * 
		 * NOTE: Version 2.0 adds the ability to create linked clones, to minimize the memory impact of a cloning operation.
		 * In a linked clone, all fields or subsets that weren't changed, either by the source, or the clone, are shared (i.e.,
		 * they point to the same location in memory). When either of the two changes a field or subset, an (unlinked) copy of that
		 * field or subset is made in the clone. This way, only changes need to occupy aditional memory. The downside is that
		 * the linked clone depends on the original. If one trashes the original, the linked clone becomes unusable. The linked
		 * clone is the default cloning mode in 2.0.
		 */
		function clone (linked : Boolean = true) : IDataset;
		
		/**
		 * Provided the current set is a `linked clone` (see above) of another set, calling this method will remove the dependency,
		 * allowing one to trash the original without destroying the clone too.
		 * 
		 * NOTE: This will effectivelly copy all fields to the clone, possibly consuming significant ammounts of RAM or CPU.
		 */
		function unlink () : void;
		
		
		// TRACKING
		
		/**
		 * Version 2.0 dropped the event dispatching ability, and replaced it with a passive mechanism of storing changes brought
		 * to the dataset, as atomic entries (one per change), called "reports". A report is an implementer of `IDatasetReport`,
		 * and stores information about what was changed, when, what was the value before the change, and the value after.
		 * Among other benefits, this effectively provides the essential functionality for adding on-premises undo-redo support.
		 * 
		 * Method `getLastReports()` returns a number of the most recent reports (by default, one). 
		 */
		function getLastReports (num : int = 1) : Vector.<IDatasetReport>;
		
		/**
		 * Similar to `getLastReports()`, except it only returns the reports, which are older than a given point in time.
		 */
		function getReportsSince (timestamp : Number) : Vector.<IDatasetReport>;
		
		/**
		 * Returns the reports which were recorded as closest to given timestamp as possible. If one is found to match the timestamp,
		 * it will be returned; otherwise, both the first report recorded after the given time, and the one recorded just before it 
		 * will be returned (provided there are such records).
		 */
		function getReportsAround (timestamp : Number) : Vector.<IDatasetReport>;
		
		/**
		 * Finds out whether the current "state" of the dataset (i.e., its entirety of fields and their respective values, recursivelly
		 * includding subsets) is the same as at the time a particular report was recorded. This will essentially be true if (1) all changes
		 * recorded in the report are traceable in the dataset's current "state", AND (2.1) there are no reports concerning any other changes, 
		 * OR, (2.2) if there are, they were susequent changes that eventually cancelled out one another (e.g., a = 1, a = 2, a = 1); 
		 */
		function hasSameStateAs (report : IDatasetReport) : Boolean;
		
		/**
		 * Enforces the current state of the dataset to be that of the given report. Runs in reverse through all the reports in-between and
		 * reverts all changes made.
		 */
		function toStateOfReport (report : IDatasetReport) : void;
		
		/**
		 * Removes reports that are more recent than a given time. This is commonly requested in linear undo-redo implementations (the "redo"
		 * history is cleared when the user "un-does", then makes a change).
		 */
		function clearReportsAfter (timestamp : Number) : void;
		
		/**
		 * Removes all reports. Usefull to recall memory, at the price of trashing the entire changes history.
		 */
		function clearAllReports () : void;
		
		/**
		 * Limits the number of report records to be kept in memory. By default, all records shall be kept.
		 */
		function set maxReports (value : int) : void;
		
		
		// DISC ACCESS
		
		/**
		 * Version 2.0 uses SQLite to persist data. Most of the arguments used here are for specific use of Adobe AIR SQLite implementation. Thus,
		 * this method essentially opens a connection to the database.
		 * 
		 * NOTE: as to stay true to the "inert" nature of this class, we do not provide a way to operate the underlying SQLite in asynchronous
		 * mode, even if the platforms gives this option (as doing so will involve dealing with events). The "accessMode" parameter takes values
		 * from the flash.data.SQLMode class. 
		 */
		function openSession (file : File, useEncryption : Boolean = false, accessMode : String = null) : void;
		
		/**
		 * Closes the current connection to the database (see notes for "openSession").
		 */
		function closeSession () : void;

	}
}