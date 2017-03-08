The code included this function, which I'm having trouble understanding:

  emptyBoardCoords :: Board -> [BoardCoord]
  emptyBoardCoords board = filter
    (maybe False (isNothing . mxo) . eitherToMaybe . flip cell board) boardCoords

Suppose we define these things:

  let e = Cell Nothing
  let x = Cell $ Just X
  let o = Cell $ Just O
  let r = Row [x,e,o]
  let re = Row [e,e,e]
  let b = Board [r,re,re]

cell returns an Either String Cell:

  *Main> cell (1,1) b
  Right _
  *Main> cell (0,0) b
  Right X

eitherToMaybe turns it into a Maybe Cell:

  *Main> eitherToMaybe $ cell (0,0) b
  Just X


