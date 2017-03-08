def testFmin():
    return fmin_cg(
        f
        , 0 # initial guess
        , fprime = grad
        , args = (np.array([[11,2],[3,4]]),) # is tuple!
    )

def f(x, *args):
    a = args[0][0,0]
    b = args[0][0,1]
    return (x - a)**2 + b

def grad(x, *args):
    a = args[0][0,0]
    b = args[0][0,1]
    return 2*(x-a)
