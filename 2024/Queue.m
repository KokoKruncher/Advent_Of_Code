classdef Queue < handle & matlab.mixin.Scalar
    properties
        data % (:,1) double
        iFirst = nan % (1,1) double = nan
        iLast = nan % (1,1) double = nan
        initialSize (1,1) double {mustBeGreaterThanOrEqual(initialSize, 10)} = 20
    end

    properties (Dependent)
        capacity
        size
    end

    methods (Access = public)
        function self = Queue(initialSize)
            arguments
                initialSize = 20
            end
            self.initialSize = initialSize;
            self.data = cell(initialSize, 1);
        end


        function append(self, vals)
            if isnan(self.iLast)
                self.iFirst = 1;
                self.iLast = 0;
            end
            
            newLastIndex = self.iLast + 1;

            if newLastIndex >= self.capacity
                self.expand(newLastIndex);
                newLastIndex = self.iLast + 1;
            end


            newDataIndx = (self.iLast + 1):newLastIndex;
            self.data{newDataIndx} = vals;
            self.iLast = newLastIndex;
        end


        function val = pop(self)
            val = self.peek();

            if self.iFirst == self.iLast
                self.softReset();
                return
            end
            self.iFirst = self.iFirst + 1;
            
            if self.iFirst > floor(self.capacity / 3)
                self.shiftForwards();
            end
        end


        function val = peek(self)
            if isnan(self.iFirst)
                error("Queue is empty!")
            end
            
            val = self.data{self.iFirst};
        end


        function tf = hasElements(self)
            tf = self.size > 0;
        end


        function hardReset(self)
            self.data = cell(self.initialSize, 1);
            self.iFirst = nan;
            self.iLast = nan;
        end
    end


    methods (Access = private)
        function softReset(self)
            self.iFirst = nan;
            self.iLast = nan;
        end


        function shiftForwards(self)
            % fprintf("Shuffling forward.\n")
            spacesToShift = self.iFirst - 1;
            self.data(1:self.iFirst-1) = [];
            self.iFirst = self.iFirst - spacesToShift;
            self.iLast = self.iLast - spacesToShift;
        end


        function expand(self, newLastIndex)
            % fprintf("Expanding.\n")
            requiredCapacity = newLastIndex - self.iFirst + 1;
            currentCapacity = self.capacity;
            
            if currentCapacity > 1.5 * requiredCapacity
                self.shiftForwards();
                return
            end
            
            oldSize = self.size;
            newCapacity = ceil(requiredCapacity * 1.5);
            oldData = self.data(self.iFirst:self.iLast);
            self.data = cell(newCapacity, 1);
            self.data(1:oldSize) = oldData;
            self.iFirst = 1;
            self.iLast = oldSize;
        end
    end


    methods
        function out = get.capacity(self)
            out = numel(self.data);
        end


        function out = get.size(self)
            out = self.iLast - self.iFirst + 1 ;
        end
    end
end