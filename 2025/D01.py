def turnDial(currentNumber, nClicks):
    newNumber = currentNumber
    nZeroPasses = 0

    if nClicks == 0:
        return newNumber, nZeroPasses
    
    newNumber = (currentNumber + nClicks) % 100

    # From the current number, put the dial back tozero.
    # Then, compensate the number of clicks needed, so that the new number is still correct after the rotation.
    # If abs(compensated number of clicks) > 100, this means that the dial has passed zero
    if nClicks > 0:
        nClicksCompensated = nClicks + currentNumber
    else:
        nClicksCompensated = -nClicks + (-currentNumber % 100)
    nZeroPasses = nClicksCompensated // 100

    # To avoid double counting
    if newNumber == 0 and nZeroPasses > 0:
        nZeroPasses = nZeroPasses - 1

    return newNumber, nZeroPasses
    

instructions = []
with open("D01_Data.txt") as file:
    instructions = file.read()

instructions = instructions.split()

## Part 1 & 2
directions = []
nClicks = []

print(directions)

for line in instructions:
    thisDirection = line[0]
    thisNumClicks = int(line[1:])
    if thisDirection == "L":
        thisNumClicks = -thisNumClicks

    directions.append(thisDirection)
    nClicks.append(thisNumClicks)

currentNumber = 50
passwordPart1 = 0
passwordPart2 = 0
for ii in range(len(nClicks)):
    currentNumber, nZeroPasses = turnDial(currentNumber, nClicks[ii])
    if currentNumber == 0:
        passwordPart1 = passwordPart1 + 1
    passwordPart2 = passwordPart2 + nZeroPasses
passwordPart2  = passwordPart2 + passwordPart1

print("Password, part 1: %i\n" % passwordPart1)
print("Password, part 2: %i\n" % passwordPart2)