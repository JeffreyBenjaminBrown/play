get_ipython().magic('matplotlib inline')
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
import scipy.io # Used to load the OCTAVE *.mat files
import scipy.misc # Used to show matrix as an image
import matplotlib.cm as cm # Used to display images in a specific colormap
from scipy.optimize import fmin_cg # unconstrained optimization
import itertools
from scipy.special import expit # Vectorized sigmoid function


### Utilities. No matrices yet.

def mapShape(arrayList): return list(map(np.shape,arrayList))


## Sigmoids, 2 kinds
  # "fast sigmoid" (1 / (1+abs(x)))
  # expit (1/(1+e^z)), unused

def expitPrime(colVec): return expit(colVec) * expit(1-colVec)

def sigmoid(x): return (x / (1 + abs(x)) + 1) / 2

def sigmoidPrime(x): return 1 / (2 * ((abs(x)+1)**2))


### Load data

def tenToZero(digit):
    if digit == 10: return 0
    else: return digit

def digitVecToBoolArray(digitVec):
    height = digitVec.shape[0]
    boolArray = np.zeros((height,10))
    for obs in range(height):
        boolArray[obs,digitVec[obs]] = 1
    return boolArray

def importTheData():
    datafile = 'digits,handwritten.mat'
    mat = scipy.io.loadmat( datafile )
    X, Y = mat['X'], mat['y']
    X = np.insert(X,0,1,axis=1)    # Insert a column of 1's
    Y = np.vectorize(tenToZero)(Y)
    YBool = digitVecToBoolArray(Y)
    return X,Y,YBool


### Coefficient matrices. "Architecture" = list of lengths.

## Make random coeffs

def mkRandCoeffsSymmetric(randUnifCoeffs):
    return randUnifCoeffs*2 - 1 # rand outputs in [0,1], not [-1,1]

def mkRandCoeffsSmall(randUnifCoeffs):
    a,b = randUnifCoeffs.shape
    e = np.sqrt(6) / np.sqrt(a+b)
    return randUnifCoeffs * e

def mkRandCoeffs(lengths):
    # lengths :: [Int] lists input, hidden, and output layer lengths
    # and it does NOT include the constant terms
    acc = []
    for i in range(len(lengths)-1):
        acc.append(mkRandCoeffsSmall(mkRandCoeffsSymmetric(
                np.random.rand(lengths[i+1],lengths[i]+1) ) ) )
    return acc


## Flatten|ravel coeffs

def flattenCoeffs(coeffMats):
    return np.concatenate( # coeffs :: a list of matrices
        tuple( list( map( np.ndarray.flatten, coeffMats ) ) )
    )

def ravelCoeffs(lengths, coeffVec):
    acc = []
    matArea = 0
    nexti = 0
    for i in range( len(lengths) - 1 ):
        matArea = (lengths[i]+1) * lengths[i+1]
        acc.append(
            coeffVec[ nexti : nexti + matArea ] # >>> parens around this line?
            .reshape( (lengths[i+1],lengths[i]+1 ) )
        )
        nexti += matArea
    return acc


### Forward-propogation

def forward(nnInputs,coeffMats):
    # nnInputs :: column vector of inputs to the neural net
    # coeffMats :: list of coefficient matrices
    latents = ["input layer latent vector does not exist"] # per-layer inputs to the sigmoid function
      # The last layer has the same number of latent and activ values.
      # Each hidden layer's latent (aka weighted input) vector is 1 neuron shorter than the corresponding activs vector.
      # HOWEVER, to make indexing the list of latents the same as the list
      # of activs, I give "latents" a dummy string value at position 0.
    activs = [nnInputs] # per-layer outputs from the sigmoid function
    for i in range(len(coeffMats)):
        newLatent = coeffMats[i].dot(activs[i])
        latents.append( newLatent )
        newActivs =  (latents[i+1] / (1 + abs(latents[i+1])) + 1) / 2
          # wanted to call _sigmoid, but function calls are costly
        if i<len(coeffMats)-1: newActivs = np.insert(newActivs,0,1,axis=0)
            # nnInputs already has the unity term (a "row" of length 1).
            # The hidden layer activations get it prepended here.
            # The output vector doesn't need it.
            # Activations ("a") have it, latents ("z") do not.
        activs.append( newActivs )
    return (latents,activs)

