import math
import time

def calculateDistance(position1, position2):
    squareDistance = 0
    for coord1, coord2 in zip(position1, position2):
        squareDistance += (coord1 - coord2) ** 2
    return math.sqrt(squareDistance)


class JunctionBoxCollection:
    def __init__(self, positions):
        nPositions = len(positions)
        pairs = [] # each element in the list will be [firstId, secondId, distance]
        for firstId in range(nPositions):
            for secondId in range(firstId + 1, nPositions):
                pairs.append([firstId, secondId, calculateDistance(positions[firstId], positions[secondId])])
    
        # Sort by distance (index 2)
        pairs.sort(key=lambda x: x[2])

        self.positions = positions
        self.pairs = pairs
        self.circuitById = list(range(nPositions))
        self.idsByCircuit = [[x] for x in range(nPositions)]
        self.mergePairIndex = 0

    def mergeNextCircuitPair(self):
        # Merge circuits in order
        nPositions = len(self.positions)
        thisPair = self.pairs[self.mergePairIndex]
        self.mergePairIndex += 1

        firstId = thisPair[0]
        secondId = thisPair[1]
        firstIdCircuit = self.circuitById[firstId]
        secondIdCircuit = self.circuitById[secondId]
        if firstIdCircuit == secondIdCircuit:
            return
        for thisId in self.idsByCircuit[secondIdCircuit]:
            self.circuitById[thisId] = firstIdCircuit
        self.idsByCircuit[firstIdCircuit] += self.idsByCircuit[secondIdCircuit]
        self.idsByCircuit[secondIdCircuit] = []

    def calculateCircuitSizes(self):
        circuitSizes = {}
        for ii in range(len(self.idsByCircuit)):
            circuitSizes[ii] = len(self.idsByCircuit[ii])
        return list(circuitSizes.values())
    
    def countCircuits(self):
        count = 0
        for ids in self.idsByCircuit:
            if len(ids) == 0:
                continue
            count += 1
        return count


def main():
    N_CONNECTIONS = 1000
    
    positions = []
    with open("D08_Data.txt") as file:
        for line in file:
            positions.append([int(x) for x in line.split(",")])

    # Part 1
    tStart = time.time()
    junctionBoxes = JunctionBoxCollection(positions)
    for ii in range(N_CONNECTIONS):
        junctionBoxes.mergeNextCircuitPair()
    circuitSizes = junctionBoxes.calculateCircuitSizes()

    circuitSizes.sort(reverse=True)
    result = circuitSizes[0]
    for ii in range(1, 3):
        result *= circuitSizes[ii]
    tEnd = time.time()

    print("Part 1 elapsed time = %.6fs" % (tEnd - tStart))
    print("Product of three largest circuit sizes = %i\n" % result)

    # Part 2
    tStart = time.time()
    nConnectionsMade = N_CONNECTIONS
    while junctionBoxes.countCircuits() > 1:
        junctionBoxes.mergeNextCircuitPair()
        nConnectionsMade += 1
    lastPairIndex = junctionBoxes.mergePairIndex - 1
    lastPairIds = junctionBoxes.pairs[lastPairIndex][:2]

    xCoordinates = []
    for thisId in lastPairIds:
        xCoordinates.append(junctionBoxes.positions[thisId][0])
    tEnd = time.time()

    print("Part 2 elapsed time = %.6fs" % (tEnd - tStart))
    print("Number of connections made = %i" % nConnectionsMade)
    print("Product of X Coordinates = %i" % math.prod(xCoordinates))


main()