def splitWorksheetIntoProblems(worksheet):
    for line in worksheet:
        if len(line) != len(worksheet[0]):
            raise Exception("The lines in the worksheet have unequal lenghs!")
    worksheetWidth = len(worksheet[0])
    worksheetHeight = len(worksheet)
    problems = []
    iProblemStart = 0
    for iCol in range(worksheetWidth):
        isProblemSeparator = True
        if iCol < worksheetWidth - 1:
            for iRow in range(worksheetHeight):
                if worksheet[iRow][iCol] != " ":
                    isProblemSeparator = False
                    break
        else:
            # Next "virtual whitespace" is right after the end of the line
            iCol += 1
        if not isProblemSeparator:
            continue
        problems.append([row[iProblemStart : iCol] for row in worksheet])
        iProblemStart = iCol + 1
    return problems


def performOperations(numbers, operationString):
    plus = lambda a, b: a + b
    times = lambda a, b: a * b

    if operationString == '+':
        operation = plus
    elif operationString == '*':
        operation = times
    else:
        raise Exception("Encountered unknown operation string: %s" % operationString)
    result = int(numbers[0])
    for ii in range(1, len(numbers)):
        result = operation(result, int(numbers[ii]))
    return result


def solveProblemPart1(problem):
    problem = problem.copy()
    operationString = problem.pop().strip()
    return performOperations(problem, operationString)


def solveProblemPart2(problem):
    problem = problem.copy()
    operationString = problem.pop().strip()
    height = len(problem)
    width = len(problem[0])
    numbers = []
    for col in range(width):
        thisNumber = []
        for row in range(height):
            thisNumber.append(problem[row][col])
        thisNumber = int("".join(thisNumber))
        numbers.append(thisNumber)
    return performOperations(numbers, operationString)


def main():
    with open("D06_Data.txt") as file:
        worksheet = [line.strip("\n") for line in file]

    problems = splitWorksheetIntoProblems(worksheet)

    # Part 1
    result = 0
    for problem in problems:
        result += solveProblemPart1(problem)
    print("Part 1: %i" % result)

    # Part 2
    result = 0
    for problem in problems:
        result += solveProblemPart2(problem)
    print("Part 2: %i" % result)


main()