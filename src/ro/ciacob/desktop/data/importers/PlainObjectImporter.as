package ro.ciacob.desktop.data.importers {
	import ro.ciacob.ciacob;
	import ro.ciacob.desktop.data.DataElement;
	import ro.ciacob.desktop.data.constants.DataKeys;

	use namespace ciacob;

	public class PlainObjectImporter implements IImporter {

		/**
		 * @see ro.ciacob.lessonbuilder.model.importers.IImporter
		 */
		public function importData (data:*, intoStructure:DataElement) : void {
			// EXPLANATION: each child is structurally identical to the root. We grab the root's class definition
			// and we use it to create new children.
			var structureDefinition:Class = Class(Object(intoStructure).constructor);
			var metaData : Object = data[DataKeys.METADATA];
			if (metaData != null) {
				if (intoStructure is DataElement) {
					for (var metaKey:String in metaData) {
						if (Object(intoStructure).
							hasOwnProperty('ciacob::setIntrinsicMetadata')) {
							var setIntrinsicMetadata:Function =
								(Object(intoStructure)['ciacob::setIntrinsicMetadata'] as
								Function);
							setIntrinsicMetadata.
								apply(this, [metaKey, metaData[metaKey]]);
						} else {
							DataElement(intoStructure).
								setMetadata(metaKey, metaData[metaKey]);
						}
					}
				}
			}
			var contentData:Object = data[DataKeys.CONTENT];
			if (contentData != null) {
				for (var contentKey:String in contentData) {
					intoStructure.
						setContent(contentKey, contentData[contentKey]);
				}
			}
			var childrenList:Array = data[DataKeys.CHILDREN];
			if (childrenList != null) {
				for (var i:int = 0; i < childrenList.length; i++) {
					var childDataToImport:Object = childrenList[i];
					var child:DataElement =
						DataElement(new structureDefinition);
					importData(childDataToImport, child);
					intoStructure.addDataChild(child);
				}
			}
		}
	}
}
