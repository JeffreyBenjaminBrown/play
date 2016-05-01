data Cycle { duration :: Fractional a => a
           , events :: [ ? OscPattern ]
             -- sound :: Pattern String -> OscPattern
           }

-- define and use like a sample name in a pattern something that means to put multiple samples through the same instructions
sound $ "bd bass hit sn" where hit = "[bd, bass, sn]" 

