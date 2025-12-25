classdef ObjectPriorityQueue < handle & matlab.mixin.Scalar
    properties
        initialSize double {mustBeScalarOrEmpty, mustBeGreaterThan(initialSize, 10)}

        % No validators on below properties as they tank speed
        values
        priorities
        size = 0
        index = 0
    end


    methods
        function self = ObjectPriorityQueue(classObject, initialSize)
            arguments
                classObject (1,1) meta.class
                initialSize (1,1) double = 20
            end
            objectConstructor = str2func(classObject.Name);
            object = objectConstructor();
            % assert(~isa(object, "handle"), "Objects stored in the priority queue must not be handle objects.");

            self.initialSize = initialSize;

            if isa(object, "matlab.mixin.Copyable")
                tempValues(initialSize) = object.copy();
                tempValues = reshape(tempValues, [], 1);
                self.values = tempValues;
            else
                self.values = repmat(object, initialSize, 1);
            end
            
            self.priorities = Inf(initialSize, 1);
        end


        function push(self, value, priority)
            oldIndex = self.index;
            newIndex = oldIndex + 1;
            self.priorities(newIndex) = priority;
            self.values(newIndex) = value;
            self.index = newIndex;
            self.size = self.size + 1;
        end


        function pushMultiple(self, values, priorities)
            arguments
                self ObjectPriorityQueue
                values
                priorities double
            end
            nValues = numel(values);
            nPriorities = numel(priorities);
            if nValues ~= nPriorities
                error("Number of values and priorities need to be the same.")
            end

            oldIndex = self.index;
            newIndex = oldIndex + nValues;
            self.values(oldIndex + 1 : newIndex) = reshape(values, [], 1);
            self.priorities(oldIndex + 1 : newIndex) = priorities(:);
            self.index = newIndex;
            self.size = self.size + nValues;

        end


        function [value, priority] = pop(self)
            if self.size < 1
                error("Priority queue is empty!");
            end

            [priority, iMinPriority] = min(self.priorities);
            value = self.values(iMinPriority);
            self.priorities(iMinPriority) = Inf;
            self.size = self.size - 1;
        end


        function [value, priority] = peek(self)
            if self.size < 1
                error("Priority queue is empty!");
            end

            [priority, iMinPriority] = min(self.priorities);
            value = self.values(iMinPriority);
        end


        function tf = hasElements(self)
            tf = self.size >= 1;
        end
    end
end