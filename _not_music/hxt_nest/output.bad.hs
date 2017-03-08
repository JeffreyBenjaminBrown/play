-- testData
[ NTree (XTag "guest" [])
    [ NTree (XTag "fname" [])
        [NTree (XText "John") []]
    , NTree (XTag "lname" [])
        [NTree (XText "Steinbeck") []]]
, NTree (XTag "guest" [])
    [ NTree (XTag "fname" [])
        [ NTree (XText "Henry") []]
    , NTree (XTag "lname" [])
        [ NTree (XText "Ford") []]
    , NTree (XTag "guest" [])
        [ NTree (XTag "fname" [])
          [ NTree (XText "Clara") []]
        , NTree (XTag "lname" [])
          [ NTree (XText "Ford") []]]]]

-- runX $ readDocument [withValidate no] "data.xml" >>> deep getGuest
[Guest {firstName = "John", lastName = "Steinbeck"},
       Guest {firstName = "John", lastName = "Steinbeck"},
       Guest {firstName = "Gloria", lastName = "Steinbeck"},
       Guest {firstName = "Gloria", lastName = "Steinbeck"},
       Guest {firstName = "Henry", lastName = "Ford"},
       Guest {firstName = "Henry", lastName = "Ford"},
       Guest {firstName = "Martha", lastName = "Ford"},
       Guest {firstName = "Martha", lastName = "Ford"}]

