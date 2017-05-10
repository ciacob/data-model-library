package ro.ciacob.desktop.data.debug {
	import ro.ciacob.desktop.data.IDataElement;
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
	 * 			function (element : IDataElement) : String
	 */
	public final class Print {
		public static function output(element:IDataElement, summarisation:Function =
			null):void {
			trace('\n');
			element.walk(function(child:IDataElement):void {
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
	}
}