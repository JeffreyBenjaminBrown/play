import unittest

class TheTestCase(unittest.TestCase):
    def testTenToZero(self):
        assert ( list(map(tenToZero, range(1,11))) ==
          list(range(1,10)) + [0] ), "tenToZero not working"

