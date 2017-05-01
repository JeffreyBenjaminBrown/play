-- stale tests, maybe to rescue ideas from

-- fgl, 2016 03 14
  -- fgl & HUnit
    main = runTestTT $ TestList
      [   TestLabel "tAddNodes"   tGraph
      ]

    tGraph = TestCase $ do
      let g = addNodes [Sq,Sq] L.empty
      assertBool "2 into blank" $ g == (L.mkGraph [(0,Sq),(1,Sq)] [], [0,1])

  -- fgl
    hasOnly :: [GN] -> G -> Addr -> Bool
    hasOnly allowedConstructors g a = and
      $ map (flip elem allowedConstructors)
      $ map (fromJust . L.lab g)
      $ [n | (n,lab) <- L.lsuc g a, lab==Has] -- nodes which the node at a has

    valid :: GN -> G -> Addr -> Bool
    valid Sd = hasOnly [Q $ Spl "bd"] -- hack; the Spl is ignored
    valid Ss = hasOnly [Sd]
    valid Ev = hasOnly [T 1,Sd,Ss] -- todo: test that there's only 1 time
    valid Sq = hasOnly [Ev]
