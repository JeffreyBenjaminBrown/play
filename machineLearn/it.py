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


# ### Utilities

def prependUnityColumn(colvec):
    return np.insert(colvec,0,1,axis=0)
test = np.array([[3,4]]).T
# (test, prependUnityColumn(test)) # test

def mapShape(arrayList): return list(map(np.shape,arrayList))

# ## Sigmoids: Expit (1/(1+e^z)) is somehow faster than "fast sigmoid" (1 / (1+abs(x)))

# obsolete, replaced by the sigmoid functions (which are next)
def expitPrime(colVec): return expit(colVec) * expit(1-colVec)
    # the derivative of ("expit" = the sigmoid function)

def _sigmoid(x): return (x / (1 + abs(x)) + 1) / 2
sigmoid = np.vectorize(_sigmoid)
# sigmoid(np.array([-10,0,10])) # test

def _sigmoidPrime(x): return 1 / (2 * ((abs(x)+1)**2))
sigmoidPrime = np.vectorize(_sigmoidPrime)
# sigmoidPrime(np.array([list(range(-10,15,5))])).T # test

data = np.random.rand(1000000)
get_ipython().magic('prun expit(data)')
# %prun sigmoid(data)
# %prun np.vectorize( lambda x: (x / (1 + abs(x)) + 1) / 2 )(data)

# ### Load data

datafile = 'digits,handwritten/data.mat'
mat = scipy.io.loadmat( datafile )
X, Y = mat['X'], mat['y']
X = np.insert(X,0,1,axis=1) #Insert a column of 1's
XT = X.T.copy() # hopefully, rows from XT come faster than columns from X
nObs = X.shape[0]

def tenToZero(digit):
    if digit == 10: return 0
    else: return digit
Y = np.vectorize(tenToZero)(Y)

def digitVecToBoolArray(digitVec):
    # >>> I meant to use this somewhere else too
    height = digitVec.shape[0]
    boolArray = np.zeros((height,10))
    for obs in range(height):
        boolArray[obs,digitVec[obs]] = 1
    return boolArray

YBool = digitVecToBoolArray(Y)
YBool;

# ### Make random coeffs. "Architecture" = list of lengths.

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
mkRandCoeffs([3,2,1]) # example: 2 matrices, 3 layers (1 hidden)

# ### Forward-propogation

def forward(nnInputs,coeffMats):
    # nnInputs :: column vector of inputs to the neural net
    # coeffMats :: list of coefficient matrices
    latents = ["input layer latent vector does not exist"] # per-layer inputs to the sigmoid function
      # The last layer has the same number of latent and activ values.
      # Each hidden layer's latent (aka weighted input) vector is 1 neuron shorter than the corresponding activs vector.
      # HOWEVER, to make indexing the list of latents the same as the list of activs, 
          # I give it a dummy string value at position 0.
    activs = [nnInputs] # per-layer outputs from the sigmoid function
    for i in range(len(coeffMats)):
        newLatent = coeffMats[i].dot(activs[i])
        latents.append( newLatent )
        newActivs = expit( latents[i+1] ) # >>>
        if i<len(coeffMats)-1: newActivs = prependUnityColumn(newActivs)
            # nnInputs already has the unity column.
            # The hidden layer activations get it prepended here.
            # The output vector doesn't need it.
            # Activations ("a") have it, latents ("z") do not.
        activs.append( newActivs )
    prediction = np.argmax(activs[-1])
    return (latents,activs,prediction)

# It works! (The smaller test's arithmetic is even human-followable.)
forward(np.array([[1,2,3]]).T
       , [np.array([[5,2,0]])]
       )
forward(  np.array([[1,1,2]]).T
        , [np.array([[1,2,3]
                    ,[4,5,6]])
           , np.array([[3,2,1]
                      ,[5,5,5]])
          ] )

# ### Cost

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
mkErrorCost(np.array([[1,0]]).T  # should be small
           , np.array([[.99,0.01]]).T)
