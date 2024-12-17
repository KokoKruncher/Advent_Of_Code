classdef Guard < handle
    properties (SetAccess = private)
        position (1,2) double
        direction (1,2) double = [-1, 0] % up by default
        isInBounds (1,1) logical = true
        stepsTaken (1,1) double = 0
    end

    properties (Dependent)
        nextPosition (1,2) double
    end

    methods
        function obj = Guard(position)
            arguments
                position = nan(1,2)
            end
            obj.position = position;
        end

        function nextPosition = get.nextPosition(self)
            nextPosition = self.position + self.direction;
        end

        function rotate90DegClockwise(self)
            rotationMatrix = [0, 1; -1, 0];
            currentDirection = self.direction;
            newDirection = rotationMatrix*currentDirection';
            self.direction = newDirection';
        end

        function step(self)
            self.position = self.nextPosition;
            self.stepsTaken = self.stepsTaken + 1;
        end

        function updateInBoundsStatus(self,mapGridSize)
            arguments
                self (1,1) D6.Guard
                mapGridSize (1,2) double
            end
            row = self.position(1);
            col = self.position(2);
            if row < 1 || row > mapGridSize(1) || col < 1 || col > mapGridSize(2)
                self.isInBounds = false;
            end
        end
    end
end


