classdef Set < handle & matlab.mixin.Scalar
    % Imitates python sets. Not vectorised, to simplify interface for cells.
    properties (Access = private)
        dict dictionary = dictionary()
    end


    methods
        function add(self, value)
            value = self.parseInputValue(value);
            self.dict(value) = true;
        end


        function remove(self, value)
            if ~self.dict.isConfigured
                return
            end

            value = self.parseInputValue(value);
            self.dict.remove(value);
        end


        function tf = contains(self, value)
            tf = false;

            if ~self.dict.isConfigured
                return
            end
            
            value = self.parseInputValue(value);
            tf = self.dict.isKey(value);
        end


        function out = numEntries(self)
            out = self.dict.numEntries();
        end


        function out = listContents(self)
            out = self.dict.keys();
        end
    end


    methods (Static, Access = private)
        function value = parseInputValue(value)
            if numel(value) > 1
                value = {value};
            end
        end
    end
end