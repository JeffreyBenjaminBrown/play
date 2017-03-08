XML: using HXT to flatten a tree

I have XML files (specifically .mm) consisting of statements (usually categories) which might have sub-statements. For instance:

<statement>
  <id><0></id>
  <text>organism</text>
  <statement>
    <id>1</id>
    <text>plant</text>
  </statement>
  <statement>
    <id>2</id>
    <text>animal</text>
    <statement>
      <id>3</id>
      <text>fish</text>
    </statement>
  </statement>
</statement>

Every statement's id is unique.

In Haskell I want to represent each statement as

  data Statement = Statement {text :: String,
                              id :: Int,
                              parent :: Maybe Int,
                              children :: [Int] }

