# returns nothing with no problems or only success messages on verbose mode [plain]

    Code
      checkDesignTest(verbose = FALSE)
    Message
      
      -- Check: Valid and missing codes 

---

    Code
      checkDesignTest(verbose = TRUE)
    Message
      
      -- Check: Subunit recoding 
      i Use names for recoded subunits.
      
      -- Check: Variables in the dataset 
      i The following 1 variable is not in info (`subunit` in blocks) but in dataset.
      It will be ignored during check: `hisei`
      
      -- Check: Valid and missing codes 
      v No deviations from design detected!

# returns nothing with no problems or only success messages on verbose mode [ansi]

    Code
      checkDesignTest(verbose = FALSE)
    Message
      
      -- [1m[1mCheck:[1m[22m Valid and missing codes 

---

    Code
      checkDesignTest(verbose = TRUE)
    Message
      
      -- [1m[1mCheck:[1m[22m Subunit recoding 
      [36mi[39m Use names for recoded subunits.
      
      -- [1m[1mCheck:[1m[22m Variables in the dataset 
      [36mi[39m The following 1 variable is not in info (`subunit` in [32mblocks[39m) but in dataset.
      It will be ignored during check: `hisei`
      
      -- [1m[1mCheck:[1m[22m Valid and missing codes 
      [32mv[39m No deviations from design detected!

# returns nothing with no problems or only success messages on verbose mode [unicode]

    Code
      checkDesignTest(verbose = FALSE)
    Message
      
      ── Check: Valid and missing codes 

---

    Code
      checkDesignTest(verbose = TRUE)
    Message
      
      ── Check: Subunit recoding 
      ℹ Use names for recoded subunits.
      
      ── Check: Variables in the dataset 
      ℹ The following 1 variable is not in info (`subunit` in blocks) but in dataset.
      It will be ignored during check: `hisei`
      
      ── Check: Valid and missing codes 
      ✔ No deviations from design detected!

# returns nothing with no problems or only success messages on verbose mode [fancy]

    Code
      checkDesignTest(verbose = FALSE)
    Message
      
      ── [1m[1mCheck:[1m[22m Valid and missing codes 

---

    Code
      checkDesignTest(verbose = TRUE)
    Message
      
      ── [1m[1mCheck:[1m[22m Subunit recoding 
      [36mℹ[39m Use names for recoded subunits.
      
      ── [1m[1mCheck:[1m[22m Variables in the dataset 
      [36mℹ[39m The following 1 variable is not in info (`subunit` in [32mblocks[39m) but in dataset.
      It will be ignored during check: `hisei`
      
      ── [1m[1mCheck:[1m[22m Valid and missing codes 
      [32m✔[39m No deviations from design detected!

# identifies ID variables that cannot be found in the dataset [plain]

    Code
      checkDesignTest(id = "FalseID")
    Condition
      Error in `checkDesign()`:
      ! ID variable `FalseID` not found in dataset.

# identifies ID variables that cannot be found in the dataset [ansi]

    Code
      checkDesignTest(id = "FalseID")
    Condition
      [1m[33mError[39m in `checkDesign()`:[22m
      [1m[22m[33m![39m ID variable `FalseID` not found in dataset.

# identifies ID variables that cannot be found in the dataset [unicode]

    Code
      checkDesignTest(id = "FalseID")
    Condition
      Error in `checkDesign()`:
      ! ID variable `FalseID` not found in dataset.

# identifies ID variables that cannot be found in the dataset [fancy]

    Code
      checkDesignTest(id = "FalseID")
    Condition
      [1m[33mError[39m in `checkDesign()`:[22m
      [1m[22m[33m![39m ID variable `FalseID` not found in dataset.

# throws danger messages when block names in blocks do not equal those in booklets [plain]

    Code
      checkDesignTest(blocks = test_block_block)
    Message
      
      -- Check: Block names 
      x Block names set in blocks does not equal block names set in booklets. Please
      check.
      > The following 1 block is in blocks but not in booklets: `bl9`
      
      -- Check: Subunit recoding 
      i Use names for recoded subunits.
      ! Found no names to recode 1 subunit: `I99` This subunit will be ignored in
      determining 'mnr'.
      
      -- Check: Variables in the dataset 
      i The following 1 variable is not in info (`subunit` in blocks) but in dataset.
      It will be ignored during check: `hisei`
      
      -- Check: Valid and missing codes 
      v No deviations from design detected!

---

    Code
      checkDesignTest(blocks = test_block_block)
    Message
      
      -- Check: Block names 
      x Block names set in blocks does not equal block names set in booklets. Please
      check.
      > The following 1 block is in booklets but not in blocks: `bl1`
      > No check for valid and missing codes will be available.
      > The following 1 block is in blocks but not in booklets: `bl9`
      
      -- Check: Subunit recoding 
      i Use names for recoded subunits.
      
      -- Check: Variables in the dataset 
      i The following 1 variable is not in info (`subunit` in blocks) but in dataset.
      It will be ignored during check: `hisei`
      
      -- Check: Valid and missing codes 
      x Not available as there is 1 block in booklets that is not in blocks!

---

    Code
      checkDesignTest(booklets = test_booklet_block)
    Message
      
      -- Check: Booklet names 
      x Booklet names set in rotation does not equal booklet names set in booklets.
      Please check.
      > The following 1 booklet is in booklets but not in rotation: `booklet4`
      
      -- Check: Subunit recoding 
      i Use names for recoded subunits.
      
      -- Check: Variables in the dataset 
      i The following 1 variable is not in info (`subunit` in blocks) but in dataset.
      It will be ignored during check: `hisei`
      
      -- Check: Valid and missing codes 
      v No deviations from design detected!

---

    Code
      checkDesignTest(booklets = test_booklet_block)
    Message
      
      -- Check: Block names 
      x Block names set in blocks does not equal block names set in booklets. Please
      check.
      > The following 1 block is in booklets but not in blocks: `bl8`
      > No check for valid and missing codes will be available.
      
      -- Check: Subunit recoding 
      i Use names for recoded subunits.
      
      -- Check: Variables in the dataset 
      i The following 1 variable is not in info (`subunit` in blocks) but in dataset.
      It will be ignored during check: `hisei`
      
      -- Check: Valid and missing codes 
      x Not available as there is 1 block in booklets that is not in blocks!

# throws danger messages when block names in blocks do not equal those in booklets [ansi]

    Code
      checkDesignTest(blocks = test_block_block)
    Message
      
      -- [1m[1mCheck:[1m[22m Block names 
      [31mx[39m Block names set in [32mblocks[39m does not equal block names set in [32mbooklets[39m. Please
      check.
      > The following 1 block is in [32mblocks[39m but not in [32mbooklets[39m: `bl9`
      
      -- [1m[1mCheck:[1m[22m Subunit recoding 
      [36mi[39m Use names for recoded subunits.
      [33m![39m Found no names to recode 1 subunit: `I99` This subunit will be ignored in
      determining 'mnr'.
      
      -- [1m[1mCheck:[1m[22m Variables in the dataset 
      [36mi[39m The following 1 variable is not in info (`subunit` in [32mblocks[39m) but in dataset.
      It will be ignored during check: `hisei`
      
      -- [1m[1mCheck:[1m[22m Valid and missing codes 
      [32mv[39m No deviations from design detected!

---

    Code
      checkDesignTest(blocks = test_block_block)
    Message
      
      -- [1m[1mCheck:[1m[22m Block names 
      [31mx[39m Block names set in [32mblocks[39m does not equal block names set in [32mbooklets[39m. Please
      check.
      > The following 1 block is in [32mbooklets[39m but not in [32mblocks[39m: `bl1`
      > No check for valid and missing codes will be available.
      > The following 1 block is in [32mblocks[39m but not in [32mbooklets[39m: `bl9`
      
      -- [1m[1mCheck:[1m[22m Subunit recoding 
      [36mi[39m Use names for recoded subunits.
      
      -- [1m[1mCheck:[1m[22m Variables in the dataset 
      [36mi[39m The following 1 variable is not in info (`subunit` in [32mblocks[39m) but in dataset.
      It will be ignored during check: `hisei`
      
      -- [1m[1mCheck:[1m[22m Valid and missing codes 
      [31mx[39m Not available as there is 1 block in booklets that is not in blocks!

---

    Code
      checkDesignTest(booklets = test_booklet_block)
    Message
      
      -- [1m[1mCheck:[1m[22m Booklet names 
      [31mx[39m Booklet names set in [32mrotation[39m does not equal booklet names set in [32mbooklets[39m.
      Please check.
      > The following 1 booklet is in [32mbooklets[39m but not in [32mrotation[39m: `booklet4`
      
      -- [1m[1mCheck:[1m[22m Subunit recoding 
      [36mi[39m Use names for recoded subunits.
      
      -- [1m[1mCheck:[1m[22m Variables in the dataset 
      [36mi[39m The following 1 variable is not in info (`subunit` in [32mblocks[39m) but in dataset.
      It will be ignored during check: `hisei`
      
      -- [1m[1mCheck:[1m[22m Valid and missing codes 
      [32mv[39m No deviations from design detected!

---

    Code
      checkDesignTest(booklets = test_booklet_block)
    Message
      
      -- [1m[1mCheck:[1m[22m Block names 
      [31mx[39m Block names set in [32mblocks[39m does not equal block names set in [32mbooklets[39m. Please
      check.
      > The following 1 block is in [32mbooklets[39m but not in [32mblocks[39m: `bl8`
      > No check for valid and missing codes will be available.
      
      -- [1m[1mCheck:[1m[22m Subunit recoding 
      [36mi[39m Use names for recoded subunits.
      
      -- [1m[1mCheck:[1m[22m Variables in the dataset 
      [36mi[39m The following 1 variable is not in info (`subunit` in [32mblocks[39m) but in dataset.
      It will be ignored during check: `hisei`
      
      -- [1m[1mCheck:[1m[22m Valid and missing codes 
      [31mx[39m Not available as there is 1 block in booklets that is not in blocks!

# throws danger messages when block names in blocks do not equal those in booklets [unicode]

    Code
      checkDesignTest(blocks = test_block_block)
    Message
      
      ── Check: Block names 
      ✖ Block names set in blocks does not equal block names set in booklets. Please
      check.
      → The following 1 block is in blocks but not in booklets: `bl9`
      
      ── Check: Subunit recoding 
      ℹ Use names for recoded subunits.
      ! Found no names to recode 1 subunit: `I99` This subunit will be ignored in
      determining 'mnr'.
      
      ── Check: Variables in the dataset 
      ℹ The following 1 variable is not in info (`subunit` in blocks) but in dataset.
      It will be ignored during check: `hisei`
      
      ── Check: Valid and missing codes 
      ✔ No deviations from design detected!

---

    Code
      checkDesignTest(blocks = test_block_block)
    Message
      
      ── Check: Block names 
      ✖ Block names set in blocks does not equal block names set in booklets. Please
      check.
      → The following 1 block is in booklets but not in blocks: `bl1`
      → No check for valid and missing codes will be available.
      → The following 1 block is in blocks but not in booklets: `bl9`
      
      ── Check: Subunit recoding 
      ℹ Use names for recoded subunits.
      
      ── Check: Variables in the dataset 
      ℹ The following 1 variable is not in info (`subunit` in blocks) but in dataset.
      It will be ignored during check: `hisei`
      
      ── Check: Valid and missing codes 
      ✖ Not available as there is 1 block in booklets that is not in blocks!

---

    Code
      checkDesignTest(booklets = test_booklet_block)
    Message
      
      ── Check: Booklet names 
      ✖ Booklet names set in rotation does not equal booklet names set in booklets.
      Please check.
      → The following 1 booklet is in booklets but not in rotation: `booklet4`
      
      ── Check: Subunit recoding 
      ℹ Use names for recoded subunits.
      
      ── Check: Variables in the dataset 
      ℹ The following 1 variable is not in info (`subunit` in blocks) but in dataset.
      It will be ignored during check: `hisei`
      
      ── Check: Valid and missing codes 
      ✔ No deviations from design detected!

---

    Code
      checkDesignTest(booklets = test_booklet_block)
    Message
      
      ── Check: Block names 
      ✖ Block names set in blocks does not equal block names set in booklets. Please
      check.
      → The following 1 block is in booklets but not in blocks: `bl8`
      → No check for valid and missing codes will be available.
      
      ── Check: Subunit recoding 
      ℹ Use names for recoded subunits.
      
      ── Check: Variables in the dataset 
      ℹ The following 1 variable is not in info (`subunit` in blocks) but in dataset.
      It will be ignored during check: `hisei`
      
      ── Check: Valid and missing codes 
      ✖ Not available as there is 1 block in booklets that is not in blocks!

# throws danger messages when block names in blocks do not equal those in booklets [fancy]

    Code
      checkDesignTest(blocks = test_block_block)
    Message
      
      ── [1m[1mCheck:[1m[22m Block names 
      [31m✖[39m Block names set in [32mblocks[39m does not equal block names set in [32mbooklets[39m. Please
      check.
      → The following 1 block is in [32mblocks[39m but not in [32mbooklets[39m: `bl9`
      
      ── [1m[1mCheck:[1m[22m Subunit recoding 
      [36mℹ[39m Use names for recoded subunits.
      [33m![39m Found no names to recode 1 subunit: `I99` This subunit will be ignored in
      determining 'mnr'.
      
      ── [1m[1mCheck:[1m[22m Variables in the dataset 
      [36mℹ[39m The following 1 variable is not in info (`subunit` in [32mblocks[39m) but in dataset.
      It will be ignored during check: `hisei`
      
      ── [1m[1mCheck:[1m[22m Valid and missing codes 
      [32m✔[39m No deviations from design detected!

---

    Code
      checkDesignTest(blocks = test_block_block)
    Message
      
      ── [1m[1mCheck:[1m[22m Block names 
      [31m✖[39m Block names set in [32mblocks[39m does not equal block names set in [32mbooklets[39m. Please
      check.
      → The following 1 block is in [32mbooklets[39m but not in [32mblocks[39m: `bl1`
      → No check for valid and missing codes will be available.
      → The following 1 block is in [32mblocks[39m but not in [32mbooklets[39m: `bl9`
      
      ── [1m[1mCheck:[1m[22m Subunit recoding 
      [36mℹ[39m Use names for recoded subunits.
      
      ── [1m[1mCheck:[1m[22m Variables in the dataset 
      [36mℹ[39m The following 1 variable is not in info (`subunit` in [32mblocks[39m) but in dataset.
      It will be ignored during check: `hisei`
      
      ── [1m[1mCheck:[1m[22m Valid and missing codes 
      [31m✖[39m Not available as there is 1 block in booklets that is not in blocks!

---

    Code
      checkDesignTest(booklets = test_booklet_block)
    Message
      
      ── [1m[1mCheck:[1m[22m Booklet names 
      [31m✖[39m Booklet names set in [32mrotation[39m does not equal booklet names set in [32mbooklets[39m.
      Please check.
      → The following 1 booklet is in [32mbooklets[39m but not in [32mrotation[39m: `booklet4`
      
      ── [1m[1mCheck:[1m[22m Subunit recoding 
      [36mℹ[39m Use names for recoded subunits.
      
      ── [1m[1mCheck:[1m[22m Variables in the dataset 
      [36mℹ[39m The following 1 variable is not in info (`subunit` in [32mblocks[39m) but in dataset.
      It will be ignored during check: `hisei`
      
      ── [1m[1mCheck:[1m[22m Valid and missing codes 
      [32m✔[39m No deviations from design detected!

---

    Code
      checkDesignTest(booklets = test_booklet_block)
    Message
      
      ── [1m[1mCheck:[1m[22m Block names 
      [31m✖[39m Block names set in [32mblocks[39m does not equal block names set in [32mbooklets[39m. Please
      check.
      → The following 1 block is in [32mbooklets[39m but not in [32mblocks[39m: `bl8`
      → No check for valid and missing codes will be available.
      
      ── [1m[1mCheck:[1m[22m Subunit recoding 
      [36mℹ[39m Use names for recoded subunits.
      
      ── [1m[1mCheck:[1m[22m Variables in the dataset 
      [36mℹ[39m The following 1 variable is not in info (`subunit` in [32mblocks[39m) but in dataset.
      It will be ignored during check: `hisei`
      
      ── [1m[1mCheck:[1m[22m Valid and missing codes 
      [31m✖[39m Not available as there is 1 block in booklets that is not in blocks!

# throws danger messages when booklet names in booklets do not equal those in rotation [plain]

    Code
      checkDesignTest(booklets = test_booklet_booklet)
    Message
      
      -- Check: Booklet names 
      x Booklet names set in rotation does not equal booklet names set in booklets.
      Please check.
      > The following 1 booklet is in rotation but not in booklets: `booklet1`
      > The following 1 booklet is in booklets but not in rotation: `booklet9`
      
      -- Check: Subunit recoding 
      i Use names for recoded subunits.
      
      -- Check: Variables in the dataset 
      i The following 1 variable is not in info (`subunit` in blocks) but in dataset.
      It will be ignored during check: `hisei`
      
      -- Check: Valid and missing codes 
      v No deviations from design detected!

---

    Code
      checkDesignTest(rotation = test_rotation_booklet)
    Message
      
      -- Check: Booklet names 
      x Booklet names set in rotation does not equal booklet names set in booklets.
      Please check.
      > The following 1 booklet is in rotation but not in booklets: `booklet8`
      > The following 1 booklet is in booklets but not in rotation: `booklet1`
      
      -- Check: Subunit recoding 
      i Use names for recoded subunits.
      
      -- Check: Variables in the dataset 
      i The following 1 variable is not in info (`subunit` in blocks) but in dataset.
      It will be ignored during check: `hisei`
      
      -- Check: Valid and missing codes 
      v No deviations from design detected!

# throws danger messages when booklet names in booklets do not equal those in rotation [ansi]

    Code
      checkDesignTest(booklets = test_booklet_booklet)
    Message
      
      -- [1m[1mCheck:[1m[22m Booklet names 
      [31mx[39m Booklet names set in [32mrotation[39m does not equal booklet names set in [32mbooklets[39m.
      Please check.
      > The following 1 booklet is in [32mrotation[39m but not in [32mbooklets[39m: `booklet1`
      > The following 1 booklet is in [32mbooklets[39m but not in [32mrotation[39m: `booklet9`
      
      -- [1m[1mCheck:[1m[22m Subunit recoding 
      [36mi[39m Use names for recoded subunits.
      
      -- [1m[1mCheck:[1m[22m Variables in the dataset 
      [36mi[39m The following 1 variable is not in info (`subunit` in [32mblocks[39m) but in dataset.
      It will be ignored during check: `hisei`
      
      -- [1m[1mCheck:[1m[22m Valid and missing codes 
      [32mv[39m No deviations from design detected!

---

    Code
      checkDesignTest(rotation = test_rotation_booklet)
    Message
      
      -- [1m[1mCheck:[1m[22m Booklet names 
      [31mx[39m Booklet names set in [32mrotation[39m does not equal booklet names set in [32mbooklets[39m.
      Please check.
      > The following 1 booklet is in [32mrotation[39m but not in [32mbooklets[39m: `booklet8`
      > The following 1 booklet is in [32mbooklets[39m but not in [32mrotation[39m: `booklet1`
      
      -- [1m[1mCheck:[1m[22m Subunit recoding 
      [36mi[39m Use names for recoded subunits.
      
      -- [1m[1mCheck:[1m[22m Variables in the dataset 
      [36mi[39m The following 1 variable is not in info (`subunit` in [32mblocks[39m) but in dataset.
      It will be ignored during check: `hisei`
      
      -- [1m[1mCheck:[1m[22m Valid and missing codes 
      [32mv[39m No deviations from design detected!

# throws danger messages when booklet names in booklets do not equal those in rotation [unicode]

    Code
      checkDesignTest(booklets = test_booklet_booklet)
    Message
      
      ── Check: Booklet names 
      ✖ Booklet names set in rotation does not equal booklet names set in booklets.
      Please check.
      → The following 1 booklet is in rotation but not in booklets: `booklet1`
      → The following 1 booklet is in booklets but not in rotation: `booklet9`
      
      ── Check: Subunit recoding 
      ℹ Use names for recoded subunits.
      
      ── Check: Variables in the dataset 
      ℹ The following 1 variable is not in info (`subunit` in blocks) but in dataset.
      It will be ignored during check: `hisei`
      
      ── Check: Valid and missing codes 
      ✔ No deviations from design detected!

---

    Code
      checkDesignTest(rotation = test_rotation_booklet)
    Message
      
      ── Check: Booklet names 
      ✖ Booklet names set in rotation does not equal booklet names set in booklets.
      Please check.
      → The following 1 booklet is in rotation but not in booklets: `booklet8`
      → The following 1 booklet is in booklets but not in rotation: `booklet1`
      
      ── Check: Subunit recoding 
      ℹ Use names for recoded subunits.
      
      ── Check: Variables in the dataset 
      ℹ The following 1 variable is not in info (`subunit` in blocks) but in dataset.
      It will be ignored during check: `hisei`
      
      ── Check: Valid and missing codes 
      ✔ No deviations from design detected!

# throws danger messages when booklet names in booklets do not equal those in rotation [fancy]

    Code
      checkDesignTest(booklets = test_booklet_booklet)
    Message
      
      ── [1m[1mCheck:[1m[22m Booklet names 
      [31m✖[39m Booklet names set in [32mrotation[39m does not equal booklet names set in [32mbooklets[39m.
      Please check.
      → The following 1 booklet is in [32mrotation[39m but not in [32mbooklets[39m: `booklet1`
      → The following 1 booklet is in [32mbooklets[39m but not in [32mrotation[39m: `booklet9`
      
      ── [1m[1mCheck:[1m[22m Subunit recoding 
      [36mℹ[39m Use names for recoded subunits.
      
      ── [1m[1mCheck:[1m[22m Variables in the dataset 
      [36mℹ[39m The following 1 variable is not in info (`subunit` in [32mblocks[39m) but in dataset.
      It will be ignored during check: `hisei`
      
      ── [1m[1mCheck:[1m[22m Valid and missing codes 
      [32m✔[39m No deviations from design detected!

---

    Code
      checkDesignTest(rotation = test_rotation_booklet)
    Message
      
      ── [1m[1mCheck:[1m[22m Booklet names 
      [31m✖[39m Booklet names set in [32mrotation[39m does not equal booklet names set in [32mbooklets[39m.
      Please check.
      → The following 1 booklet is in [32mrotation[39m but not in [32mbooklets[39m: `booklet8`
      → The following 1 booklet is in [32mbooklets[39m but not in [32mrotation[39m: `booklet1`
      
      ── [1m[1mCheck:[1m[22m Subunit recoding 
      [36mℹ[39m Use names for recoded subunits.
      
      ── [1m[1mCheck:[1m[22m Variables in the dataset 
      [36mℹ[39m The following 1 variable is not in info (`subunit` in [32mblocks[39m) but in dataset.
      It will be ignored during check: `hisei`
      
      ── [1m[1mCheck:[1m[22m Valid and missing codes 
      [32m✔[39m No deviations from design detected!

# throws warning when more variables in dataset available than in blocks$subunit [plain]

    Code
      checkDesignTest(dat = within(prepDat, hisei <- NULL))
    Message
      
      -- Check: Subunit recoding 
      i Use names for recoded subunits.
      
      -- Check: Valid and missing codes 
      v No deviations from design detected!

---

    Code
      checkDesignTest(dat = within(prepDat, {
        hisei <- NULL
        testB <- 2
        testA <- 1
      }))
    Message
      
      -- Check: Subunit recoding 
      i Use names for recoded subunits.
      
      -- Check: Variables in the dataset 
      i The following 2 variables are not in info (`subunit` in blocks) but in
      dataset. They will be ignored during check: `testA` and `testB`
      
      -- Check: Valid and missing codes 
      v No deviations from design detected!

# throws warning when more variables in dataset available than in blocks$subunit [ansi]

    Code
      checkDesignTest(dat = within(prepDat, hisei <- NULL))
    Message
      
      -- [1m[1mCheck:[1m[22m Subunit recoding 
      [36mi[39m Use names for recoded subunits.
      
      -- [1m[1mCheck:[1m[22m Valid and missing codes 
      [32mv[39m No deviations from design detected!

---

    Code
      checkDesignTest(dat = within(prepDat, {
        hisei <- NULL
        testB <- 2
        testA <- 1
      }))
    Message
      
      -- [1m[1mCheck:[1m[22m Subunit recoding 
      [36mi[39m Use names for recoded subunits.
      
      -- [1m[1mCheck:[1m[22m Variables in the dataset 
      [36mi[39m The following 2 variables are not in info (`subunit` in [32mblocks[39m) but in
      dataset. They will be ignored during check: `testA` and `testB`
      
      -- [1m[1mCheck:[1m[22m Valid and missing codes 
      [32mv[39m No deviations from design detected!

# throws warning when more variables in dataset available than in blocks$subunit [unicode]

    Code
      checkDesignTest(dat = within(prepDat, hisei <- NULL))
    Message
      
      ── Check: Subunit recoding 
      ℹ Use names for recoded subunits.
      
      ── Check: Valid and missing codes 
      ✔ No deviations from design detected!

---

    Code
      checkDesignTest(dat = within(prepDat, {
        hisei <- NULL
        testB <- 2
        testA <- 1
      }))
    Message
      
      ── Check: Subunit recoding 
      ℹ Use names for recoded subunits.
      
      ── Check: Variables in the dataset 
      ℹ The following 2 variables are not in info (`subunit` in blocks) but in
      dataset. They will be ignored during check: `testA` and `testB`
      
      ── Check: Valid and missing codes 
      ✔ No deviations from design detected!

# throws warning when more variables in dataset available than in blocks$subunit [fancy]

    Code
      checkDesignTest(dat = within(prepDat, hisei <- NULL))
    Message
      
      ── [1m[1mCheck:[1m[22m Subunit recoding 
      [36mℹ[39m Use names for recoded subunits.
      
      ── [1m[1mCheck:[1m[22m Valid and missing codes 
      [32m✔[39m No deviations from design detected!

---

    Code
      checkDesignTest(dat = within(prepDat, {
        hisei <- NULL
        testB <- 2
        testA <- 1
      }))
    Message
      
      ── [1m[1mCheck:[1m[22m Subunit recoding 
      [36mℹ[39m Use names for recoded subunits.
      
      ── [1m[1mCheck:[1m[22m Variables in the dataset 
      [36mℹ[39m The following 2 variables are not in info (`subunit` in [32mblocks[39m) but in
      dataset. They will be ignored during check: `testA` and `testB`
      
      ── [1m[1mCheck:[1m[22m Valid and missing codes 
      [32m✔[39m No deviations from design detected!

# throws warning when more variables in blocks$subunit than in dataset [plain]

    Code
      checkDesignTest(dat = within(prepDat, hisei <- NULL))
    Message
      
      -- Check: Subunit recoding 
      i Use names for recoded subunits.
      
      -- Check: Valid and missing codes 
      v No deviations from design detected!

---

    Code
      checkDesignTest(dat = prepDat[, -c(2, 7)])
    Message
      
      -- Check: Subunit recoding 
      i Use names for recoded subunits.
      
      -- Check: Variables in Info 
      i The following 1 variable is not in dataset but in info (`subunit` in blocks).
      It will be ignored during check: `I05R`
      
      -- Check: Valid and missing codes 
      v No deviations from design detected!

# throws warning when more variables in blocks$subunit than in dataset [ansi]

    Code
      checkDesignTest(dat = within(prepDat, hisei <- NULL))
    Message
      
      -- [1m[1mCheck:[1m[22m Subunit recoding 
      [36mi[39m Use names for recoded subunits.
      
      -- [1m[1mCheck:[1m[22m Valid and missing codes 
      [32mv[39m No deviations from design detected!

---

    Code
      checkDesignTest(dat = prepDat[, -c(2, 7)])
    Message
      
      -- [1m[1mCheck:[1m[22m Subunit recoding 
      [36mi[39m Use names for recoded subunits.
      
      -- [1m[1mCheck:[1m[22m Variables in Info 
      [36mi[39m The following 1 variable is not in dataset but in info (`subunit` in [32mblocks[39m).
      It will be ignored during check: `I05R`
      
      -- [1m[1mCheck:[1m[22m Valid and missing codes 
      [32mv[39m No deviations from design detected!

# throws warning when more variables in blocks$subunit than in dataset [unicode]

    Code
      checkDesignTest(dat = within(prepDat, hisei <- NULL))
    Message
      
      ── Check: Subunit recoding 
      ℹ Use names for recoded subunits.
      
      ── Check: Valid and missing codes 
      ✔ No deviations from design detected!

---

    Code
      checkDesignTest(dat = prepDat[, -c(2, 7)])
    Message
      
      ── Check: Subunit recoding 
      ℹ Use names for recoded subunits.
      
      ── Check: Variables in Info 
      ℹ The following 1 variable is not in dataset but in info (`subunit` in blocks).
      It will be ignored during check: `I05R`
      
      ── Check: Valid and missing codes 
      ✔ No deviations from design detected!

# throws warning when more variables in blocks$subunit than in dataset [fancy]

    Code
      checkDesignTest(dat = within(prepDat, hisei <- NULL))
    Message
      
      ── [1m[1mCheck:[1m[22m Subunit recoding 
      [36mℹ[39m Use names for recoded subunits.
      
      ── [1m[1mCheck:[1m[22m Valid and missing codes 
      [32m✔[39m No deviations from design detected!

---

    Code
      checkDesignTest(dat = prepDat[, -c(2, 7)])
    Message
      
      ── [1m[1mCheck:[1m[22m Subunit recoding 
      [36mℹ[39m Use names for recoded subunits.
      
      ── [1m[1mCheck:[1m[22m Variables in Info 
      [36mℹ[39m The following 1 variable is not in dataset but in info (`subunit` in [32mblocks[39m).
      It will be ignored during check: `I05R`
      
      ── [1m[1mCheck:[1m[22m Valid and missing codes 
      [32m✔[39m No deviations from design detected!

# identifies incorrect sysMis codes and allows for user-defined sysMis [plain]

    Code
      checkDesignTest(dat = within(prepDat, I01R <- ifelse(I01R == "mbi", "mbd", I01R)),
      sysMis = "mbd")
    Message
      
      -- Check: Subunit recoding 
      i Use names for recoded subunits.
      
      -- Check: Variables in the dataset 
      i The following 1 variable is not in info (`subunit` in blocks) but in dataset.
      It will be ignored during check: `hisei`
      
      -- Check: Valid and missing codes 
      i Deviations from design detected!
      x Found for 1 subunit sysMis instead of valid codes for booklet `booklet1`:
      I01R
      i I01R (6 cases: person101, person111, person112, person113, person144, and person155)

---

    Code
      checkDesignTest(dat = within(userDefinedSysMis, I01R <- ifelse(I01R == "mbi",
      NA, I01R)), sysMis = "NA")
    Message
      
      -- Check: Subunit recoding 
      i Use names for recoded subunits.
      
      -- Check: Variables in the dataset 
      i The following 1 variable is not in info (`subunit` in blocks) but in dataset.
      It will be ignored during check: `hisei`
      
      -- Check: Valid and missing codes 
      i Deviations from design detected!
      x Found for 1 subunit sysMis instead of valid codes for booklet `booklet1`:
      I01R
      i I01R (6 cases: person101, person111, person112, person113, person144, and person155)

# identifies incorrect sysMis codes and allows for user-defined sysMis [ansi]

    Code
      checkDesignTest(dat = within(prepDat, I01R <- ifelse(I01R == "mbi", "mbd", I01R)),
      sysMis = "mbd")
    Message
      
      -- [1m[1mCheck:[1m[22m Subunit recoding 
      [36mi[39m Use names for recoded subunits.
      
      -- [1m[1mCheck:[1m[22m Variables in the dataset 
      [36mi[39m The following 1 variable is not in info (`subunit` in [32mblocks[39m) but in dataset.
      It will be ignored during check: `hisei`
      
      -- [1m[1mCheck:[1m[22m Valid and missing codes 
      [36mi[39m Deviations from design detected!
      [31mx[39m Found for 1 subunit sysMis instead of valid codes for booklet `booklet1`:
      I01R
      [36mi[39m I01R (6 cases: person101, person111, person112, person113, person144, and person155)

---

    Code
      checkDesignTest(dat = within(userDefinedSysMis, I01R <- ifelse(I01R == "mbi",
      NA, I01R)), sysMis = "NA")
    Message
      
      -- [1m[1mCheck:[1m[22m Subunit recoding 
      [36mi[39m Use names for recoded subunits.
      
      -- [1m[1mCheck:[1m[22m Variables in the dataset 
      [36mi[39m The following 1 variable is not in info (`subunit` in [32mblocks[39m) but in dataset.
      It will be ignored during check: `hisei`
      
      -- [1m[1mCheck:[1m[22m Valid and missing codes 
      [36mi[39m Deviations from design detected!
      [31mx[39m Found for 1 subunit sysMis instead of valid codes for booklet `booklet1`:
      I01R
      [36mi[39m I01R (6 cases: person101, person111, person112, person113, person144, and person155)

# identifies incorrect sysMis codes and allows for user-defined sysMis [unicode]

    Code
      checkDesignTest(dat = within(prepDat, I01R <- ifelse(I01R == "mbi", "mbd", I01R)),
      sysMis = "mbd")
    Message
      
      ── Check: Subunit recoding 
      ℹ Use names for recoded subunits.
      
      ── Check: Variables in the dataset 
      ℹ The following 1 variable is not in info (`subunit` in blocks) but in dataset.
      It will be ignored during check: `hisei`
      
      ── Check: Valid and missing codes 
      ℹ Deviations from design detected!
      ✖ Found for 1 subunit sysMis instead of valid codes for booklet `booklet1`:
      I01R
      ℹ I01R (6 cases: person101, person111, person112, person113, person144, and person155)

---

    Code
      checkDesignTest(dat = within(userDefinedSysMis, I01R <- ifelse(I01R == "mbi",
      NA, I01R)), sysMis = "NA")
    Message
      
      ── Check: Subunit recoding 
      ℹ Use names for recoded subunits.
      
      ── Check: Variables in the dataset 
      ℹ The following 1 variable is not in info (`subunit` in blocks) but in dataset.
      It will be ignored during check: `hisei`
      
      ── Check: Valid and missing codes 
      ℹ Deviations from design detected!
      ✖ Found for 1 subunit sysMis instead of valid codes for booklet `booklet1`:
      I01R
      ℹ I01R (6 cases: person101, person111, person112, person113, person144, and person155)

# identifies incorrect sysMis codes and allows for user-defined sysMis [fancy]

    Code
      checkDesignTest(dat = within(prepDat, I01R <- ifelse(I01R == "mbi", "mbd", I01R)),
      sysMis = "mbd")
    Message
      
      ── [1m[1mCheck:[1m[22m Subunit recoding 
      [36mℹ[39m Use names for recoded subunits.
      
      ── [1m[1mCheck:[1m[22m Variables in the dataset 
      [36mℹ[39m The following 1 variable is not in info (`subunit` in [32mblocks[39m) but in dataset.
      It will be ignored during check: `hisei`
      
      ── [1m[1mCheck:[1m[22m Valid and missing codes 
      [36mℹ[39m Deviations from design detected!
      [31m✖[39m Found for 1 subunit sysMis instead of valid codes for booklet `booklet1`:
      I01R
      [36mℹ[39m I01R (6 cases: person101, person111, person112, person113, person144, and person155)

---

    Code
      checkDesignTest(dat = within(userDefinedSysMis, I01R <- ifelse(I01R == "mbi",
      NA, I01R)), sysMis = "NA")
    Message
      
      ── [1m[1mCheck:[1m[22m Subunit recoding 
      [36mℹ[39m Use names for recoded subunits.
      
      ── [1m[1mCheck:[1m[22m Variables in the dataset 
      [36mℹ[39m The following 1 variable is not in info (`subunit` in [32mblocks[39m) but in dataset.
      It will be ignored during check: `hisei`
      
      ── [1m[1mCheck:[1m[22m Valid and missing codes 
      [36mℹ[39m Deviations from design detected!
      [31m✖[39m Found for 1 subunit sysMis instead of valid codes for booklet `booklet1`:
      I01R
      [36mℹ[39m I01R (6 cases: person101, person111, person112, person113, person144, and person155)

# identifies incorrect vc codes [plain]

    Code
      checkDesignTest(dat = within(prepDat, I22R <- ifelse(I22R == "mbd", "mbi", I22R)),
      sysMis = "mbd")
    Message
      
      -- Check: Subunit recoding 
      i Use names for recoded subunits.
      
      -- Check: Variables in the dataset 
      i The following 1 variable is not in info (`subunit` in blocks) but in dataset.
      It will be ignored during check: `hisei`
      
      -- Check: Valid and missing codes 
      i Deviations from design detected!
      x Found for 1 subunit valid codes instead of sysMis for booklet `booklet1`:
      I22R
      i I22R (100 cases: person100, person101, person102, person103, person104, person105, person106, person107, person108, person109, person110, person111, person112, person113, person114, person115, person116, person117, person118, person119, person120, person121, person122, person123, person124, person125, person126, person127, person128, person129, person130, person131, person132, person133, person134, person135, person136, person137, person138, person139, person140, person141, person142, person143, person144, person145, person146, person147, person148, person149, person150, person151, person152, person153, person154, person155, person156, person157, person158, person159, person160, person161, person162, person163, person164, person165, person166, person167, person168, person169, person170, person171, person172, person173, person174, person175, person176, person177, person178, person179, person180, person181, person182, person183, person184, person185, person186, person187, person188, person189, person190, person191, person192, person193, person194, person195, person196, person197, person198, and person199)

---

    Code
      checkDesignTest(dat = within(userDefinedSysMis, I22R <- ifelse(is.na(I22R),
      "mbi", I22R)), sysMis = "NA")
    Message
      
      -- Check: Subunit recoding 
      i Use names for recoded subunits.
      
      -- Check: Variables in the dataset 
      i The following 1 variable is not in info (`subunit` in blocks) but in dataset.
      It will be ignored during check: `hisei`
      
      -- Check: Valid and missing codes 
      i Deviations from design detected!
      x Found for 1 subunit valid codes instead of sysMis for booklet `booklet1`:
      I22R
      i I22R (100 cases: person100, person101, person102, person103, person104, person105, person106, person107, person108, person109, person110, person111, person112, person113, person114, person115, person116, person117, person118, person119, person120, person121, person122, person123, person124, person125, person126, person127, person128, person129, person130, person131, person132, person133, person134, person135, person136, person137, person138, person139, person140, person141, person142, person143, person144, person145, person146, person147, person148, person149, person150, person151, person152, person153, person154, person155, person156, person157, person158, person159, person160, person161, person162, person163, person164, person165, person166, person167, person168, person169, person170, person171, person172, person173, person174, person175, person176, person177, person178, person179, person180, person181, person182, person183, person184, person185, person186, person187, person188, person189, person190, person191, person192, person193, person194, person195, person196, person197, person198, and person199)

# identifies incorrect vc codes [ansi]

    Code
      checkDesignTest(dat = within(prepDat, I22R <- ifelse(I22R == "mbd", "mbi", I22R)),
      sysMis = "mbd")
    Message
      
      -- [1m[1mCheck:[1m[22m Subunit recoding 
      [36mi[39m Use names for recoded subunits.
      
      -- [1m[1mCheck:[1m[22m Variables in the dataset 
      [36mi[39m The following 1 variable is not in info (`subunit` in [32mblocks[39m) but in dataset.
      It will be ignored during check: `hisei`
      
      -- [1m[1mCheck:[1m[22m Valid and missing codes 
      [36mi[39m Deviations from design detected!
      [31mx[39m Found for 1 subunit valid codes instead of sysMis for booklet `booklet1`:
      I22R
      [36mi[39m I22R (100 cases: person100, person101, person102, person103, person104, person105, person106, person107, person108, person109, person110, person111, person112, person113, person114, person115, person116, person117, person118, person119, person120, person121, person122, person123, person124, person125, person126, person127, person128, person129, person130, person131, person132, person133, person134, person135, person136, person137, person138, person139, person140, person141, person142, person143, person144, person145, person146, person147, person148, person149, person150, person151, person152, person153, person154, person155, person156, person157, person158, person159, person160, person161, person162, person163, person164, person165, person166, person167, person168, person169, person170, person171, person172, person173, person174, person175, person176, person177, person178, person179, person180, person181, person182, person183, person184, person185, person186, person187, person188, person189, person190, person191, person192, person193, person194, person195, person196, person197, person198, and person199)

---

    Code
      checkDesignTest(dat = within(userDefinedSysMis, I22R <- ifelse(is.na(I22R),
      "mbi", I22R)), sysMis = "NA")
    Message
      
      -- [1m[1mCheck:[1m[22m Subunit recoding 
      [36mi[39m Use names for recoded subunits.
      
      -- [1m[1mCheck:[1m[22m Variables in the dataset 
      [36mi[39m The following 1 variable is not in info (`subunit` in [32mblocks[39m) but in dataset.
      It will be ignored during check: `hisei`
      
      -- [1m[1mCheck:[1m[22m Valid and missing codes 
      [36mi[39m Deviations from design detected!
      [31mx[39m Found for 1 subunit valid codes instead of sysMis for booklet `booklet1`:
      I22R
      [36mi[39m I22R (100 cases: person100, person101, person102, person103, person104, person105, person106, person107, person108, person109, person110, person111, person112, person113, person114, person115, person116, person117, person118, person119, person120, person121, person122, person123, person124, person125, person126, person127, person128, person129, person130, person131, person132, person133, person134, person135, person136, person137, person138, person139, person140, person141, person142, person143, person144, person145, person146, person147, person148, person149, person150, person151, person152, person153, person154, person155, person156, person157, person158, person159, person160, person161, person162, person163, person164, person165, person166, person167, person168, person169, person170, person171, person172, person173, person174, person175, person176, person177, person178, person179, person180, person181, person182, person183, person184, person185, person186, person187, person188, person189, person190, person191, person192, person193, person194, person195, person196, person197, person198, and person199)

# identifies incorrect vc codes [unicode]

    Code
      checkDesignTest(dat = within(prepDat, I22R <- ifelse(I22R == "mbd", "mbi", I22R)),
      sysMis = "mbd")
    Message
      
      ── Check: Subunit recoding 
      ℹ Use names for recoded subunits.
      
      ── Check: Variables in the dataset 
      ℹ The following 1 variable is not in info (`subunit` in blocks) but in dataset.
      It will be ignored during check: `hisei`
      
      ── Check: Valid and missing codes 
      ℹ Deviations from design detected!
      ✖ Found for 1 subunit valid codes instead of sysMis for booklet `booklet1`:
      I22R
      ℹ I22R (100 cases: person100, person101, person102, person103, person104, person105, person106, person107, person108, person109, person110, person111, person112, person113, person114, person115, person116, person117, person118, person119, person120, person121, person122, person123, person124, person125, person126, person127, person128, person129, person130, person131, person132, person133, person134, person135, person136, person137, person138, person139, person140, person141, person142, person143, person144, person145, person146, person147, person148, person149, person150, person151, person152, person153, person154, person155, person156, person157, person158, person159, person160, person161, person162, person163, person164, person165, person166, person167, person168, person169, person170, person171, person172, person173, person174, person175, person176, person177, person178, person179, person180, person181, person182, person183, person184, person185, person186, person187, person188, person189, person190, person191, person192, person193, person194, person195, person196, person197, person198, and person199)

---

    Code
      checkDesignTest(dat = within(userDefinedSysMis, I22R <- ifelse(is.na(I22R),
      "mbi", I22R)), sysMis = "NA")
    Message
      
      ── Check: Subunit recoding 
      ℹ Use names for recoded subunits.
      
      ── Check: Variables in the dataset 
      ℹ The following 1 variable is not in info (`subunit` in blocks) but in dataset.
      It will be ignored during check: `hisei`
      
      ── Check: Valid and missing codes 
      ℹ Deviations from design detected!
      ✖ Found for 1 subunit valid codes instead of sysMis for booklet `booklet1`:
      I22R
      ℹ I22R (100 cases: person100, person101, person102, person103, person104, person105, person106, person107, person108, person109, person110, person111, person112, person113, person114, person115, person116, person117, person118, person119, person120, person121, person122, person123, person124, person125, person126, person127, person128, person129, person130, person131, person132, person133, person134, person135, person136, person137, person138, person139, person140, person141, person142, person143, person144, person145, person146, person147, person148, person149, person150, person151, person152, person153, person154, person155, person156, person157, person158, person159, person160, person161, person162, person163, person164, person165, person166, person167, person168, person169, person170, person171, person172, person173, person174, person175, person176, person177, person178, person179, person180, person181, person182, person183, person184, person185, person186, person187, person188, person189, person190, person191, person192, person193, person194, person195, person196, person197, person198, and person199)

# identifies incorrect vc codes [fancy]

    Code
      checkDesignTest(dat = within(prepDat, I22R <- ifelse(I22R == "mbd", "mbi", I22R)),
      sysMis = "mbd")
    Message
      
      ── [1m[1mCheck:[1m[22m Subunit recoding 
      [36mℹ[39m Use names for recoded subunits.
      
      ── [1m[1mCheck:[1m[22m Variables in the dataset 
      [36mℹ[39m The following 1 variable is not in info (`subunit` in [32mblocks[39m) but in dataset.
      It will be ignored during check: `hisei`
      
      ── [1m[1mCheck:[1m[22m Valid and missing codes 
      [36mℹ[39m Deviations from design detected!
      [31m✖[39m Found for 1 subunit valid codes instead of sysMis for booklet `booklet1`:
      I22R
      [36mℹ[39m I22R (100 cases: person100, person101, person102, person103, person104, person105, person106, person107, person108, person109, person110, person111, person112, person113, person114, person115, person116, person117, person118, person119, person120, person121, person122, person123, person124, person125, person126, person127, person128, person129, person130, person131, person132, person133, person134, person135, person136, person137, person138, person139, person140, person141, person142, person143, person144, person145, person146, person147, person148, person149, person150, person151, person152, person153, person154, person155, person156, person157, person158, person159, person160, person161, person162, person163, person164, person165, person166, person167, person168, person169, person170, person171, person172, person173, person174, person175, person176, person177, person178, person179, person180, person181, person182, person183, person184, person185, person186, person187, person188, person189, person190, person191, person192, person193, person194, person195, person196, person197, person198, and person199)

---

    Code
      checkDesignTest(dat = within(userDefinedSysMis, I22R <- ifelse(is.na(I22R),
      "mbi", I22R)), sysMis = "NA")
    Message
      
      ── [1m[1mCheck:[1m[22m Subunit recoding 
      [36mℹ[39m Use names for recoded subunits.
      
      ── [1m[1mCheck:[1m[22m Variables in the dataset 
      [36mℹ[39m The following 1 variable is not in info (`subunit` in [32mblocks[39m) but in dataset.
      It will be ignored during check: `hisei`
      
      ── [1m[1mCheck:[1m[22m Valid and missing codes 
      [36mℹ[39m Deviations from design detected!
      [31m✖[39m Found for 1 subunit valid codes instead of sysMis for booklet `booklet1`:
      I22R
      [36mℹ[39m I22R (100 cases: person100, person101, person102, person103, person104, person105, person106, person107, person108, person109, person110, person111, person112, person113, person114, person115, person116, person117, person118, person119, person120, person121, person122, person123, person124, person125, person126, person127, person128, person129, person130, person131, person132, person133, person134, person135, person136, person137, person138, person139, person140, person141, person142, person143, person144, person145, person146, person147, person148, person149, person150, person151, person152, person153, person154, person155, person156, person157, person158, person159, person160, person161, person162, person163, person164, person165, person166, person167, person168, person169, person170, person171, person172, person173, person174, person175, person176, person177, person178, person179, person180, person181, person182, person183, person184, person185, person186, person187, person188, person189, person190, person191, person192, person193, person194, person195, person196, person197, person198, and person199)

