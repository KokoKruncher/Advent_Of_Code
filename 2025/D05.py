def isWithin(num, range):
    if num >= range[0] and num <= range[1]:
        return True
    else:
        return False


def isIdFresh(id, freshIdRanges):
    for range in freshIdRanges:
        if isWithin(id, range):
            return True
    return False


def removeDuplicateRanges(ranges):
    # Sort ranges by their minimum value like this:
    # 0001111111110000000000000
    # 0000000000111111110000000
    # 0000000000001110000000000
    # 0000000000000000000011111
    #
    # So that we can then merge them like this:
    # 1. Merge first two lines
    # XXXXXXXXXXXXXXXXXXXXXXXXX
    # 0001111111111111110000000
    # 0000000000001110000000000
    # 0000000000000000000011111
    #
    # 2. Merge second and third lines
    # XXXXXXXXXXXXXXXXXXXXXXXXX
    # XXXXXXXXXXXXXXXXXXXXXXXXX
    # 0001111111111111110000000
    # 0000000000000000000011111 <- can't be merged with any other lines

    ranges = sorted(ranges)
    nRanges = len(ranges)
    toBeRemoved = [False] * nRanges
    for ii in range(1, nRanges):
        lowerRange = ranges[ii - 1]
        upperRange = ranges[ii]
        if intersect(lowerRange, upperRange):
            toBeRemoved[ii - 1] = True
            ranges[ii] = mergeRanges(lowerRange, upperRange)
    
    mergedRanges = []
    for thisRange, isThisRangeToBeRemoved in zip(ranges, toBeRemoved):
        if isThisRangeToBeRemoved:
            continue
        mergedRanges.append(thisRange)

    return mergedRanges
        

def intersect(lowerRange, upperRange):
    if upperRange[0] <= lowerRange[1]:
        return True
    else:
        return False
    

def mergeRanges(lowerRange, upperRange):
    newRange = []
    newRange.append(lowerRange[0])
    newRange.append(max(lowerRange[1], upperRange[1]))
    return newRange


def main():
    freshIdRanges = []
    availableIds = []
    with open("D05_Data.txt") as file:
        for line in file:
            line = line.strip()
            if len(line) == 0:
                continue
            if "-" in line:
                freshIdRanges.append([int(x) for x in line.split("-")])
            else:
                availableIds.append(int(line))
    
    # Part 1
    nFreshAvailableIds = 0
    for id in availableIds:
        if isIdFresh(id, freshIdRanges):
            nFreshAvailableIds += 1
    print("Number of available IDs that are fresh = %i" % nFreshAvailableIds)

    # Part 2
    mergedRanges = removeDuplicateRanges(freshIdRanges)
    nFreshIds = 0
    for thisRange in mergedRanges:
        nFreshIds += thisRange[1] - thisRange[0] + 1
    print("Number of possible fresh IDs = %i" % nFreshIds)

main()