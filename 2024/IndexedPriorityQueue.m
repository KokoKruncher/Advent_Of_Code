classdef IndexedPriorityQueue < handle & matlab.mixin.Scalar
    % INDEXEDPRIORITYQUEUE Priority queue with update capability. Binary heap implementation.
    % Reference:
    % https://youtu.be/jND_WJ8r7FE?si=INXIypW3t8Hq-fvf

    properties (SetAccess = private, GetAccess = public)
        size
    end


    properties (Dependent)
        arraySize
    end


    properties (Access = private)
        initialCapacity (1,1) {mustBeInteger, mustBeGreaterThan(initialCapacity, 4)} = 5
        capacity
        availableKeyIndices

        keyToKeyIndexMap
        keyIndexToKeyMap

        % values(keyIndex) = priority value of the key represented by keyIndex
        values

        % keyIndexToNodeIndex(keyIndex) = index of node in the heap for the given key
        keyIndexToNodeIndex

        % nodeIndexToKeyIndex(nodeIndex) = key index for the given node
        nodeIndexToKeyIndex

        bSkipContainsCheckOnce = false
    end

    %% Public interface
    methods
        function self = IndexedPriorityQueue(initialCapacity)
            if nargin > 0
                self.initialCapacity = initialCapacity;
            end

            self.reset();
        end


        function push(self, key, priority)
            if self.size > 1 && self.contains_(key)
                error("Key already exists in queue! To update the priority of this key, call update() instead.");
            end

            assert(isfinite(priority), "Priority must be finite!");

            self.size = self.size + 1;

            if self.size > self.capacity
                self.capacity = 2 * self.capacity;
                self.availableKeyIndices = [(self.capacity:-1:self.size), self.availableKeyIndices];
            end

            keyIndex = self.availableKeyIndices(end);

            self.keyToKeyIndexMap(key) = keyIndex;
            self.keyIndexToKeyMap(keyIndex) = key;
            self.values(keyIndex) = priority;

            self.keyIndexToNodeIndex(keyIndex) = self.size;
            self.nodeIndexToKeyIndex(self.size) = keyIndex;

            self.availableKeyIndices = self.availableKeyIndices(1:end-1);
            self.swim(self.size);
        end


        function [key, priority] = pop(self)
            if self.size < 1
                error("Queue is empty!");
            end

            [key, priority] = self.removeNode(1);
        end


        function [key, priority] = peek(self)
            if self.size < 1
                error("Queue is empty!");
            end

            keyIndex = self.nodeIndexToKeyIndex(1);
            key = self.keyIndexToKeyMap(keyIndex);
            priority = self.values(keyIndex);
        end

        
        function update(self, key, newPriority)
            assert(isscalar(key));

            if ~self.contains_(key)
                error("Key to be updated is not in queue!");
            end

            assert(isscalar(newPriority));
            assert(isfinite(newPriority), "Priority must be finite!");

            keyIndex = self.keyToKeyIndexMap(key);
            self.values(keyIndex) = newPriority;
            
            nodeIndex = self.keyIndexToNodeIndex(keyIndex);
            self.swim(nodeIndex);
            self.sink(nodeIndex);
        end


        function pushOrDecrease(self, key, priority)
            if ~self.contains_(key)
                self.bSkipContainsCheckOnce = true;
                self.push(key, priority);
                return
            end

            keyIndex = self.keyToKeyIndexMap(key);
            oldPriority = self.values(keyIndex);

            if oldPriority <= priority
                return
            end

            self.update(key, priority);
        end


        function pushOrIncrease(self, key, priority)
            if ~self.contains_(key)
                self.push(key, priority);
                return
            end

            keyIndex = self.keyToKeyIndexMap(key);
            oldPriority = self.values(keyIndex);

            if oldPriority >= priority
                return
            end

            self.update(key, priority);
        end
        

        function varargout = remove(self, key)
            assert(isscalar(key), "Can only remove 1 key at a time.");
            
            if ~self.contains_(key)
                error("Key to be removed is not in the queue!")
            end

            keyIndex = self.keyToKeyIndexMap(key);
            nodeIndex = self.keyIndexToNodeIndex(keyIndex);

            [key, priority] = self.removeNode(nodeIndex);
            varargout{1} = key;
            varargout{2} = priority;
        end


        function tf = contains(self, key)
            tf = self.keyToKeyIndexMap.isKey(key);
        end


        function tf = hasElements(self)
            tf = self.size > 0;
        end


        function reset(self)
            self.keyToKeyIndexMap = dictionary();
            self.keyIndexToKeyMap = dictionary();

            self.size = 0;
            self.capacity = self.initialCapacity;
            self.availableKeyIndices = (self.initialCapacity:-1:1);
            self.values = Inf(self.initialCapacity, 1);
            self.keyIndexToNodeIndex = nan(self.initialCapacity, 1);
            self.nodeIndexToKeyIndex = nan(self.initialCapacity, 1);
            self.bSkipContainsCheckOnce = false;
        end


        function debug(self)
            vals = self.values(:).';
            pm = self.keyIndexToNodeIndex(:).';
            im = self.nodeIndexToKeyIndex(:).';

            % To zero-based indexing
            print(vals, "vals");
            print(pm - 1, "pm  ");
            print(im - 1, "im  ");

            % Nested functions
            function print(array, name)
                arrayWidth = width(array);
                formatSpec = join(repmat("%i", 1, arrayWidth), " ");

                fprintf(1, "%s: " + formatSpec + "\n", name, array);
            end
        end
    end

    %% Private implementation
    methods (Access = private)
        function tf = contains_(self, key)
            % Internal contains() method, which can be skipped once if the key was already checked by the calling
            % method, therefore eliminaing duplicate contains() calls when going from
            % pushOrDecrease()/pushOrIncrease() -> push()
            if ~self.bSkipContainsCheckOnce
                tf = self.keyToKeyIndexMap.isKey(key);
            else
                tf = false;
                self.bSkipContainsCheckOnce = false;
            end
        end


        function [key, priority] = removeNode(self, nodeIndex)
            keyIndex = self.nodeIndexToKeyIndex(nodeIndex);
            self.availableKeyIndices(end + 1) = keyIndex;

            key = self.keyIndexToKeyMap(keyIndex);
            priority = self.values(keyIndex);

            self.keyIndexToKeyMap(keyIndex) = [];
            self.keyToKeyIndexMap(key) = [];

            self.swap(nodeIndex, self.size);
            self.nodeIndexToKeyIndex(self.size) = nan;
            self.keyIndexToNodeIndex(keyIndex) = nan;
            self.size = self.size - 1;

            if self.size < 1
                return
            end

            self.swim(nodeIndex);
            self.sink(nodeIndex);
        end


        function swim(self, nodeIndex)
            value = self.getNodeValue(nodeIndex);
            % parentNodeIndex = floor(nodeIndex / 2);
            parentNodeIndex = self.parent(nodeIndex);
            while nodeIndex > 1 && self.getNodeValue(parentNodeIndex) > value
                self.swap(nodeIndex, parentNodeIndex);

                nodeIndex = parentNodeIndex;
                % parentNodeIndex = floor(nodeIndex / 2);
                parentNodeIndex = self.parent(nodeIndex);
            end
        end


        function sink(self, nodeIndex)
            value = self.getNodeValue(nodeIndex);
            [smallestChildNodeIndex, smallestChildNodeValue, hasChild] = self.findSmallestChild(nodeIndex);
            while hasChild && smallestChildNodeValue < value
                self.swap(nodeIndex, smallestChildNodeIndex);
                nodeIndex = smallestChildNodeIndex;
                [smallestChildNodeIndex, smallestChildNodeValue, hasChild] = self.findSmallestChild(nodeIndex);
            end
        end


        function swap(self, nodeIndex1, nodeIndex2)
            if nodeIndex1 == nodeIndex2
                return
            end

            keyIndex1 = self.nodeIndexToKeyIndex(nodeIndex1);
            keyIndex2 = self.nodeIndexToKeyIndex(nodeIndex2);

            self.keyIndexToNodeIndex(keyIndex1) = nodeIndex2;
            self.keyIndexToNodeIndex(keyIndex2) = nodeIndex1;

            self.nodeIndexToKeyIndex(nodeIndex1) = keyIndex2;
            self.nodeIndexToKeyIndex(nodeIndex2) = keyIndex1;

        end


        function out = getNodeValue(self, nodeIndex)
            keyIndex = self.nodeIndexToKeyIndex(nodeIndex);
            out = self.values(keyIndex);
        end


        function [smallestChildNodeIndex, smallestChildNodeValue, hasChild] = findSmallestChild(self, nodeIndex)
            hasChild = true;
            smallestChildNodeIndex = nan;
            smallestChildNodeValue = nan;
            
            childNodeIndices = [self.leftChild(nodeIndex), self.rightChild(nodeIndex)];
            isChildInBounds = self.isInBounds(childNodeIndices);
            nChildrenInBounds = nnz(isChildInBounds);
            
            if nChildrenInBounds == 0
                hasChild = false;
                return
            end

            if nChildrenInBounds == 1
                smallestChildNodeIndex = childNodeIndices(isChildInBounds);
                smallestChildNodeValue = self.getNodeValue(smallestChildNodeIndex);
                return
            end

            % Uncomment if changing from binary heap to heap where nodes have >2 children
            % childNodeIndices = childNodeIndices(isChildInBounds);

            % This for-loop avoids overhead of min() function
            childNodeValues = self.getNodeValue(childNodeIndices);
            iSmallestChild = 1;
            for ii = 2:numel(childNodeIndices)
                if childNodeValues(ii) < childNodeValues(iSmallestChild)
                    iSmallestChild = ii;
                end
            end
        end


        function tf = isInBounds(self, nodeIndex)
            tf = nodeIndex <= self.size;
        end
    end


    methods (Static, Access = private)
        function parentNodeIndex = parent(nodeIndex)
            parentNodeIndex = floor(nodeIndex / 2);
        end


        function leftChildNodeIndex = leftChild(nodeIndex)
            leftChildNodeIndex = 2 * nodeIndex;
        end


        function rightChildNodeIndex = rightChild(nodeIndex)
            rightChildNodeIndex = 2 * nodeIndex + 1;
        end
    end

    %% Getters
    methods
        function out = get.arraySize(self)
            out = numel(self.values);
        end
    end
end