mkRegularizationCost([np.array([[10,1,2]])]) # should be 5
mkRegularizationCost([np.eye(1),np.eye(2)]) # should be 1

def testCost():
    nnInputs = np.array([[1,2,-1]]).T
    observedCategs = np.array([[1,0]])
    Thetas = mkRandCoeffs([2,2,2])
    latents,activs,predicts = forward(nnInputs,Thetas)
    ec = mkErrorCost(observedCategs,activs[-1])
    rc = mkRegularizationCost(Thetas)
    return (ec,rc)
testCost()

# ### Errors, and back-propogating them

def mkErrors(coeffMats,latents,activs,yVec):
    "Returns a list of error vectors, one per layer."
    nLayers = len(latents)
    errs = list( range( nLayers ) ) # dummy values, just for size
    errs[0] = "input layer has no error term"
    errs[-1] = activs[-1] - yVec # the last layer's error is different
    for i in reversed( range( 1, nLayers - 1 ) ): # indexing activs
        errs[i] = ( coeffMats[i].T.dot( errs[i+1] )[1:] 
                    # [1:] to drop the first, the "error" in the constant unity neuron
                    * expitPrime(latents[i]) ) # >>>
    for i in range(1,len(errs)): errs[i] = errs[i].reshape((-1,1))
    return errs

def testMkErrors(): return mkErrors(
      [np.eye(2),np.eye(2),np.ones((2,2))]
    , ["nonexistent", np.array([[1,1]]).T,np.array([[1,1]]).T, "unimportant"]
    , [np.array([[1,1]]).T,np.array([[1,1]]).T,np.array([[1,1]]).T,np.array([[2,3]]).T]
    , np.array([[2,3.1]]).T
    )

def testMkErrors2(): return mkErrors(
      [np.eye(2),np.ones((2,2))]
    , ["nonexistent", np.array([[1,1]]).T, "unimportant"]
    , [np.array([[1,1]]).T,np.array([[1,1]]).T,np.array([[2,3]]).T]
    , np.array([[2,3.1]]).T
    )
testMkErrors2()

def mkObsDeltaMats(errs,activs):
    "Compute the change in coefficient matrices implied by the error and activation vectors from a given observation."
    nMats = len(activs)-1
    acc = list(range(nMats)) # start with dummy values
    for i in range(nMats):
        acc[i] = errs[i+1].dot( activs[i].T )
    return acc

def testMkObsDeltaMats(): # result should be 3 by 3
    errs = ["nonexistent",np.ones((3,1))]
    activs = [np.ones((3,1)),"unimportant"]
    return mkObsDeltaMats(errs,activs)
testMkObsDeltaMats()

# ### Putting it together?

def mkCoeffDeltasFromObs(coeffMats,X,YBool):
    latents,activs,_ = forward(X,coeffMats)
    errs = mkErrors(coeffMats,latents,activs,YBool)
    return mkObsDeltaMats(errs,activs)

def run(lengths): # >>> ! refers to global variables
    coeffs = mkRandCoeffs( lengths )
    costAcc = []
    changeAcc = list(map(lambda x: x.dot(0),coeffs)) # initCoeffs * 0
    for run in range(5): # 2 is enough if convergence monotonic
        costThisRun = 0
        for obs in range( nObs ): # >>> inefficient, runs forward twice for each obs
            # should combine with the next loop
            _,activs,_ = forward( XT[:,[obs]] # >>> was: X[obs].reshape((-1,1))
                                , coeffs )
            costThisRun += mkErrorCost( YBool[obs], activs[-1])
        costAcc.append(costThisRun/nObs)
        for obs in range( nObs ):
            ocd = mkCoeffDeltasFromObs(
                    coeffs,
                    XT[:,[obs]],
                    YBool[obs].reshape((-1,1)))
            changeAcc += ocd
        for i in range(len(coeffs)):
            coeffs[i] -= 1000 * (ocd[i] / nObs)
    return costAcc # >>> also return coeffs
