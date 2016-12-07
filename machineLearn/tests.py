import unittest

class TheTestCase(unittest.TestCase):
    def testTenToZero(self):
        assert ( list(map(tenToZero, range(1,11))) ==
          list(range(1,10)) + [0] ), "problem in tenToZero"

    def testFlatten(self):
        assert np.array_equal( 
            flattenCoeffs( [np.eye(1),np.eye(2)] )
            , np.array( [1,1,0,0,1] )
        ), "problem in flatten"
