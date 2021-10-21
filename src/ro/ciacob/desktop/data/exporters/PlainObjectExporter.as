package ro.ciacob.desktop.data.exporters {
	import ro.ciacob.ciacob;
	import ro.ciacob.desktop.data.DataElement;
	import ro.ciacob.desktop.data.constants.DataKeys;

	use namespace ciacob;

	public class PlainObjectExporter implements IExporter {
		
		public function export(data:DataElement, shallow : Boolean = false, isRecursiveCall : Boolean = false):* {
			var result:Object = {};
			result[DataKeys.METADATA] = {};
			var metaKeys : Array = data.getMetaKeys();
			for (var i:int = 0; i < metaKeys.length; i++) {
				var metaKey : String = metaKeys[i];
				result[DataKeys.METADATA][metaKey] = data.getMetadata(metaKey);
			}
			// We must orphan the element before serializing, as genealogy will be re-created
			// upon deserialization.
			delete result[DataKeys.METADATA][DataKeys.PARENT];
			delete result[DataKeys.METADATA][DataKeys.INDEX];
			delete result[DataKeys.METADATA][DataKeys.LEVEL];
			delete result[DataKeys.METADATA][DataKeys.ROUTE];
			result[DataKeys.CONTENT] = {};
			var contentKeys : Array = data.getContentKeys();
			for (var k:int = 0; k < contentKeys.length; k++) {
				var contentKey : String = contentKeys[k];
				result[DataKeys.CONTENT][contentKey] = data.getContent(contentKey);
			}
			result[DataKeys.CHILDREN] = [];
			if (!shallow) {
				for (var j:int = 0; j < data.numDataChildren; j++) {
					var childItem : DataElement = DataElement(data.getDataChildAt(j));			
					var childItemExported:Object = export (childItem);
					result[DataKeys.CHILDREN][j] = childItemExported;
				}
			}
			return result;
		}
	}
}
