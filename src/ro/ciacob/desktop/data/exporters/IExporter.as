package ro.ciacob.desktop.data.exporters {
	import ro.ciacob.desktop.data.DataElement;
	

	/**
	 * Implementors will be responsible with converting DataElement structures into
	 * various formats.
	 */
	public interface IExporter {
		/**
		 * Takes a (possibly) hierarchical DataElement structure, converts it
		 * into a different format and returns the result.
		 * 
		 * @param	data
		 * 			The structure to be converted.
		 * 
		 * @param	shallow
		 * 			If set, shall not recursivelly descend into children
		 * 
		 * @param	isRecursiveCall
		 * 			Recursive calls can set this argument to `true`, so that initialization tasks can be performed on
		 * 			the initial (originar) call of the function.
		 * 
		 * @return	The converted result. 
		 */
		function export (data : DataElement, shallow : Boolean = false, isRecursiveCall : Boolean = false) : *;
	}
}