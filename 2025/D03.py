import copy

def findMaxJoltages(bankJoltages, nDigits):
    nBanks = len(bankJoltages)
    maxJoltages = []
    for thisBank in bankJoltages:
        lastTakenIndex = -1
        maxBankJoltage = 0
        for thisDigitIndex in range(nDigits):
            allowableDigits = thisBank.copy()
            if lastTakenIndex >= 0:
                for ii in range(lastTakenIndex + 1):
                    allowableDigits[ii] = -1
            
            if (thisDigitIndex + 1) != nDigits:
                nColumnsToSave = nDigits - thisDigitIndex - 1
                allowableDigits = allowableDigits[:-nColumnsToSave]
            
            maxBatteryJoltage = max(allowableDigits)
            lastTakenIndex = allowableDigits.index(maxBatteryJoltage)
            maxBankJoltage += maxBatteryJoltage * 10 ** (nDigits - (thisDigitIndex + 1))
        maxJoltages.append(maxBankJoltage)
    return maxJoltages

with open("D03_Data.txt") as file:
    bankJoltages = file.read().split()

# Split into individual battery joltage and convert to int
# Joltage of battery j in bank i = bankJoltages[i][j]
for ii in range(len(bankJoltages)):
    bankJoltages[ii] = [int(x) for x in list(bankJoltages[ii])]

# Part 1
maxJoltages = findMaxJoltages(bankJoltages, 2)
print("Output Joltage, part 1 = %i" % sum(maxJoltages))

# Part 2
maxJoltages = findMaxJoltages(bankJoltages, 12)
print("Output Joltage, part 2 = %i" % sum(maxJoltages))