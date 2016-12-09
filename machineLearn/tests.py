import unittest

class TheTestCase(unittest.TestCase):
    ## WARNING: Expects the following to exist:
      ## X,Y,YBool = importTheData()
    def testTenToZero(self):
        assert ( list(map(tenToZero, range(1,11))) ==
          list(range(1,10)) + [0] ), "problem in tenToZero"

    def testDigitVecToBoolArray(self):
        x = np.array([[ 1.,  0.,  0.,  0.,  0.,  0.,  0.,  0.,  0.,  0.],
                      [ 0.,  0.,  0.,  0.,  1.,  0.,  0.,  0.,  0.,  0.],
                      [ 0.,  0.,  0.,  0.,  0.,  0.,  0.,  0.,  0.,  1.]])
        y = digitVecToBoolArray(np.array([0,4,9]))
        assert np.array_equal(x,y), "problem in digitVecToBoolArray"
        
    def testFlattenCoeffs(self):
        assert np.array_equal(
            flattenCoeffs( [np.eye(1),np.eye(2)] )
            , np.array( [1,1,0,0,1] )
        ), "problem in flatten"

    def testRavelIdempotent(self):
        lengths = [2,3]
        x1 = mkRandCoeffs(lengths)
        x2 = flattenCoeffs(x1)
        x3 = ravelCoeffs(lengths,x2)
        x4 = flattenCoeffs(x3)
        assert np.isclose(x1,x3).all(), "problem in ravel"
        assert np.isclose(x2,x4).all(), "problem in ravel"

    def testRavelCoeffs(self):
        makeIt = ravelCoeffs( [1,2,2]
                              , np.array( [ 1,2,3,4,
                                            11,12,13,14,15,16 ] ) )
        mustBe = [ np.array( [[1,2], [3,4]] )
                 , np.array([[11, 12, 13], [14, 15, 16]] )
        ]
        assert np.array_equal(makeIt[0], mustBe[0]), "problem in ravel"
        assert np.array_equal(makeIt[1], mustBe[1]), "problem in ravel"

    def testForward(self):
        # Is human-followable math. The 100 causes an activation near unity.
        latents,activs = forward(np.array([[1,2,3]]).T
                                 , [np.array([[5,2,0],
                                              [0,1,100]]),
                                    np.array([[555,0,1]])
        ] )
        assert np.array_equal( latents[1], np.array( [[9],[302]] ) ),"testForward"
        assert np.isclose( latents[2], np.array( [[-99]] ), atol=.01),"testForward"
        
    def testMkErrorCost(self): # just make sure it runs
        lengths = [400,26,10]
        coeffVec = flattenCoeffs( mkRandCoeffs( lengths ) )
        mkErrorCost(coeffVec,lengths,X,YBool)

    def testMkCoeffGradVec(self): # just make sure it runs
        lengths = [400,26,10]
        coeffVec = flattenCoeffs( mkRandCoeffs( lengths ) )
        mkCoeffGradVec(coeffVec,lengths,X,YBool)
