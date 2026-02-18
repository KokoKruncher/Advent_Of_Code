from math import *

def isEven(n):
    return n % 2 == 0


def findIdsRepeatedTwice(ids):
    # Odd number of digits can't have twice repeated pattern
    idsRepeatedTwice = []
    for thisId in ids:
        nDigits = floor(log10(thisId) + 1)
        if not isEven(nDigits):
            continue
        lastHalf = thisId % 10 ** (nDigits / 2)
        firstHalf = (thisId - lastHalf) / (10 ** (nDigits / 2))
        if firstHalf != lastHalf:
            continue
        idsRepeatedTwice.append(thisId)
    return idsRepeatedTwice


def findIdsWithRepeatingSequences(ids):
    idsWithRepeatingSequences = []
    for thisId in ids:
        if isIdRepeatingSequence(thisId):
            idsWithRepeatingSequences.append(thisId)
    return idsWithRepeatingSequences
        

def isIdRepeatingSequence(id):
    nDigits = floor(log10(id) + 1)
    if nDigits < 2:
        return False
    
    nDigitsInGroup = allFactors(nDigits)
    nGroupings = len(nDigitsInGroup)
    for ii in range(nGroupings):
        thisNumDigits = nDigitsInGroup[ii]
        firstDigitIndices = list(range(1, nDigits + 1, thisNumDigits))
        lastDigitIndices = firstDigitIndices.copy()
        for jj in range(len(lastDigitIndices)):
            lastDigitIndices[jj] += thisNumDigits - 1
        groupDigits = extractDigitsBetween(id, firstDigitIndices, lastDigitIndices, nDigits)

        isAllGroupDigitsEqual = True
        for thisGroupDigit in groupDigits:
            if thisGroupDigit != groupDigits[0]:
                isAllGroupDigitsEqual = False
                break
        if isAllGroupDigitsEqual:
            return True
            
    return False
        
        
def extractDigitsBetween(num, firstIndices, lastIndices, nDigits):
    digits = []
    for ii in range(len(firstIndices)):
        temp = (num % 10 ** (nDigits + 1 - firstIndices[ii])) // (10 ** (nDigits - lastIndices[ii]))
        digits.append(temp)
    return digits
    
def allFactors(n):
    factors = []
    candidates = range(1, n // 2 + 1)
    for thisCandidate in candidates:
        if n % thisCandidate == 0:
            factors.append(thisCandidate)
    return factors


with open("D02_Data.txt") as file:
    allIdString = file.read()

# Part 1
idRanges = allIdString.split(",")
ids = []
for thisRange in idRanges:
    thisRange = thisRange.split("-")
    thisRange = list(range(int(thisRange[0]), int(thisRange[1]) + 1)) # Range stops at the number before the second argument
    ids = ids + thisRange

invalidIds1 = findIdsRepeatedTwice(ids)
print("Sum of invalid IDs, part 1: %i" % sum(invalidIds1))

# Part 2
invalidIds2 = findIdsWithRepeatingSequences(ids)
print("Sum of invalid IDs, part 2: %i" % sum(invalidIds2))