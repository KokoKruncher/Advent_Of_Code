def calculateRectangleArea(position1, position2):
    x = abs(position2[0] - position1[0]) + 1
    y = abs(position2[1] - position1[1]) + 1
    return(x * y)


def isPositionWithinRectangle(position, corner1, corner2):
    isWithinX = position[0] > min(corner1[0], corner2[0]) and position[0] < max(corner1[0], corner2[0])
    isWithinY = position[1] > min(corner1[1], corner2[1]) and position[1] < max(corner1[1], corner2[1])
    return isWithinX and isWithinY


def isRectangleValid(indexCorner1, indexCorner2, redTilePositions):
    if abs(indexCorner2 - indexCorner1) == 1:
        # Corners are directly connected, and thus guaranteed to have green tiles between them
        return True
    nPositions = len(redTilePositions)
    corner1 = redTilePositions[indexCorner1]
    corner2 = redTilePositions[indexCorner2]
    for ii in range(nPositions):
        if ii == indexCorner1 or ii == indexCorner2:
            continue
        if isPositionWithinRectangle(redTilePositions[ii], corner1, corner2):
            return False
    return True


def main():
#     redTilePositions = []
#     with open("D09_Data.txt") as file:
#         for line in file:
#             x, y = line.split(",")
#             redTilePositions.append([int(x), int(y)])

    redTilePositions = [[7,1],[11,1],[11,7],[9,7],[9,5],[2,5],[2,3],[7,3]]

    # Part 1
    nPositions = len(redTilePositions)
    largestArea = 0
    for ii in range(nPositions):
        for jj in range(ii + 1, nPositions):
            thisArea = calculateRectangleArea(redTilePositions[ii], redTilePositions[jj])
            if thisArea > largestArea:
                largestArea = thisArea
    print("Largest area, part 1 = %i" % largestArea)

    # Part 2
    largestArea = 0
    for ii in range(nPositions):
        for jj in range(ii + 1, nPositions):
            if not isRectangleValid(ii, jj, redTilePositions):
                continue
            thisArea = calculateRectangleArea(redTilePositions[ii], redTilePositions[jj])
            if thisArea > largestArea:
                largestArea = thisArea
                print("%i: [%i, %i], [%i, %i]" % (largestArea, redTilePositions[ii][0], redTilePositions[ii][1], redTilePositions[jj][0], redTilePositions[jj][1]))
    print("Largest area, part 2 = %i" % largestArea)
     


main()