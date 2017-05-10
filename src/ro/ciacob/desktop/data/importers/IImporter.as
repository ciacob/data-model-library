package ro.ciacob.desktop.data.importers {
	import ro.ciacob.desktop.data.IDataElement;

	/**
	 * Implementors will be responsible with populating given IDataElement structures with
	 * data in various formats.
	 */
	public interface IImporter {
		
		/**
		 * Imports some data (in third-party format) into an IDataElement hierarchical structure.
		 * @param	data
		 * 			Data to be imported.
		 * 
		 * @param 	intoStructure
		 * 			IDataElement structure to import into.
		 */
		function importData (data: *, intoStructure : IDataElement) : void;
	}
}
