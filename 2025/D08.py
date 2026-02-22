import math

def calculateDistance(position1, position2):
    squareDistance = 0
    for coord1, coord2 in zip(position1, position2):
        squareDistance += (coord1 - coord2) ** 2
    return math.sqrt(squareDistance)


def main():
    N_CONNECTIONS = 1000
    
    positions = []
    with open("D08_Data.txt") as file:
        for line in file:
            positions.append([int(x) for x in line.split(",")])

    nPositions = len(positions)
    pairDistances = [] # each element in the list will be [firstId, secondId, distance]
    for firstId in range(nPositions):
        for secondId in range(firstId + 1, nPositions):
            pairDistances.append([firstId, secondId, calculateDistance(positions[firstId], positions[secondId])])
    
    # Sort by distance (index 2)
    pairDistances.sort(key=lambda x: x[2])

    # Merge circuits in order
    circuitById = list(range(nPositions))
    idsByCircuit = [[x] for x in range(nPositions)]
    for ii in range(N_CONNECTIONS):
        thisPair = pairDistances[ii]
        firstId = thisPair[0]
        secondId = thisPair[1]
        firstIdCircuit = circuitById[firstId]
        secondIdCircuit = circuitById[secondId]
        if firstIdCircuit == secondIdCircuit:
            continue
        for thisId in idsByCircuit[secondIdCircuit]:
            circuitById[thisId] = firstIdCircuit
        idsByCircuit[firstIdCircuit] += idsByCircuit[secondIdCircuit]
        idsByCircuit[secondIdCircuit] = []
    
    # print(circuitById)
    circuitSizes = {}
    for circuit in circuitById:
        if circuit in circuitSizes:
            circuitSizes[circuit] += 1
        else:
            circuitSizes[circuit] = 1
    circuitSizes = list(circuitSizes.items())
    circuitSizes.sort(key=lambda x: x[1], reverse=True)
    circuitSizes = [x[1] for x in circuitSizes]

    result = circuitSizes[0]
    for ii in range(1, 3):
        result *= circuitSizes[ii]
    print("Product of three largest circuit sizes = %i" % result)
    


main()