def predict(nnInputs,coeffMats):
    latents,activs = forward(nnInputs,coeffMats)
    return latents[-1].argmax()


#### Optimization, inc. backprop
### Cost

# contra tradition, neither cost needs to be scaled by 1/|obs|
def mkObsErrorCost(observed,predicted):
    return np.sum( # -y log hx - (1-y) log (1-hx)
        (-1) * observed * np.log(predicted)
        - (1 - observed) * np.log(1 - predicted)
    )

def mkRegularizationCost(coeffMats):
    flatMats = [np.delete(x,0,axis=1).flatten()
                for x in coeffMats]
    return np.concatenate(np.array(flatMats)**2).sum()


### Errors, and back-propogating them

def mkErrors(coeffMats,latents,activs,yVec):
    "Make a list of error vectors, one per layer."
    nLayers = len(latents)
    errs = list( range( nLayers ) ) # dummy values, just for size
    errs[0] = "input layer has no error term"
    errs[-1] = activs[-1] - yVec # the last layer's error is different
    for i in reversed( range( 1, nLayers - 1 ) ): # indexing activs
        errs[i] = ( coeffMats[i].T.dot( errs[i+1] )[1:] 
                    # [1:] drops term 0, the "error" in the constant unity neuron
                    * 1 / (2 * ((abs(latents[i])+1)**2)) )
                      # wanted to call sigmoidPrime, but function calls costly
    for i in range(1,len(errs)): errs[i] = errs[i].reshape((-1,1))
    return errs

def mkObsDeltaMats(errs,activs):
    "For a single observation, compute the change in coefficient matrices implied by the error and activation vectors."
    nMats = len(activs)-1
    acc = list(range(nMats)) # start with dummy values
    for i in range(nMats):
        acc[i] = errs[i+1].dot( activs[i].T )
    return acc


### Optimizing by hand

def handRun(lengths,X,YBool):
    nObs = X.shape[0]
    coeffs = mkRandCoeffs( lengths )
    costAcc = []
    changeAcc = list(map(lambda x: x.dot(0),coeffs)) # = initCoeffs * 0
    for run in range(5): # convex cost => convergence "starts" immediately
        costThisRun = 0
        for obs in range( nObs ):
            latents,activs = forward(X[obs].reshape((-1,1)),coeffs)
            errs = mkErrors(coeffs,latents,activs,YBool[obs].reshape((-1,1)))
            costThisRun += mkObsErrorCost( YBool[obs], activs[-1])
            ocd = mkObsDeltaMats(errs,activs)
            for i in range(len(coeffs)): changeAcc[i] += ocd[i]
        costAcc.append(costThisRun/nObs)
        for i in range(len(coeffs)): coeffs[i] -= 10 * (changeAcc[i] / nObs)
    return costAcc


### Optimizing with scipy.optimize.fmin_cg

def mkErrorCost(coeffVec,*args):
    lengths,X,YBool = args
    coeffs = ravelCoeffs(lengths,coeffVec)
    nObs = X.shape[0]
    acc = 0
    for i in range(nObs):
        _,activs = forward( X[i], coeffs )
        acc += mkObsErrorCost( YBool[i], activs[-1] )
    return acc/nObs

def mkCoeffGradVec(coeffVec,*args):
    lengths,X,YBool = args
    coeffs = ravelCoeffs(lengths,coeffVec)
    acc = [x.dot(0) for x in coeffs]
    for obs in range( X.shape[0] ): # accumulate gradient from each observation
        latents,activs = forward(X[obs].reshape((-1,1)),coeffs)
        errs = mkErrors(coeffs,latents,activs,YBool[obs].reshape((-1,1)))
        ocd = mkObsDeltaMats(errs,activs)
        for i in range(len(coeffs)): acc[i] += ocd[i]
    return flattenCoeffs(acc)

def run(lengths,X,YBool):
    return fmin_cg(
        mkErrorCost
        , flattenCoeffs( mkRandCoeffs( lengths ) )
        , fprime = mkCoeffGradVec
        , args = (lengths,X,YBool)
        , maxiter = 100
    )

