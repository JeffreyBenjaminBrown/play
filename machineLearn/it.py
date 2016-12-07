get_ipython().magic('matplotlib inline')
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
import scipy.io # Used to load the OCTAVE *.mat files
import scipy.misc # Used to show matrix as an image
import matplotlib.cm as cm # Used to display images in a specific colormap
import random # To pick random images to display
import scipy.optimize # fmin_cg to train neural network
import itertools
from scipy.special import expit # Vectorized sigmoid function


### Utilities

def mapShape(arrayList): return list(map(np.shape,arrayList))


## Sigmoids, 2 kinds
  # "fast sigmoid" (1 / (1+abs(x)))
  # expit (1/(1+e^z)), unused

def expitPrime(colVec): return expit(colVec) * expit(1-colVec)

def sigmoid(x): return (x / (1 + abs(x)) + 1) / 2

def sigmoidPrime(x): return 1 / (2 * ((abs(x)+1)**2))


### Load data

datafile = 'digits,handwritten.mat'
mat = scipy.io.loadmat( datafile )
X, Y = mat['X'], mat['y']
X = np.insert(X,0,1,axis=1) #Insert a column of 1's

def tenToZero(digit):
    if digit == 10: return 0
    else: return digit

Y = np.vectorize(tenToZero)(Y)

def digitVecToBoolArray(digitVec):
    height = digitVec.shape[0]
    boolArray = np.zeros((height,10))
    for obs in range(height):
        boolArray[obs,digitVec[obs]] = 1
    return boolArray

YBool = digitVecToBoolArray(Y)


### Make random coeffs. "Architecture" = list of lengths.

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


### Forward-propogation

def forward(nnInputs,coeffMats):
    # nnInputs :: column vector of inputs to the neural net
    # coeffMats :: list of coefficient matrices
    latents = ["input layer latent vector does not exist"] # per-layer inputs to the sigmoid function
      # The last layer has the same number of latent and activ values.
      # Each hidden layer's latent (aka weighted input) vector is 1 neuron shorter than the corresponding activs vector.
      # HOWEVER, to make indexing the list of latents the same as the list of activs, 
          # I give "latents" a dummy string value at position 0.
    activs = [nnInputs] # per-layer outputs from the sigmoid function
    for i in range(len(coeffMats)):
        newLatent = coeffMats[i].dot(activs[i])
        latents.append( newLatent )
        newActivs =  (latents[i+1] / (1 + abs(latents[i+1])) + 1) / 2
          # >>> wanted to call _sigmoid, but function calls are costly
        if i<len(coeffMats)-1: newActivs = np.insert(newActivs,0,1,axis=0)
            # nnInputs already has the unity term (a "row" of length 1).
            # The hidden layer activations get it prepended here.
            # The output vector doesn't need it.
            # Activations ("a") have it, latents ("z") do not.
        activs.append( newActivs )
    return (latents,activs)


### Cost

# contra tradition, neither cost needs to be scaled by 1/|obs|
def mkErrorCost(observed,predicted):
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
                    # [1:] to drop the first, the "error" in the constant unity neuron
                    * 1 / (2 * ((abs(latents[i])+1)**2)) )
                      # >>> wanted to call _sigmoidPrime, but function calls!
    for i in range(1,len(errs)): errs[i] = errs[i].reshape((-1,1))
    return errs

def mkObsDeltaMats(errs,activs):
    "Compute the change in coefficient matrices implied by the error and activation vectors from a given observation."
    nMats = len(activs)-1
    acc = list(range(nMats)) # start with dummy values
    for i in range(nMats):
        acc[i] = errs[i+1].dot( activs[i].T )
    return acc


### Putting it together

def run(lengths,X,YBool):
    nObs = X.shape[0]
    coeffs = mkRandCoeffs( lengths )
    costAcc = []
    changeAcc = list(map(lambda x: x.dot(0),coeffs)) # initCoeffs * 0
    for run in range(5): # 2 is enough if convergence monotonic
        costThisRun = 0
        for obs in range( nObs ):
            latents,activs = forward(X[obs].reshape((-1,1)),coeffs)
            errs = mkErrors(coeffs,latents,activs,YBool[obs].reshape((-1,1)))
            costThisRun += mkErrorCost( YBool[obs], activs[-1])
            ocd = mkObsDeltaMats(errs,activs)
            for i in range(len(coeffs)): changeAcc[i] += ocd[i]
        costAcc.append(costThisRun/nObs)
        for i in range(len(coeffs)): coeffs[i] -= 10 * (changeAcc[i] / nObs)
    return costAcc

