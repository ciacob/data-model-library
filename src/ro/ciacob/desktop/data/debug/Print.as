package ro.ciacob.desktop.data.debug {
	import ro.ciacob.desktop.data.DataElement;
	import ro.ciacob.utils.Strings;

	/**
	 * Prints out the hierarchic structure of given element, carying out custom
	 * summarization.
	 *
	 * @param	element
	 * 			The element to print.
	 *
	 * @param	summarisation
	 * 			An optional function to call against each child, expected to
	 * 			produce a string that will be inserted into each `ELEMENT`
	 * 			description. The function's signature must be:
	 *
	 * 			function (element : DataElement) : String
	 */
	public final class Print {
		
		private static const INDENT:String = '    ';
		
		public static function output(element:DataElement, summarisation:Function =
			null):void {
			trace('\n');
			element.walk(function(child:DataElement):void {
				var padding:String = Strings.repeatString('    ', child.level);
				var childRoute:String = child.route;
				var summary:String = '';
				if (summarisation != null) {
					summary = summarisation(child) + ' ';
				}
				var elRoute:String = child.route;
				var contentDump:Array = [];
				var elContentKeys:Array = child.getContentKeys();
				elContentKeys.sort();
				for (var k:int = 0; k < elContentKeys.length; k++) {
					var contentKey:String = elContentKeys[k];
					contentDump.push(contentKey + '-> ' + child.getContent(contentKey));
				}
				trace(padding + '[ELEMENT ' + summary + childRoute + ']');
				trace(padding + '         ' + contentDump.join('\n' + padding + '         '));
			});
		}
		
		public static function outputLegacy(element:DataElement):void {
			trace(_indent(element.level), 'Printing element: ', element);
			var metaKeys:Array = element.getMetaKeys();
			if (metaKeys.length > 0) {
				trace(_indent(element.level), 'METADATA');
				for each (var metaKey:String in metaKeys) {
					trace(_indent(element.level), metaKey, '=>', element.getMetadata(metaKey));
				}
			} else {
				trace(_indent(element.level), 'NO METADATA');
			}
			var contentKeys:Array = element.getContentKeys();
			if (contentKeys.length > 0) {
				trace(_indent(element.level), 'CONTENT');
				for each (var contentKey:String in contentKeys) {
					trace(_indent(element.level), contentKey, '=>', element.getContent(contentKey));
				}
			} else {
				trace(_indent(element.level), 'NO CONTENT');
			}
			var numChildren:int = element.numDataChildren;
			if (numChildren > 0) {
				trace(_indent(element.level), 'CHILDREN (', element.numDataChildren, ')');
				for (var i:int = 0; i < numChildren; i++) {
					outputLegacy(element.getDataChildAt(i));
				}
			} else {
				trace(_indent(element.level), 'NO CHILDREN');
			}
			trace(_indent(element.level), 'Finished printing element.\n');
		}
		
		private static function _indent(toLevel:int):String {
			return Strings.repeatString(INDENT, toLevel);
		}
	}
}