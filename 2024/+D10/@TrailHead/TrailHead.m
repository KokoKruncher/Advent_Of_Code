classdef TrailHead < handle
    properties (SetAccess = private)
        peaksReachable (:,:) logical
        topographicMap (:,:) double
        mapSize (1,2) double
        pathNum (1,1) double = 0
        nPathsToPeaks (1,1) double = 0
        locationsTravelled (:,2) double
        nLocationsTravelled (1,1) double = 0;
    end
    

    methods
        function self = TrailHead(topographicMap)
            mapSize = size(topographicMap);
            self.topographicMap = topographicMap;
            self.mapSize = mapSize;
            self.peaksReachable = false(mapSize);
            self.locationsTravelled = nan(numel(topographicMap),2);
        end
        
        traverse(self,location,direction)

        function score = calculateScore(self)
            score = sum(self.peaksReachable,"all");
        end
    end


    methods (Access = private)
        function isPeak = checkIfLocationIsPeak(self,location)
            row = location(1);
            col = location(2);
            height = self.topographicMap(row,col);
            if height == 9
                isPeak = true;
            else
                isPeak = false;
            end
        end

        function addPeak(self,location)
            row = location(1);
            col = location(2);
            self.peaksReachable(row,col) = true;
            self.nPathsToPeaks = self.nPathsToPeaks + 1;
        end

        function isDirectionValid = checkDirection(self,location,direction)
            newLocation = location + direction;
            isDirectionValid = false;

            isNewLocationInBounds = self.checkIfLocationIsInBounds(newLocation);
            if ~isNewLocationInBounds
                return
            end

            isSlopeGradualUphill = self.checkIfSlopeIsGradualUphill(location,newLocation);
            if ~isSlopeGradualUphill
                return
            end

            isDirectionValid = true;
        end

        function isLocationInBounds = checkIfLocationIsInBounds(self,location)
            if location(1) < 1 || location(1) > self.mapSize(1) || ...
                    location(2) < 1 || location(2) > self.mapSize(2)
                isLocationInBounds = false;
            else
                isLocationInBounds = true;
            end
        end

        function isSlopeGradualUphill = checkIfSlopeIsGradualUphill(self,location,newLocation)
            currentRow = location(1);
            currentCol = location(2);
            currentHeight = self.topographicMap(currentRow,currentCol);

            newRow = newLocation(1);
            newCol = newLocation(2);
            newHeight = self.topographicMap(newRow,newCol);

            slope = newHeight - currentHeight;
            if slope == 1
                isSlopeGradualUphill = true;
            else
                isSlopeGradualUphill = false;
            end
        end
    end


    methods (Static)
        function newDirection = rotateDirection(direction,nTimes)
            % rotates direction by 90 degrees clockwise
            rotationMatrix = [0, 1; -1, 0];
            newDirection = ((rotationMatrix^nTimes)*direction')';
        end
    end
end

