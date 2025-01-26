package ro.ciacob.desktop.data.events {
    import flash.events.Event;
    import ro.ciacob.desktop.data.SelectableDataElement;

    public class SelectableDataEvent extends Event {

        public static const REPORT:String = "report";

        private var _selectionAnchor:SelectableDataElement;
        private var _unselected:Array;
        private var _selected:Array;

        /**
         * Constructor for the SelectableDataEvent.
         *
         * @param type The event type ("report").
         * @param selectionAnchor The anchor element for the selection.
         * @param unselected An array of items that were unselected. Defaults to null.
         * @param selected An array of items that were selected. Defaults to null.
         * @param bubbles Whether the event bubbles. Defaults to false.
         * @param cancelable Whether the event can be canceled. Defaults to false.
         */
        public function SelectableDataEvent(
                type:String,
                selectionAnchor:SelectableDataElement,
                unselected:Array = null,
                selected:Array = null,
                bubbles:Boolean = false,
                cancelable:Boolean = false
            ) {
            super(type, bubbles, cancelable);

            _selectionAnchor = selectionAnchor;
            _unselected = unselected ? unselected.concat() : [];
            _selected = selected ? selected.concat() : [];
        }

        // Read-only getters for the payload properties
        public function get selectionAnchor():SelectableDataElement {
            return _selectionAnchor;
        }

        public function get unselected():Array {
            return _unselected.concat(); // Return a copy to ensure immutability
        }

        public function get selected():Array {
            return _selected.concat(); // Return a copy to ensure immutability
        }

        /**
         * Creates a copy of the event object.
         *
         * @return A new SelectableDataEvent instance with the same properties.
         */
        override public function clone():Event {
            return new SelectableDataEvent(
                    type,
                    _selectionAnchor,
                    _unselected,
                    _selected,
                    bubbles,
                    cancelable
                );
        }

        /**
         * Returns a string representation of the event object.
         *
         * @return A string describing the event.
         */
        override public function toString():String {
            return formatToString(
                    "SelectableDataEvent",
                    "type",
                    "selectionAnchor",
                    "unselected",
                    "selected",
                    "bubbles",
                    "cancelable",
                    "eventPhase"
                );
        }
    }
}
