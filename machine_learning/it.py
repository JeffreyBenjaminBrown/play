
# coding: utf-8

# # Programming Exercise 4: Neural Networks Learning

# In[1]:

get_ipython().magic('matplotlib inline')
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
import scipy.io #Used to load the OCTAVE *.mat files
import scipy.misc #Used to show matrix as an image
import matplotlib.cm as cm #Used to display images in a specific colormap
import random #To pick random images to display
import scipy.optimize #fmin_cg to train neural network
import itertools
from scipy.special import expit #Vectorized sigmoid function


# ## Visualizing the data

# In[2]:

#Note this is actually a symlink... same data as last exercise,
#so there's no reason to add another 7MB to my github repo...
datafile = 'data/ex4data1.mat'
mat = scipy.io.loadmat( datafile )
X, Y = mat['X'], mat['y']
#Insert a column of 1's to X as usual
X = np.insert(X,0,1,axis=1)
print( "'Y' shape: %s. Unique elements in y: %s"%(mat['y'].shape,np.unique(mat['y'])) )
print( "'X' shape: %s. X[0] shape: %s"%(X.shape,X[0].shape) )
#X is 5000 images. Each image is a row. Each image has 400 pixels unrolled (20x20)
#y is a classification for each image. 1-10, where "10" is the handwritten "0"


# In[3]:

def tenToZero(digit):
    if digit == 10: return 0
    else: return digit
Y = np.vectorize(tenToZero)(Y)
YBool = np.zeros((Y.shape[0],10)) # because ten categories
for i in range(Y.shape[0]):
    YBool[i,Y[i]]=1
YBool


# In[4]:

def getDatumImg(row):
    """
    Function that is handed a single np array with shape 1x400,
    crates an image object from it, and returns it
    """
    width, height = 20, 20
    square = row[1:].reshape(width,height)
    return square.T
    
def displaySomeData(indices_to_display = None):
    """
    Function that picks 100 random rows from X, creates a 20x20 image from each,
    then stitches them together into a 10x10 grid of images, and shows it.
    """
    width, height = 20, 20
    nrows, ncols = 10, 10
    if not indices_to_display:
        indices_to_display = random.sample(range(X.shape[0]), nrows*ncols)
    big_picture = np.zeros((height*nrows,width*ncols))
    irow, icol = 0, 0
    for idx in indices_to_display:
        if icol == ncols:
            irow += 1
            icol  = 0
        iimg = getDatumImg(X[idx])
        big_picture[irow*height:irow*height+iimg.shape[0],icol*width:icol*width+iimg.shape[1]] = iimg
        icol += 1
    fig = plt.figure(figsize=(6,6))
    img = scipy.misc.toimage( big_picture )
    plt.imshow(img,cmap = cm.Greys_r)


# In[5]:

displaySomeData()


# ## Architecture

# In[6]:

def makeRandCoeffsSymmetric(randUnifCoeffs):
    return randUnifCoeffs*2 - 1 # rand outputs in [0,1], not [-1,1]
def makeRandCoeffsSmall(randUnifCoeffs):
    a,b = randUnifCoeffs.shape
    e = np.sqrt(6) / np.sqrt(a+b)
    return randUnifCoeffs * e


# In[7]:

def makeRandCoeffs(lengths):
    # lengths :: [Int] is input, hidden, and output layer lengths
    # lengths does NOT include the constant terms
    acc = []
    for i in range(len(lengths)-1):
        acc.append(makeRandCoeffsSmall(makeRandCoeffsSymmetric(
                np.random.rand(lengths[i+1],lengths[i]+1) ) ) )
    return acc
makeRandCoeffs([3,2,1]) # example: 2 matrices, 3 layers (1 hidden)


# ## Forward-propogation

# In[8]:

def prependUnityColumn(colvec):
    return np.insert(colvec,0,1,axis=0)
test = np.array([[3,4]]).T
# (test, prependUnityColumn(test)) # test


# In[9]:

def forward(nnInputs,coeffMats):
    # nnInputs :: column vector of inputs to the neural net
    # coeffMats :: list of coefficient matrices
    latents = ["nothing"] # per-layer inputs to the sigmoid function
      # to make indexing latents the same as activs, give it a dummy "nothing" at position 0
    activs = [nnInputs] # per-layer outputs from the sigmoid function
    for i in range(len(coeffMats)):
        newLatent = coeffMats[i].dot(activs[i])
        latents.append( newLatent )
        newActivs = expit( latents[i+1] )
        if i<len(coeffMats)-1: newActivs = prependUnityColumn(newActivs)
            # nnInputs already has the unity column.
            # The hidden layer activations need it prepended.
            # The output vector doesn't need it.
        activs.append( newActivs )
    prediction = np.argmax(activs[-1])
    return (latents,activs,prediction)


# In[10]:

# It works! (And the smaller test's arithmetic is human-followable.)
forward(np.array([[1,2,3]]).T
       , [np.array([[5,2,0]])]
       )
forward(  np.array([[1,1,2]]).T
        , [np.array([[1,2,3]
                    ,[4,5,6]])
           , np.array([[3,2,1]
                      ,[5,5,5]])
          ] )


# ## Cost

# In[11]:

# contra tradition, neither cost needs to be scaled by 1/|obs|
def errorCost(observed,predicted):
    return np.sum( # -y log hx - (1-y) log (1-hx)
        (-1) * observed * np.log(predicted)
        - (1 - observed) * np.log(1 - predicted)
    )
# errorCost(np.array([[1,0]]).T  # should be small
#           , np.array([[.99,0.01]]).T)
def regularizationCost(coeffMats):
    flatMats = [np.delete(x,0,axis=1).flatten()
                for x in coeffMats]
    return np.concatenate(np.array(flatMats)**2).sum()
# regulCost([np.eye(1),np.eye(2)]) # should be 1
# regulCost([np.array([[10,1,2]])]) # should be 5


# In[12]:

def testCost():
    nnInputs = np.array([[1,2,-1]]).T
    observedCategs = np.array([[1,0]])
    Thetas = makeRandCoeffs([2,2,2])
    latents,activs,predicts = forward(nnInputs,Thetas)
    ec = errorCost(observedCategs,activs[-1])
    rc = regularizationCost(Thetas)
    print(latents)
    print("... = the latents\n")
    print(activs)
    print("... = the activations\n")
    print(predicts)
    print("... = the predictions\n")
    print(ec)
    print("... = the error cost\n")
    print(rc)
    print("... = the regularization cost\n")
testCost()


# In[ ]:



