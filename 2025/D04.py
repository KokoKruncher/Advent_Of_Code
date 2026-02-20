def isAccessible(grid, row, col):
    INCREMENTS = [-1, 0, 1]
    COUNT_LIMIT = 3
    nRows = len(grid)
    nCols = len(grid[0])
    count = 0
    for ii in INCREMENTS:
        rowToCheck = row + ii
        if rowToCheck < 0 or rowToCheck >= nRows:
            continue
        for jj in INCREMENTS:
            colToCheck = col + jj
            if colToCheck < 0 or colToCheck >= nCols:
                continue
            if rowToCheck == row and colToCheck == col:
                continue
            if grid[rowToCheck][colToCheck] == "@":
                count += 1
            if count > COUNT_LIMIT:
                return False
    return True


def findAccessiblePositions(grid):
    nRows = len(grid)
    nCols = len(grid[0])
    rows = []
    cols = []
    for iRow in range(nRows):
        for iCol in range(nCols):
            char = grid[iRow][iCol]
            if char != "@":
                continue
            if isAccessible(grid, iRow, iCol):
                rows.append(iRow)
                cols.append(iCol)
    return rows, cols


def replaceCharacterAtIndex(str, index, newCharacter):
    return str[:index] + newCharacter + str[index + 1:]


def main():
    grid = []
    with open ("D04_Data.txt") as file:
        for line in file:
            grid.append(line.strip())

    # Part 1
    rows, cols = findAccessiblePositions(grid)
    nAccessiblePositions = len(rows)
    print("Number of accessible rolls of paper = %i" % nAccessiblePositions)

    # Part 2
    nPositionsRemoved = 0
    while nAccessiblePositions > 0:
        for thisRow, thisCol in zip(rows, cols):
            grid[thisRow] = replaceCharacterAtIndex(grid[thisRow], thisCol, ".")
        nPositionsRemoved += nAccessiblePositions
        rows, cols = findAccessiblePositions(grid)
        nAccessiblePositions = len(rows)

    print("Number of poisitions removed: %i" % nPositionsRemoved)


if __name__ == '__main__':
    main()