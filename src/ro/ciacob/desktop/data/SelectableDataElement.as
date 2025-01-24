package ro.ciacob.desktop.data {

    import ro.ciacob.utils.Objects;
    import ro.ciacob.utils.Descriptor;
    import ro.ciacob.utils.Strings;
    import flash.events.IEventDispatcher;
    import flash.events.EventDispatcher;
    import flash.events.Event;
    import ro.ciacob.desktop.data.events.SelectableDataEvent;

    public class SelectableDataElement extends DataElement implements IEventDispatcher {
        private static const OP_SELECT:String = 'select';
        private static const OP_UNSELECT:String = 'unselect';

        private var _usesNormalization:Boolean;
        private var _isSelected:Boolean;
        private var _isSelectable:Boolean;
        private var _isUsingHighAnchor:Boolean;
        private var _eventDispatcher:EventDispatcher;
        
        protected var _globalSelectionMap:Object;

        /**
         * Subclass of `DataElement` adding selection management capabilities.
         *
         * @param   initialMetadata
         *          See `DataElement` constructor documentation.
         *
         * @param   initialContent
         *          See `DataElement` constructor documentation.
         *
         * @param   normalizeSelection
         *          Enforces a selection model where selecting elements found at
         *          different levels in the hierarchy selects the descendants
         *          available at the deepest level of the provided ones, in exchange.
         *
         * @see     DataElement
         */
        public function SelectableDataElement(normalizeSelection:Boolean = false,
                initialMetadata:Object = null,
                initialContent:Object = null) {
            super(initialMetadata, initialContent);
            _eventDispatcher = new EventDispatcher(this);
            _usesNormalization = normalizeSelection;
        }

        /**
         * @return `True` if the element is currently selected, `false` otherwise.
         */
        public function get isSelected():Boolean {
            return _isSelected;
        }

        /**
         * Sets the current `SelectableDataElement` as selectable (`true`) or not.
         */
        public function set isSelectable(value:Boolean):void {
            if (_isSelectable != value) {
                _isSelectable = value;
            }
        }

        /**
         * @return  `True` if the current `SelectableDataElement` can be selected,
         *          `false` otherwise.
         */
        public function get isSelectable():Boolean {
            return _isSelectable;
        }

        /**
         * @return `True` if a higher-index selection anchor is to be preferred to a
         * lower one. For practical purposes this can result in replicating Windows
         * behavior, where a new selection range REPLACES the existing one rather than
         * building on top of it. The `false` value can result in a behavior that is
         * more common on Unix, where you can increase or decrease an existing
         * selection range. Default is `false`.
         */
        public function get isUsingHighAnchor():Boolean {
            return _isUsingHighAnchor;
        }

        /**
         * @param The selection anchor model to use. Use `true` if a higher-index
         * selection anchor is to be preferred to a lower one. For practical purposes
         * this can result in replicating Windows behavior, where a new selection range
         * REPLACES the existing one rather than building on top of it. The `false` value
         * can result in a behavior that is more common on Unix, where you can increase
         * or decrease an existing selection range.
         */
        public function set isUsingHighAnchor(value:Boolean):void {
            if (_isUsingHighAnchor != value) {
                _isUsingHighAnchor = value;
                // TBD: report new anchor if it has changed
            }
        }

        /**
         * Root-level storage for all currently selected elements within the current
         * hierarchy. Each `SelectableDataElement` in-there is stored under its
         * `route`, as key. There are also two dedicated keys, `lowAnchor` and
         * `highAnchor` that hold the lowest, respectively highest routes among
         * those that the latest "select..." operation provided.
         *
         * @return  Object with all currently selected elements and high and low
         *          selection anchors.
         */
        public function get globalSelectionMap():Object {
            // Delegate to parent, for as long as there is a parent.
            if (dataParent != null) {
                return SelectableDataElement(dataParent).globalSelectionMap;
            }

            // If this _is_ the root, return the `_globalSelectionMap` (initialize if needed).
            if (_globalSelectionMap == null) {
                _globalSelectionMap = {};
            }
            return _globalSelectionMap;
        }

        /**
         * @see flash.events.IEventDispatcher.addEventListener
         */
        public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {
            _eventDispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
        }

        /**
         * @see flash.events.IEventDispatcher.removeEventListener
         */
        public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void {
            _eventDispatcher.removeEventListener(type, listener, useCapture);
        }

        /**
         * @see flash.events.IEventDispatcher.dispatchEvent
         */
        public function dispatchEvent(event:Event):Boolean {
            return _eventDispatcher.dispatchEvent(event);
        }

        /**
         * @see flash.events.IEventDispatcher.hasEventListener
         */
        public function hasEventListener(type:String):Boolean {
            return _eventDispatcher.hasEventListener(type);
        }

        /**
         * @see flash.events.IEventDispatcher.willTrigger
         */
        public function willTrigger(type:String):Boolean {
            return _eventDispatcher.willTrigger(type);
        }

        /**
         * Selects the current element or any other descendant(s) of the same root. Does
         * NOT clear the current selection, use `clearSelection()` explicitly.
         *
         * @param   ...elements
         *          Array of SelectableDataElement instances to select. If empty, the current
         *          element will be selected. Otherwise, all elements that are not orphans and
         *          belong to the `root` of the current element will be selected, subject to the
         *          `normalizeSelection` and `isSelectable` settings.
         */
        public function select(...elements):void {
            _doOperation(OP_SELECT, elements);
        }

        /**
         * Unselects the current element or any other descendant(s) of the same root, provided they
         * were selected.
         *
         * @param   ...elements
         *          Array of SelectableDataElement instances to unselect, if applicable. If empty,
         *          the current element will be unselected. Otherwise, all elements that are not
         *          orphans and belong to the `root` of the current element will be unselected,
         *          subject to the `normalizeSelection` setting.
         */
        public function unselect(...elements):void {
            _doOperation(OP_UNSELECT, elements);
        }

        /**
         * Selects a range of descendants of the same root as the current element, subject to the
         * `normalizeSelection` and `isSelectable` settings.  Does NOT clear the current selection, use
         * `clearSelection()` explicitly.
         *
         * @param   to
         *          The element to select up to and including, observing `route` order.
         *
         * @param   from
         *          Optional. The element to select from, including. If `null`, and a suitable
         *          "...Anchor" exists within `globalSelectionMap`, that will be used instead.
         *          If no anchor exists, the current `SelectableDataElement` will be assumed.
         */
        public function selectRange(to:SelectableDataElement, from:SelectableDataElement = null):void {
            var rangeSet:Array = _buildRangeSet(to,
                    from || (_isUsingHighAnchor ? _globalSelectionMap.highAnchor : _globalSelectionMap.lowAnchor) || this
                );
            select.apply(this, rangeSet);
        }

        /**
         * Unselects a range of descendants of the same root as the current element, subject to the
         * `normalizeSelection` and `isSelectable` settings, and provided they where selected.
         *
         * @param   to
         *          The element to unselect up to and including, observing `route` order.
         *
         * @param   from
         *          Optional. The element to unselect from, including. If `null`, and a suitable
         *          "...Anchor" exists within `globalSelectionMap`, that will be used instead.
         *          If no anchor exists, the current `SelectableDataElement` will be assumed.
         */
        public function unselectRange(to:SelectableDataElement, from:SelectableDataElement = null):void {
            var rangeSet:Array = _buildRangeSet(to,
                    from || (_isUsingHighAnchor ? _globalSelectionMap.highAnchor : _globalSelectionMap.lowAnchor) || this
                );
            unselect.apply(this, rangeSet);
        }

        /**
         * Removes any selection across the entire hierarchy of the current `SelectableDataElement` instance.
         */
        public function clearSelection():void {
            var unselected:Array = [];
            if (_globalSelectionMap) {
                delete _globalSelectionMap.lowAnchor;
                delete _globalSelectionMap.highAnchor;
            }

            var unselectRoutes:Array = Objects.getKeys(_globalSelectionMap);
            if (unselectRoutes.length) {
                for (var i:int = 0; i < unselectRoutes.length; i++) {
                    var route:String = unselectRoutes[i];
                    var selEl:SelectableDataElement = _globalSelectionMap[route];
                    selEl._isSelected = false;
                    unselected.push(selEl);
                    delete _globalSelectionMap[route];
                }
                _reportChanges(null, unselected);
            }
        }

        /**
         * Reports to the outside world what changed in the hierarchy of the current element's root, from
         * a selection point of view.
         *
         * @param   selectionAnchor
         *          A `SelectableDataElement` instance to be considered the "selection anchor", a single
         *          selected element the user can leverage to construct selection ranges from. Can be
         *          `null` (to indicate there is no selection across the entire hierarchy).
         *
         * @param   unselected
         *          Optional Array with `SelectableDataElement` instances that have been unselected.
         *
         * @param   selected
         *          Optional Array with `SelectableDataElement` instances that have been selected.
         */
        protected function _reportChanges(selectionAnchor:SelectableDataElement, unselected:Array = null, selected:Array = null):void {
            dispatchEvent(new SelectableDataEvent(SelectableDataEvent.REPORT, selectionAnchor, unselected, selected));
        }

        /**
         * Rewrites the given `rawSet` Array the way that elements found at different levels in the hierarchy
         * are "normalized" to their deeper descendants. The exact level of the normalization is given by the
         * most deeply nested of the provided elements. Returns the rewritten set.
         *
         * @param   rawSet
         *          Original, non-normalized Array of `SelectableDataElement` instances.
         *
         * @return  Normalized Array with `SelectableDataElement` instances.
         */
        protected function _doNormalization(rawSet:Array):Array {

            // Normalization makes no sense for lone elements or empty sets.
            if (rawSet.length < 2) {
                return rawSet;
            }

            // Sort elements, ancestors before descendants, earlier sibling before later sibling,
            // in depth-first-traversal order.
            var normalizedSet:Array = [];
            var sortedSet:Array = rawSet.concat();
            sortedSet.sort(_compareRoutes);

            // Get a hold of the highest level any of the sorted elements has. This is the
            // most deeply nested element among all received.
            var highestLevel:int = 0;
            for (var i:int = 0; i < sortedSet.length; i++) {
                var testEl:SelectableDataElement = sortedSet[i];
                var testLevel:int = testEl.level;
                if (testLevel > highestLevel) {
                    highestLevel = testLevel;
                }
            }

            // Find the closest common ancestor we can use as for traversal.
            var commonAncestorEl:SelectableDataElement = _getCommonAncestorOf(sortedSet);

            // Normalize to the highest level available by traversing the reference and only retaining
            // its descendants living at the highest level, and which relate to or are among the received,
            // original elements.
            commonAncestorEl.walk(function visitElement(testDescendantEl:SelectableDataElement):void {
                    if (testDescendantEl.level === highestLevel) {

                        // Descendant was already in the original set.
                        if (sortedSet.includes(testDescendantEl)) {
                            if (!normalizedSet.includes(testDescendantEl)) {
                                normalizedSet.push(testDescendantEl);
                            }
                            return;
                        }

                        // Descendant is a (grand)child of at least one of the elements in the original set.
                        var matchesOriginalEl:Boolean = sortedSet.some(
                                function checkElement(sortedElement:SelectableDataElement, ...ignore):Boolean {
                                    return testDescendantEl.route.indexOf(sortedElement.route) == 0;
                                }
                            );
                        if (matchesOriginalEl) {
                            if (!normalizedSet.includes(testDescendantEl)) {
                                normalizedSet.push(testDescendantEl);
                            }
                            return;
                        }
                    }
                });

            return normalizedSet;
        }

        /**
         * Performs an operation (selection or deselection) on the provided `elements`. This function is a
         * delegatee used by `select()` and `unselect()`.
         *
         * @param   type
         *          The type of operation to perform. One of `OP_SELECT` or `OP_UNSELECT`.
         *
         * @param   ...elements
         *          Array of SelectableDataElement instances to operate on see `select()` or `unselect()` for details.
         */
        protected function _doOperation(changeType:String, elements:Array):void {
            var selected:Array = [];
            var unselected:Array = [];
            var changedRoutes:Array = [];
            var thisRoot:SelectableDataElement = SelectableDataElement(this.root);
            var toChange:Array = (elements || []).concat();
            if (!toChange.length) {
                toChange.push(this);
            }
            toChange = toChange.filter(function callback(item:SelectableDataElement, ...ignore):Boolean {
                    var changeSpecificChecks:Boolean = (changeType == OP_SELECT) ?
                        item.isSelectable && !(item.route in _globalSelectionMap) :
                        (changeType == OP_UNSELECT) ?
                        item.route in _globalSelectionMap : true;
                    return (item && item.root && item.root === thisRoot && changeSpecificChecks);
                });

            if (_usesNormalization) {
                toChange = _doNormalization(toChange);
            }
            for (var i:int = 0; i < toChange.length; i++) {
                var elToChange:SelectableDataElement = toChange[i];
                var elRoute:String = elToChange.route;
                changedRoutes.push(elRoute);
                if (changeType == OP_SELECT) {
                    elToChange._isSelected = true;
                    selected.push(elToChange);
                    _globalSelectionMap[elRoute] = elToChange;
                }
                else if (changeType == OP_UNSELECT) {
                    elToChange._isSelected = false;
                    unselected.push(elToChange);
                    delete _globalSelectionMap[elRoute];
                }
            }
            if (changedRoutes.length) {
                if (changedRoutes.length > 1) {
                    changedRoutes.sort(Descriptor.multiPartComparison);
                    _globalSelectionMap.lowAnchor = _globalSelectionMap[changedRoutes[0]];
                    _globalSelectionMap.highAnchor = _globalSelectionMap[changedRoutes[changedRoutes.length - 1]];
                }
                else {
                    _globalSelectionMap.lowAnchor = _globalSelectionMap.highAnchor = _globalSelectionMap[changedRoutes[0]];
                }
            }
            _reportChanges(
                    (_isUsingHighAnchor ? _globalSelectionMap.highAnchor : _globalSelectionMap.lowAnchor) || null,
                    unselected.length ? unselected : null,
                    selected.length ? selected : null
                );
        }

        /**
         * Returns the flat list of all the `SelectableDataElement` instances that "live between" the given `to` and `from`,
         * within their common hierarchy. A depth-first traversal is used to produce the list, which will always proceed
         * from the *lower-index* element (higher in the hierarchy or an earlier sibling) to the *higher-index* one (lower
         * in the hierarchy, or a later sibling). If diverging, the resulting Array is then reversed to match the original
         * direction (`from` towards `to`).
         *
         * @param   to
         *          Terminus-point of the range.
         *
         * @param   from
         *          Starting point of the range.
         *
         * @return  Array with all elements of the range, including both ends. If `to` and `from` are identical, the Array
         *          contains a single element. Either is invalid (null, orphan, part of a different hierarchy), returned
         *          Array is empty.
         */
        protected function _buildRangeSet(to:SelectableDataElement, from:SelectableDataElement):Array {

            // Do an early exit if both ends are missing, both are orphaned or they belong to different hierarchies.
            if ((!to && !from) || (!to.root && !from.root) || to.root !== from.root) {
                return [];
            }

            // Do an early exit if only one end is valid (return it).
            var srcSet:Array = [];
            if (from && from.root) {
                srcSet.push(from);
            }
            if (to && to.root) {
                srcSet.push(to);
            }
            if (srcSet.length === 1) {
                return [srcSet[0]];
            }

            // If ends were given in reverse order, temporarily change that.
            var sortedSet:Array = srcSet.concat().sort(_compareRoutes);
            var mustReverseOutput:Boolean = (sortedSet[0] !== srcSet[0]);

            // Walk the closest common ancestor and register all interim elements, including both
            // ends.
            var output:Array = [];
            var $c:Object = {mustAdd: false};
            var commonAncestorEl:SelectableDataElement = _getCommonAncestorOf(sortedSet);
            commonAncestorEl.walk(function visitElement(testDescendantEl:SelectableDataElement):void {
                    if (testDescendantEl == sortedSet[0]) {
                        $c.mustAdd = true;
                    }
                    if ($c.mustAdd) {
                        output.push(testDescendantEl);
                    }
                    if (testDescendantEl == sortedSet[1]) {
                        $c.mustAdd = false;
                    }
                });

            // Ensure returned elements flow in the original direction.
            if (mustReverseOutput) {
                output.reverse();
            }
            return output;
        }

        /**
         * Gets the element that is the closest (grand)parent of all given (grand)child elements.
         *
         * @param   elements
         *          Array of `SelectableDataElement` instances.
         *
         * @return  A `SelectableDataElement` instance that is the closest common ancestor of all
         *          provided `elements`. Falls back to `root` if a better common ancestor
         *          cannot be determined.
         */
        protected function _getCommonAncestorOf(elements:Array):SelectableDataElement {

            // Get all routes and sort them lexicographically.
            var routes:Array = elements.map(
                    function callback(element:SelectableDataElement, ...ignore):String {
                        return element.route;
                    }
                );
            routes.sort();

            // Get the shortest common prefix.
            var firstRoute:String = routes[0];
            var lastRoute:String = routes[routes.length - 1];
            var i:int = 0;
            while (i < firstRoute.length && firstRoute.charAt(i) === lastRoute.charAt(i)) {
                i++;
            }
            var commonPrefix:String = firstRoute.substring(0, i);
            if (!commonPrefix) {
                trace('SelectableDataElement: `_getCommonAncestorOf()` - could not find common prefix of [',
                        firstRoute, ',', lastRoute, ']. Using root instead.');
                return SelectableDataElement(root);
            }
            if (Strings.endsWith(commonPrefix, '_')) {
                commonPrefix = commonPrefix.slice(0, -1);
            }

            // Return the element whose `route` matches the common prefix.
            var commonAncestor:DataElement = getElementByRoute(commonPrefix);
            if (!commonAncestor) {
                trace('SelectableDataElement: `_getCommonAncestorOf()` - route "', commonPrefix,
                        '" did not resolve. Using root instead.');
            }
            return SelectableDataElement(commonAncestor || root);
        }

        /**
         *
         * Array sort callback function. Sorts an Array of `SelectableDataElement` instances by their `route`,
         * placing ancestors before their descendants, in the order of a depth-first traversal.
         *
         * @param   elA Element to compare.
         * @param   elB Element to compare with.
         *
         * @return  Positive integer if `elA` compares "greater than" `elB` (i.e., lower in hierarchy);
         *          negative integer if `elA` compares "less than" `elB` (i.e., higher in hierarchy);
         *          and 0 if they compare "equal" (i.e., same hierarchic position in different hierarchies,
         *          or the exact same element within the same hierarchy).
         *
         * @see     Array.prototype.sort
         */
        protected function _compareRoutes(elA:SelectableDataElement, elB:SelectableDataElement):int {
            return Descriptor.multiPartComparison(elA.route, elB.route);
        }
    }
}
