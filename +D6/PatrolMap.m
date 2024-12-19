classdef PatrolMap < handle
    properties (SetAccess = private)
        grid (:,:) {mustBeA(grid,'string')} = ""
        gridSize (:,:) double
        guard (1,1) D6.Guard
        obstacles logical
        pathWalked logical
        previousDirections cell
    end
    
    methods
        function self = PatrolMap(args)
            arguments
                args.data = [];
                args.grid = [];
            end
            if ~isempty(args.grid) && ~isempty(args.data)
                error("Only assign either data or grid")
            end

            if isempty(args.grid) && isempty(args.data)
                error("Neither data nor grid assigned")
            end

            if ~isempty(args.grid)
                self.grid = args.grid;
            else
                self.grid = self.formatData(args.data);
            end
  
            self.gridSize = size(self.grid);
            self.previousDirections = cell(self.gridSize);

            initialGuardPosition = self.findInitialPosition();
            self.guard = D6.Guard(initialGuardPosition);

            self.obstacles = self.grid == "#";
            self.pathWalked = false(self.gridSize);
            
            % fill in data for starting position
            rowIndx = initialGuardPosition(1);
            colIndx = initialGuardPosition(2);
            self.updatePathWalked(rowIndx,colIndx);
            self.updatePreviousDirections(rowIndx,colIndx);
        end


        function initialPosition = findInitialPosition(self)
            % "^" is the starting position
            linearIndx = find(self.grid == "^");
            assert(numel(linearIndx) == 1,"Multiple guards found.")

            [row,col] = ind2sub(self.gridSize,linearIndx);
            initialPosition = [row, col];
        end


        function updatePathWalked(self,rowIndx,colIndx)
            self.pathWalked(rowIndx,colIndx) = true;
        end


        function updatePreviousDirections(self,rowIndx,colIndx)
            directionsAtThisPoint =  self.previousDirections(rowIndx,colIndx);
            directionsAtThisPoint{1}{end+1} = self.guard.direction;
            self.previousDirections(rowIndx,colIndx) = directionsAtThisPoint;
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


        function hasBeenWalkedBefore = checkIfPreviouslyWalked(self,rowIndx,colIndx)
            hasBeenWalkedBefore = self.pathWalked(rowIndx,colIndx);
        end


        function step(self)
            if self.guard.isInLoop
                warning("Guard is in loop, not moving.")
                return
            end
            
            if ~self.guard.isInBounds
                warning("Guard is out of bounds, not moving.")
                return
            end

            % check if next position is obstacle
            while self.checkForObstacles()
                self.guard.rotate90DegClockwise();
            end

            self.guard.step();
            rowIndx = self.guard.position(1);
            colIndx = self.guard.position(2);
            
            self.guard.checkIfInBounds(self.gridSize);
            if ~self.guard.isInBounds
                return
            end
            
            hasBeenWalkedBefore = self.checkIfPreviouslyWalked(rowIndx,colIndx);
            if hasBeenWalkedBefore
                previousDirectionsAtThisPoint = self.previousDirections(rowIndx,colIndx);
                self.guard.checkIfInLoop(previousDirectionsAtThisPoint);
            end
            
            self.updatePathWalked(rowIndx,colIndx);
            self.updatePreviousDirections(rowIndx,colIndx);
        end


        function gridWithDirectionSymbols = makeGridWithDirectionSymbols(self)
            gridWithDirectionSymbols = self.grid;
            nGridPositions = numel(gridWithDirectionSymbols);
            for indx = 1:nGridPositions
                if ~self.pathWalked(indx)
                    continue
                end
                directions = self.previousDirections{indx};
                lastDirection = directions{end};

                if all(lastDirection == [-1 0],'all')
                    symbol = "^";
                elseif all(lastDirection == [0 1],'all')
                    symbol = ">";
                elseif all(lastDirection == [1 0],'all')
                    symbol = "v";
                elseif all(lastDirection == [0 -1],'all')
                    symbol = "<";
                else
                    error("Unknown direction.")
                end
                gridWithDirectionSymbols(indx) = symbol;
            end
        end


        function exportGrid(self,args)
            arguments
                self (1,1) D6.PatrolMap
                args.bUseDirectionSymbols (1,1) logical = true
            end
            
            if args.bUseDirectionSymbols
                gridWithPathWalked = self.makeGridWithDirectionSymbols;
            else
                gridWithPathWalked = self.grid;
                gridWithPathWalked(self.pathWalked) = "X";
            end
            initialPosition = self.guard.initialPosition;
            initialRow = initialPosition(1);
            initialCol = initialPosition(2);
            gridWithPathWalked(initialRow,initialCol) = "O";
            
            if ~isfolder("Outputs")
                mkdir("Outputs")
            end
            writematrix(gridWithPathWalked,"Outputs/D6_Part1.txt")
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

