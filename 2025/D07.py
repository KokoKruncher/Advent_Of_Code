def main():
    with open("D07_Data.txt") as file:
        manifold = [line.strip("\n") for line in file]
    
    # Part 1 & Part 2
    nRows = len(manifold)
    nCols = len(manifold[0])
    isBeamPrev = [col == "S" for col in manifold[0]]
    nBeamsPrev = [1 if col else 0 for col in isBeamPrev]
    splitCount = 0
    nPossibilities = sum(nBeamsPrev)
    for row in range(nRows):
        thisRow = manifold[row]
        
        # # Visualise
        # visualRow = list(thisRow)
        # for ii, bool in zip(range(nCols), isBeamPrev):
        #     if bool:
        #         visualRow[ii] = "|"
        # print("".join(visualRow))
        
        if row == 0:
            continue
        isBeamCurrent = isBeamPrev.copy()
        nBeamsCurrent = nBeamsPrev.copy()
        for col in range(nCols):
            if isBeamPrev[col] and thisRow[col] == "^":
                # Hit a splitter, which would add 1 possibility for each beam that hit the splitter
                splitCount += 1
                nHits = nBeamsPrev[col]
                nPossibilities += nHits

                # Split the beams left and right, and remove the beams at the splitter
                isBeamCurrent[col] = False
                nBeamsCurrent[col] = 0
                if (col - 1) >= 0:
                    isBeamCurrent[col - 1] = True
                    nBeamsCurrent[col - 1] += nHits
                if (col + 1) < nCols:
                    isBeamCurrent[col + 1] = True
                    nBeamsCurrent[col + 1] += nHits
        isBeamPrev = isBeamCurrent
        nBeamsPrev = nBeamsCurrent
    print("Number of times beam was split = %i" % splitCount)
    print("Number of possibilities = %i" % nPossibilities)
        

main()