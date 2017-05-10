package ro.ciacob.desktop.data.exporters {
	import ro.ciacob.desktop.data.IDataElement;

	/**
	 * Implementors will be responsible with converting IDataElement structures into
	 * various formats.
	 */
	public interface IExporter {
		/**
		 * Takes a (possibly) hierarchical IDataElement structure, converts it
		 * into a different format and returns the result.
		 * 
		 * @param	data
		 * 			The structure to be converted.
		 * @return	The converted result. 
		 */
		function export (data : IDataElement, shallow : Boolean = false) : *;
	}
}