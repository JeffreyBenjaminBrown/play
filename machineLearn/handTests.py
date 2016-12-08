sigmoid(np.array([-10,0,10]))
sigmoidPrime(np.array([list(range(-10,15,5))])).T

YBool

mkRandCoeffs([3,2,1]) # example: 2 matrices, 3 layers (1 hidden)

# forward() works!
  # (The smaller test's arithmetic is even human-followable.)
forward(np.array([[1,2,3]]).T
       , [np.array([[5,2,0]])]
       )
forward(  np.array([[1,1,2]]).T
        , [np.array([[1,2,3]
                    ,[4,5,6]])
           , np.array([[3,2,1]
                      ,[5,5,5]])
          ] )

mkObsErrorCost(np.array([[1,0]]).T  # should be small
              , np.array([[.99,0.01]]).T)
mkRegularizationCost([np.array([[10,1,2]])]) # should be 5
mkRegularizationCost([np.eye(1),np.eye(2)]) # should be 1

def testCost():
    nnInputs = np.array([[1,2,-1]]).T
    observedCategs = np.array([[1,0]])
    Thetas = mkRandCoeffs([2,2,2])
    latents,activs = forward(nnInputs,Thetas)
    ec = mkObsErrorCost(observedCategs,activs[-1])
    rc = mkRegularizationCost(Thetas)
    return (ec,rc)

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

def testMkObsDeltaMats(): # result should be list of 1 3 by 3
    errs = ["nonexistent",np.ones((3,1))]
    activs = [np.ones((3,1)),"unimportant"]
    return mkObsDeltaMats(errs,activs)

def testMkObsDeltaMats2(): # result should be list of 2 3 by 3s
    errs = ["nonexistent",np.ones((3,1)),np.ones((3,1))]
    activs = [np.ones((3,1)),np.ones((3,1)),"unimportant"]
    return mkObsDeltaMats(errs,activs)
