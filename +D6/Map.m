classdef Map < handle
    properties (SetAccess = private)
        grid
        gridSize (:,:) double
        guard (1,1) D6.Guard
        obstacles logical
        pathWalked logical
    end
    
    methods
        function self = Map(data)
            self.grid = self.formatData(data);
            self.gridSize = size(self.grid);

            guardPosition = self.findInitialPosition();
            self.guard = D6.Guard(guardPosition);

            self.obstacles = self.grid == "#";
            self.pathWalked = false(self.gridSize);
            self.updatePathWalked();
        end

        function initialPosition = findInitialPosition(self)
            % "^" is the starting position
            linearIndx = find(self.grid == "^");
            assert(numel(linearIndx) == 1,"Multiple guards found.")

            [row,col] = ind2sub(self.gridSize,linearIndx);
            initialPosition = [row, col];
        end

        function updatePathWalked(self)
            rowIndx = self.guard.position(1);
            colIndx = self.guard.position(2);
            self.pathWalked(rowIndx,colIndx) = true;
        end

        function nextPositionIsObstacle = checkForObstacles(self)
            row = self.guard.nextPosition(1);
            col = self.guard.nextPosition(2);

            % check if next position is in bounds
            if row < 1 || row > self.gridSize(1) || col < 1 || col > self.gridSize(2)
                nextPositionIsObstacle = false;
                return
            end

            nextPositionIsObstacle = self.obstacles(row,col);
        end

        function step(self)
            % check if guard is in bounds
            if ~self.guard.isInBounds
                warning("Guard is out of bounds, not moving.")
                return
            end

            % check if next position is obstacle
            while self.checkForObstacles()
                self.guard.rotate90DegClockwise();
            end

            self.guard.step();
            self.guard.updateInBoundsStatus(self.gridSize);
            if self.guard.isInBounds
                self.updatePathWalked();
            end
        end

        function exportGrid(self)
            gridWithPathWalked = self.grid;
            gridWithPathWalked(self.pathWalked) = "X";

            if ~isfolder("Outputs")
                mkdir("Outputs")
            end
            writematrix(gridWithPathWalked,"Outputs/D5_Part1.txt")
        end
    end

    methods (Static)
        function grid = formatData(data)
            assert(isstring(data) && iscolumn(data), ...
                "Excpecting column vector of strings.")

            dataLength = unique(strlength(data));
            assert(numel(dataLength) == 1, ...
                "All rows must have the same length to be made into grid.")

            % form grid of single strings
            grid = split(data,"");
            grid = grid(:,2:end-1);
            assert(all(strlength(grid) == 1,'all'))
        end
    end
end

