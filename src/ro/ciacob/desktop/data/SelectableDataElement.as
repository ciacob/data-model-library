package ro.ciacob.desktop.data {

    import ro.ciacob.utils.Objects;
    import ro.ciacob.utils.Descriptor;

    public class SelectableDataElement extends DataElement {
        private static const OP_SELECT:String = 'select';
        private static const OP_UNSELECT:String = 'unselect';

        private var _usesNormalization:Boolean;
        private var _isSelected:Boolean;
        private var _isSelectable:Boolean;
        private var _isUsingHighAnchor:Boolean;
        private var _globalSelectionMap:Object;

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
        private function _reportChanges(selectionAnchor:SelectableDataElement, unselected:Array = null, selected:Array = null):void {
            // TBD: use a custom Event to dispatch this information (make the class an IEventDispatcher implementor).
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
        private function _doNormalization(rawSet:Array):Array {
            // TODO: implement
            return rawSet;
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
        private function _doOperation(changeType:String, elements:Array):void {
            var selected:Array = [];
            var unselected:Array = [];
            var changedRoutes:Array = [];
            var thisRoot:SelectableDataElement = SelectableDataElement(this.root);
            var toChange:Array = elements.concat();
            if (!toChange.length) {
                toChange.push(this);
            }
            toChange = toChange.filter(function callback(item:SelectableDataElement, ...ignore):Boolean {
                    var changeSpecificChecks:Boolean = (changeType == OP_SELECT) ?
                        item.isSelectable && !(item.route in _globalSelectionMap) :
                        (changeType == OP_UNSELECT) ?
                        item.route in _globalSelectionMap : true;
                    return (item && item.dataParent && item.root === thisRoot && changeSpecificChecks);
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
                    unselected.length ? unselected : null
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
        private function _buildRangeSet(to:SelectableDataElement, from:SelectableDataElement):Array {
            // TODO: implement
            return [from, to];
        }
    }
}
