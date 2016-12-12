# exec(open("./reading.py").read())
# http://pybrain.org/docs/tutorial/netmodcon.html

from pybrain.structure import FeedForwardNetwork
from pybrain.structure import LinearLayer, SigmoidLayer
from pybrain.structure import FullConnection

if 1: # create network
  n = FeedForwardNetwork()

  inLayer = LinearLayer(2,name = "inputs") # names are optional
    # if used, the number of neurons vanishes from the text representation of the object (what you get if you evaluate its name)
  hiddenLayer = SigmoidLayer(3, name = "middle")
  outLayer = LinearLayer(1)
  n.addInputModule(inLayer)
  n.addModule(hiddenLayer)
  n.addOutputModule(outLayer)

  in_to_hidden = FullConnection(inLayer, hiddenLayer)
  hidden_to_out = FullConnection(hiddenLayer, outLayer)
  n.addConnection(in_to_hidden)
  n.addConnection(hidden_to_out)
  
  n.sortModules()

if 0: # examine network
  print( n ) # examine network
  n.activate([1, 2]) # run network
  in_to_hidden.params
  hidden_to_out.params
  n.params # = flatten( the prev two lines )

# skipped: recurrent networks
