classdef PriorityQueue < handle & matlab.mixin.Scalar
    properties
        initialSize (1,1) double {mustBeGreaterThan(initialSize, 10)} = 20
        values (:,1) cell
        priorities (:,1) double
        size (1,1) double = 0
        index (1,1) double = 0
    end


    methods
        function self = PriorityQueue(initialSize)
            if nargin > 0
                self.initialSize = initialSize;
            else
                initialSize = self.initialSize;
            end

            self.values = cell(initialSize, 1);
            self.priorities = Inf(initialSize, 1);
        end


        function push(self, value, priority)
            oldIndex = self.index;
            newIndex = oldIndex + 1;
            self.priorities(newIndex) = priority;
            self.values{newIndex} = value;
            self.index = newIndex;
            self.size = self.size + 1;
        end


        function pushMultiple(self, values, priorities)
            arguments
                self PriorityQueue
                values cell
                priorities double
            end
            nValues = numel(values);
            nPriorities = numel(priorities);
            if nValues ~= nPriorities
                error("Number of values and priorities need to be the same.")
            end

            oldIndex = self.index;
            newIndex = oldIndex + nValues;
            self.priorities(oldIndex + 1 : newIndex) = priorities(:);
            [self.values{oldIndex + 1 : newIndex}] = values{:};
            self.index = newIndex;
            self.size = self.size + nValues;

        end


        function [value, priority]= pop(self)
            if self.size < 1
                error("Priority queue is empty!");
            end

            [priority, iMinPriority] = min(self.priorities);
            value = self.values{iMinPriority};
            self.priorities(iMinPriority) = Inf;
            self.size = self.size - 1;
        end


        function [value, priority] = peek(self)
            if self.size < 1
                error("Priority queue is empty!");
            end

            [priority, iMinPriority] = min(self.priorities);
            value = self.values{iMinPriority};
        end


        function tf = hasElements(self)
            tf = self.size >= 1;
        end
    end
end