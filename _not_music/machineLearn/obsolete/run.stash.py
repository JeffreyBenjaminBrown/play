

# I tried to inline the call to mkObsCoeffDelta

def run(lengths): # >>> ! refers to global variables X, XT, nObs, YBool, ?..
    coeffs = mkRandCoeffs( lengths )
    costAcc = []
    changeAcc = list(map(lambda x: x.dot(0),coeffs)) # initCoeffs * 0
    for run in range(5): # 2 is enough if convergence monotonic
        costThisRun = 0
        for obs in range( nObs ):
            latents,activs = forward(XT[:,[obs]],coeffs)
            errs = mkErrors(coeffs,latents,activs,YBool[obs])
            changeAcc += mkObsDeltaMats(errs,activs)
              # >>> but mkObsDeltaMats returns a list of mats!
            costThisRun += mkErrorCost( YBool[obs], activs[-1])
        costAcc.append(costThisRun/nObs)
        for i in range(len(coeffs)):
            coeffs[i] -= 1000 * (ocd[i] / nObs)
    return costAcc
