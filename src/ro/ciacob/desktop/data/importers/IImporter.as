package ro.ciacob.desktop.data.importers {
	import ro.ciacob.desktop.data.DataElement;

	/**
	 * Implementors will be responsible with populating given DataElement structures with
	 * data in various formats.
	 */
	public interface IImporter {
		
		/**
		 * Imports some data (in third-party format) into an DataElement hierarchical structure.
		 * @param	data
		 * 			Data to be imported.
		 * 
		 * @param 	intoStructure
		 * 			DataElement structure to import into.
		 */
		function importData (data: *, intoStructure : DataElement) : void;
	}
}
