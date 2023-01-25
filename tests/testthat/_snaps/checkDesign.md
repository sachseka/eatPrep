# returns nothing with no problems or only success messages on verbose mode [plain]

    Code
      checkDesignTest(verbose = FALSE)

---

    Code
      checkDesignTest(verbose = TRUE)
    Message <cliMessage>
      
      -- Check: Subunit recoding 
      i Use names for recoded subunits.
      
      -- Check: Variables in the dataset 
      i The following 1 variable is not in info (`subunit` in blocks) but in dataset.
      It will be ignored during check: `hisei`
      v No deviations from design detected!

# returns nothing with no problems or only success messages on verbose mode [ansi]

    Code
      checkDesignTest(verbose = FALSE)

---

    Code
      checkDesignTest(verbose = TRUE)
    Message <cliMessage>
      
      -- [1m[1mCheck:[1m[22m Subunit recoding 
      [36mi[39m Use names for recoded subunits.
      
      -- [1m[1mCheck:[1m[22m Variables in the dataset 
      [36mi[39m The following 1 variable is not in info (`subunit` in [32mblocks[39m) but in dataset.
      It will be ignored during check: `hisei`
      [32mv[39m No deviations from design detected!

# returns nothing with no problems or only success messages on verbose mode [unicode]

    Code
      checkDesignTest(verbose = FALSE)

---

    Code
      checkDesignTest(verbose = TRUE)
    Message <cliMessage>
      
      ── Check: Subunit recoding 
      ℹ Use names for recoded subunits.
      
      ── Check: Variables in the dataset 
      ℹ The following 1 variable is not in info (`subunit` in blocks) but in dataset.
      It will be ignored during check: `hisei`
      ✔ No deviations from design detected!

# returns nothing with no problems or only success messages on verbose mode [fancy]

    Code
      checkDesignTest(verbose = FALSE)

---

    Code
      checkDesignTest(verbose = TRUE)
    Message <cliMessage>
      
      ── [1m[1mCheck:[1m[22m Subunit recoding 
      [36mℹ[39m Use names for recoded subunits.
      
      ── [1m[1mCheck:[1m[22m Variables in the dataset 
      [36mℹ[39m The following 1 variable is not in info (`subunit` in [32mblocks[39m) but in dataset.
      It will be ignored during check: `hisei`
      [32m✔[39m No deviations from design detected!

# identifies ID variables that cannot be found in the dataset [plain]

    Code
      checkDesignTest(id = "FalseID")
    Error <rlang_error>
      ID variable `FalseID` not found in dataset.

# identifies ID variables that cannot be found in the dataset [ansi]

    Code
      checkDesignTest(id = "FalseID")
    Error <rlang_error>
      [1m[22mID variable `FalseID` not found in dataset.

# identifies ID variables that cannot be found in the dataset [unicode]

    Code
      checkDesignTest(id = "FalseID")
    Error <rlang_error>
      ID variable `FalseID` not found in dataset.

# identifies ID variables that cannot be found in the dataset [fancy]

    Code
      checkDesignTest(id = "FalseID")
    Error <rlang_error>
      [1m[22mID variable `FalseID` not found in dataset.

# throws danger messages when block names in blocks do not equal those in booklets [plain]

    Code
      checkDesignTest(blocks = test_block_block)
    Message <cliMessage>
      
      -- Check: Block names 
      x Block names set in blocks does not equal block names set in booklets. Please
      check.
      > The following 1 block is in booklets but not in blocks: `bl1`
      > The following 1 block is in blocks but not in booklets: `bl9`
      
      -- Check: Subunit recoding 
      i Use names for recoded subunits.
      
      -- Check: Variables in the dataset 
      i The following 1 variable is not in info (`subunit` in blocks) but in dataset.
      It will be ignored during check: `hisei`
      i Deviations from design detected!
      i Found for 7 variables
      valid codes instead of sysMis for booklet `booklet1`: 
      i I01R (100 cases: person100, person101, person102, person103, person104, person105, person106, person107, person108, person109, person110, person111, person112, person113, person114, person115, person116, person117, ..., person198, and person199)
      i I02R (100 cases: person100, person101, person102, person103, person104, person105, person106, person107, person108, person109, person110, person111, person112, person113, person114, person115, person116, person117, ..., person198, and person199)
      i I03R (100 cases: person100, person101, person102, person103, person104, person105, person106, person107, person108, person109, person110, person111, person112, person113, person114, person115, person116, person117, ..., person198, and person199)
      i I04R (100 cases: person100, person101, person102, person103, person104, person105, person106, person107, person108, person109, person110, person111, person112, person113, person114, person115, person116, person117, ..., person198, and person199)
      i I05R (100 cases: person100, person101, person102, person103, person104, person105, person106, person107, person108, person109, person110, person111, person112, person113, person114, person115, person116, person117, ..., person198, and person199)
      i I06R (100 cases: person100, person101, person102, person103, person104, person105, person106, person107, person108, person109, person110, person111, person112, person113, person114, person115, person116, person117, ..., person198, and person199)
      i I07R (100 cases: person100, person101, person102, person103, person104, person105, person106, person107, person108, person109, person110, person111, person112, person113, person114, person115, person116, person117, ..., person198, and person199)
      i Found for 7 variables
      valid codes instead of sysMis for booklet `booklet3`: 
      i I01R (100 cases: person300, person301, person302, person303, person304, person305, person306, person307, person308, person309, person310, person311, person312, person313, person314, person315, person316, person317, ..., person398, and person399)
      i I02R (100 cases: person300, person301, person302, person303, person304, person305, person306, person307, person308, person309, person310, person311, person312, person313, person314, person315, person316, person317, ..., person398, and person399)
      i I03R (100 cases: person300, person301, person302, person303, person304, person305, person306, person307, person308, person309, person310, person311, person312, person313, person314, person315, person316, person317, ..., person398, and person399)
      i I04R (100 cases: person300, person301, person302, person303, person304, person305, person306, person307, person308, person309, person310, person311, person312, person313, person314, person315, person316, person317, ..., person398, and person399)
      i I05R (100 cases: person300, person301, person302, person303, person304, person305, person306, person307, person308, person309, person310, person311, person312, person313, person314, person315, person316, person317, ..., person398, and person399)
      i I06R (100 cases: person300, person301, person302, person303, person304, person305, person306, person307, person308, person309, person310, person311, person312, person313, person314, person315, person316, person317, ..., person398, and person399)
      i I07R (100 cases: person300, person301, person302, person303, person304, person305, person306, person307, person308, person309, person310, person311, person312, person313, person314, person315, person316, person317, ..., person398, and person399)

---

    Code
      checkDesignTest(booklets = test_booklet_block)
    Message <cliMessage>
      
      -- Check: Block names 
      x Block names set in blocks does not equal block names set in booklets. Please
      check.
      > The following 1 block is in booklets but not in blocks: `bl8`
      
      -- Check: Subunit recoding 
      i Use names for recoded subunits.
      
      -- Check: Variables in the dataset 
      i The following 1 variable is not in info (`subunit` in blocks) but in dataset.
      It will be ignored during check: `hisei`
      i Deviations from design detected!
      i Found for 7 variables
      valid codes instead of sysMis for booklet `booklet1`: 
      i I01R (100 cases: person100, person101, person102, person103, person104, person105, person106, person107, person108, person109, person110, person111, person112, person113, person114, person115, person116, person117, ..., person198, and person199)
      i I02R (100 cases: person100, person101, person102, person103, person104, person105, person106, person107, person108, person109, person110, person111, person112, person113, person114, person115, person116, person117, ..., person198, and person199)
      i I03R (100 cases: person100, person101, person102, person103, person104, person105, person106, person107, person108, person109, person110, person111, person112, person113, person114, person115, person116, person117, ..., person198, and person199)
      i I04R (100 cases: person100, person101, person102, person103, person104, person105, person106, person107, person108, person109, person110, person111, person112, person113, person114, person115, person116, person117, ..., person198, and person199)
      i I05R (100 cases: person100, person101, person102, person103, person104, person105, person106, person107, person108, person109, person110, person111, person112, person113, person114, person115, person116, person117, ..., person198, and person199)
      i I06R (100 cases: person100, person101, person102, person103, person104, person105, person106, person107, person108, person109, person110, person111, person112, person113, person114, person115, person116, person117, ..., person198, and person199)
      i I07R (100 cases: person100, person101, person102, person103, person104, person105, person106, person107, person108, person109, person110, person111, person112, person113, person114, person115, person116, person117, ..., person198, and person199)

# throws danger messages when block names in blocks do not equal those in booklets [ansi]

    Code
      checkDesignTest(blocks = test_block_block)
    Message <cliMessage>
      
      -- [1m[1mCheck:[1m[22m Block names 
      [31mx[39m Block names set in [32mblocks[39m does not equal block names set in [32mbooklets[39m. Please
      check.
      > The following 1 block is in [32mbooklets[39m but not in [32mblocks[39m: `bl1`
      > The following 1 block is in [32mblocks[39m but not in [32mbooklets[39m: `bl9`
      
      -- [1m[1mCheck:[1m[22m Subunit recoding 
      [36mi[39m Use names for recoded subunits.
      
      -- [1m[1mCheck:[1m[22m Variables in the dataset 
      [36mi[39m The following 1 variable is not in info (`subunit` in [32mblocks[39m) but in dataset.
      It will be ignored during check: `hisei`
      [36mi[39m Deviations from design detected!
      [36mi[39m Found for 7 variables
      valid codes instead of sysMis for booklet `booklet1`: 
      [36mi[39m I01R (100 cases: person100, person101, person102, person103, person104, person105, person106, person107, person108, person109, person110, person111, person112, person113, person114, person115, person116, person117, ..., person198, and person199)
      [36mi[39m I02R (100 cases: person100, person101, person102, person103, person104, person105, person106, person107, person108, person109, person110, person111, person112, person113, person114, person115, person116, person117, ..., person198, and person199)
      [36mi[39m I03R (100 cases: person100, person101, person102, person103, person104, person105, person106, person107, person108, person109, person110, person111, person112, person113, person114, person115, person116, person117, ..., person198, and person199)
      [36mi[39m I04R (100 cases: person100, person101, person102, person103, person104, person105, person106, person107, person108, person109, person110, person111, person112, person113, person114, person115, person116, person117, ..., person198, and person199)
      [36mi[39m I05R (100 cases: person100, person101, person102, person103, person104, person105, person106, person107, person108, person109, person110, person111, person112, person113, person114, person115, person116, person117, ..., person198, and person199)
      [36mi[39m I06R (100 cases: person100, person101, person102, person103, person104, person105, person106, person107, person108, person109, person110, person111, person112, person113, person114, person115, person116, person117, ..., person198, and person199)
      [36mi[39m I07R (100 cases: person100, person101, person102, person103, person104, person105, person106, person107, person108, person109, person110, person111, person112, person113, person114, person115, person116, person117, ..., person198, and person199)
      [36mi[39m Found for 7 variables
      valid codes instead of sysMis for booklet `booklet3`: 
      [36mi[39m I01R (100 cases: person300, person301, person302, person303, person304, person305, person306, person307, person308, person309, person310, person311, person312, person313, person314, person315, person316, person317, ..., person398, and person399)
      [36mi[39m I02R (100 cases: person300, person301, person302, person303, person304, person305, person306, person307, person308, person309, person310, person311, person312, person313, person314, person315, person316, person317, ..., person398, and person399)
      [36mi[39m I03R (100 cases: person300, person301, person302, person303, person304, person305, person306, person307, person308, person309, person310, person311, person312, person313, person314, person315, person316, person317, ..., person398, and person399)
      [36mi[39m I04R (100 cases: person300, person301, person302, person303, person304, person305, person306, person307, person308, person309, person310, person311, person312, person313, person314, person315, person316, person317, ..., person398, and person399)
      [36mi[39m I05R (100 cases: person300, person301, person302, person303, person304, person305, person306, person307, person308, person309, person310, person311, person312, person313, person314, person315, person316, person317, ..., person398, and person399)
      [36mi[39m I06R (100 cases: person300, person301, person302, person303, person304, person305, person306, person307, person308, person309, person310, person311, person312, person313, person314, person315, person316, person317, ..., person398, and person399)
      [36mi[39m I07R (100 cases: person300, person301, person302, person303, person304, person305, person306, person307, person308, person309, person310, person311, person312, person313, person314, person315, person316, person317, ..., person398, and person399)

---

    Code
      checkDesignTest(booklets = test_booklet_block)
    Message <cliMessage>
      
      -- [1m[1mCheck:[1m[22m Block names 
      [31mx[39m Block names set in [32mblocks[39m does not equal block names set in [32mbooklets[39m. Please
      check.
      > The following 1 block is in [32mbooklets[39m but not in [32mblocks[39m: `bl8`
      
      -- [1m[1mCheck:[1m[22m Subunit recoding 
      [36mi[39m Use names for recoded subunits.
      
      -- [1m[1mCheck:[1m[22m Variables in the dataset 
      [36mi[39m The following 1 variable is not in info (`subunit` in [32mblocks[39m) but in dataset.
      It will be ignored during check: `hisei`
      [36mi[39m Deviations from design detected!
      [36mi[39m Found for 7 variables
      valid codes instead of sysMis for booklet `booklet1`: 
      [36mi[39m I01R (100 cases: person100, person101, person102, person103, person104, person105, person106, person107, person108, person109, person110, person111, person112, person113, person114, person115, person116, person117, ..., person198, and person199)
      [36mi[39m I02R (100 cases: person100, person101, person102, person103, person104, person105, person106, person107, person108, person109, person110, person111, person112, person113, person114, person115, person116, person117, ..., person198, and person199)
      [36mi[39m I03R (100 cases: person100, person101, person102, person103, person104, person105, person106, person107, person108, person109, person110, person111, person112, person113, person114, person115, person116, person117, ..., person198, and person199)
      [36mi[39m I04R (100 cases: person100, person101, person102, person103, person104, person105, person106, person107, person108, person109, person110, person111, person112, person113, person114, person115, person116, person117, ..., person198, and person199)
      [36mi[39m I05R (100 cases: person100, person101, person102, person103, person104, person105, person106, person107, person108, person109, person110, person111, person112, person113, person114, person115, person116, person117, ..., person198, and person199)
      [36mi[39m I06R (100 cases: person100, person101, person102, person103, person104, person105, person106, person107, person108, person109, person110, person111, person112, person113, person114, person115, person116, person117, ..., person198, and person199)
      [36mi[39m I07R (100 cases: person100, person101, person102, person103, person104, person105, person106, person107, person108, person109, person110, person111, person112, person113, person114, person115, person116, person117, ..., person198, and person199)

# throws danger messages when block names in blocks do not equal those in booklets [unicode]

    Code
      checkDesignTest(blocks = test_block_block)
    Message <cliMessage>
      
      ── Check: Block names 
      ✖ Block names set in blocks does not equal block names set in booklets. Please
      check.
      → The following 1 block is in booklets but not in blocks: `bl1`
      → The following 1 block is in blocks but not in booklets: `bl9`
      
      ── Check: Subunit recoding 
      ℹ Use names for recoded subunits.
      
      ── Check: Variables in the dataset 
      ℹ The following 1 variable is not in info (`subunit` in blocks) but in dataset.
      It will be ignored during check: `hisei`
      ℹ Deviations from design detected!
      ℹ Found for 7 variables
      valid codes instead of sysMis for booklet `booklet1`: 
      ℹ I01R (100 cases: person100, person101, person102, person103, person104, person105, person106, person107, person108, person109, person110, person111, person112, person113, person114, person115, person116, person117, …, person198, and person199)
      ℹ I02R (100 cases: person100, person101, person102, person103, person104, person105, person106, person107, person108, person109, person110, person111, person112, person113, person114, person115, person116, person117, …, person198, and person199)
      ℹ I03R (100 cases: person100, person101, person102, person103, person104, person105, person106, person107, person108, person109, person110, person111, person112, person113, person114, person115, person116, person117, …, person198, and person199)
      ℹ I04R (100 cases: person100, person101, person102, person103, person104, person105, person106, person107, person108, person109, person110, person111, person112, person113, person114, person115, person116, person117, …, person198, and person199)
      ℹ I05R (100 cases: person100, person101, person102, person103, person104, person105, person106, person107, person108, person109, person110, person111, person112, person113, person114, person115, person116, person117, …, person198, and person199)
      ℹ I06R (100 cases: person100, person101, person102, person103, person104, person105, person106, person107, person108, person109, person110, person111, person112, person113, person114, person115, person116, person117, …, person198, and person199)
      ℹ I07R (100 cases: person100, person101, person102, person103, person104, person105, person106, person107, person108, person109, person110, person111, person112, person113, person114, person115, person116, person117, …, person198, and person199)
      ℹ Found for 7 variables
      valid codes instead of sysMis for booklet `booklet3`: 
      ℹ I01R (100 cases: person300, person301, person302, person303, person304, person305, person306, person307, person308, person309, person310, person311, person312, person313, person314, person315, person316, person317, …, person398, and person399)
      ℹ I02R (100 cases: person300, person301, person302, person303, person304, person305, person306, person307, person308, person309, person310, person311, person312, person313, person314, person315, person316, person317, …, person398, and person399)
      ℹ I03R (100 cases: person300, person301, person302, person303, person304, person305, person306, person307, person308, person309, person310, person311, person312, person313, person314, person315, person316, person317, …, person398, and person399)
      ℹ I04R (100 cases: person300, person301, person302, person303, person304, person305, person306, person307, person308, person309, person310, person311, person312, person313, person314, person315, person316, person317, …, person398, and person399)
      ℹ I05R (100 cases: person300, person301, person302, person303, person304, person305, person306, person307, person308, person309, person310, person311, person312, person313, person314, person315, person316, person317, …, person398, and person399)
      ℹ I06R (100 cases: person300, person301, person302, person303, person304, person305, person306, person307, person308, person309, person310, person311, person312, person313, person314, person315, person316, person317, …, person398, and person399)
      ℹ I07R (100 cases: person300, person301, person302, person303, person304, person305, person306, person307, person308, person309, person310, person311, person312, person313, person314, person315, person316, person317, …, person398, and person399)

---

    Code
      checkDesignTest(booklets = test_booklet_block)
    Message <cliMessage>
      
      ── Check: Block names 
      ✖ Block names set in blocks does not equal block names set in booklets. Please
      check.
      → The following 1 block is in booklets but not in blocks: `bl8`
      
      ── Check: Subunit recoding 
      ℹ Use names for recoded subunits.
      
      ── Check: Variables in the dataset 
      ℹ The following 1 variable is not in info (`subunit` in blocks) but in dataset.
      It will be ignored during check: `hisei`
      ℹ Deviations from design detected!
      ℹ Found for 7 variables
      valid codes instead of sysMis for booklet `booklet1`: 
      ℹ I01R (100 cases: person100, person101, person102, person103, person104, person105, person106, person107, person108, person109, person110, person111, person112, person113, person114, person115, person116, person117, …, person198, and person199)
      ℹ I02R (100 cases: person100, person101, person102, person103, person104, person105, person106, person107, person108, person109, person110, person111, person112, person113, person114, person115, person116, person117, …, person198, and person199)
      ℹ I03R (100 cases: person100, person101, person102, person103, person104, person105, person106, person107, person108, person109, person110, person111, person112, person113, person114, person115, person116, person117, …, person198, and person199)
      ℹ I04R (100 cases: person100, person101, person102, person103, person104, person105, person106, person107, person108, person109, person110, person111, person112, person113, person114, person115, person116, person117, …, person198, and person199)
      ℹ I05R (100 cases: person100, person101, person102, person103, person104, person105, person106, person107, person108, person109, person110, person111, person112, person113, person114, person115, person116, person117, …, person198, and person199)
      ℹ I06R (100 cases: person100, person101, person102, person103, person104, person105, person106, person107, person108, person109, person110, person111, person112, person113, person114, person115, person116, person117, …, person198, and person199)
      ℹ I07R (100 cases: person100, person101, person102, person103, person104, person105, person106, person107, person108, person109, person110, person111, person112, person113, person114, person115, person116, person117, …, person198, and person199)

# throws danger messages when block names in blocks do not equal those in booklets [fancy]

    Code
      checkDesignTest(blocks = test_block_block)
    Message <cliMessage>
      
      ── [1m[1mCheck:[1m[22m Block names 
      [31m✖[39m Block names set in [32mblocks[39m does not equal block names set in [32mbooklets[39m. Please
      check.
      → The following 1 block is in [32mbooklets[39m but not in [32mblocks[39m: `bl1`
      → The following 1 block is in [32mblocks[39m but not in [32mbooklets[39m: `bl9`
      
      ── [1m[1mCheck:[1m[22m Subunit recoding 
      [36mℹ[39m Use names for recoded subunits.
      
      ── [1m[1mCheck:[1m[22m Variables in the dataset 
      [36mℹ[39m The following 1 variable is not in info (`subunit` in [32mblocks[39m) but in dataset.
      It will be ignored during check: `hisei`
      [36mℹ[39m Deviations from design detected!
      [36mℹ[39m Found for 7 variables
      valid codes instead of sysMis for booklet `booklet1`: 
      [36mℹ[39m I01R (100 cases: person100, person101, person102, person103, person104, person105, person106, person107, person108, person109, person110, person111, person112, person113, person114, person115, person116, person117, …, person198, and person199)
      [36mℹ[39m I02R (100 cases: person100, person101, person102, person103, person104, person105, person106, person107, person108, person109, person110, person111, person112, person113, person114, person115, person116, person117, …, person198, and person199)
      [36mℹ[39m I03R (100 cases: person100, person101, person102, person103, person104, person105, person106, person107, person108, person109, person110, person111, person112, person113, person114, person115, person116, person117, …, person198, and person199)
      [36mℹ[39m I04R (100 cases: person100, person101, person102, person103, person104, person105, person106, person107, person108, person109, person110, person111, person112, person113, person114, person115, person116, person117, …, person198, and person199)
      [36mℹ[39m I05R (100 cases: person100, person101, person102, person103, person104, person105, person106, person107, person108, person109, person110, person111, person112, person113, person114, person115, person116, person117, …, person198, and person199)
      [36mℹ[39m I06R (100 cases: person100, person101, person102, person103, person104, person105, person106, person107, person108, person109, person110, person111, person112, person113, person114, person115, person116, person117, …, person198, and person199)
      [36mℹ[39m I07R (100 cases: person100, person101, person102, person103, person104, person105, person106, person107, person108, person109, person110, person111, person112, person113, person114, person115, person116, person117, …, person198, and person199)
      [36mℹ[39m Found for 7 variables
      valid codes instead of sysMis for booklet `booklet3`: 
      [36mℹ[39m I01R (100 cases: person300, person301, person302, person303, person304, person305, person306, person307, person308, person309, person310, person311, person312, person313, person314, person315, person316, person317, …, person398, and person399)
      [36mℹ[39m I02R (100 cases: person300, person301, person302, person303, person304, person305, person306, person307, person308, person309, person310, person311, person312, person313, person314, person315, person316, person317, …, person398, and person399)
      [36mℹ[39m I03R (100 cases: person300, person301, person302, person303, person304, person305, person306, person307, person308, person309, person310, person311, person312, person313, person314, person315, person316, person317, …, person398, and person399)
      [36mℹ[39m I04R (100 cases: person300, person301, person302, person303, person304, person305, person306, person307, person308, person309, person310, person311, person312, person313, person314, person315, person316, person317, …, person398, and person399)
      [36mℹ[39m I05R (100 cases: person300, person301, person302, person303, person304, person305, person306, person307, person308, person309, person310, person311, person312, person313, person314, person315, person316, person317, …, person398, and person399)
      [36mℹ[39m I06R (100 cases: person300, person301, person302, person303, person304, person305, person306, person307, person308, person309, person310, person311, person312, person313, person314, person315, person316, person317, …, person398, and person399)
      [36mℹ[39m I07R (100 cases: person300, person301, person302, person303, person304, person305, person306, person307, person308, person309, person310, person311, person312, person313, person314, person315, person316, person317, …, person398, and person399)

---

    Code
      checkDesignTest(booklets = test_booklet_block)
    Message <cliMessage>
      
      ── [1m[1mCheck:[1m[22m Block names 
      [31m✖[39m Block names set in [32mblocks[39m does not equal block names set in [32mbooklets[39m. Please
      check.
      → The following 1 block is in [32mbooklets[39m but not in [32mblocks[39m: `bl8`
      
      ── [1m[1mCheck:[1m[22m Subunit recoding 
      [36mℹ[39m Use names for recoded subunits.
      
      ── [1m[1mCheck:[1m[22m Variables in the dataset 
      [36mℹ[39m The following 1 variable is not in info (`subunit` in [32mblocks[39m) but in dataset.
      It will be ignored during check: `hisei`
      [36mℹ[39m Deviations from design detected!
      [36mℹ[39m Found for 7 variables
      valid codes instead of sysMis for booklet `booklet1`: 
      [36mℹ[39m I01R (100 cases: person100, person101, person102, person103, person104, person105, person106, person107, person108, person109, person110, person111, person112, person113, person114, person115, person116, person117, …, person198, and person199)
      [36mℹ[39m I02R (100 cases: person100, person101, person102, person103, person104, person105, person106, person107, person108, person109, person110, person111, person112, person113, person114, person115, person116, person117, …, person198, and person199)
      [36mℹ[39m I03R (100 cases: person100, person101, person102, person103, person104, person105, person106, person107, person108, person109, person110, person111, person112, person113, person114, person115, person116, person117, …, person198, and person199)
      [36mℹ[39m I04R (100 cases: person100, person101, person102, person103, person104, person105, person106, person107, person108, person109, person110, person111, person112, person113, person114, person115, person116, person117, …, person198, and person199)
      [36mℹ[39m I05R (100 cases: person100, person101, person102, person103, person104, person105, person106, person107, person108, person109, person110, person111, person112, person113, person114, person115, person116, person117, …, person198, and person199)
      [36mℹ[39m I06R (100 cases: person100, person101, person102, person103, person104, person105, person106, person107, person108, person109, person110, person111, person112, person113, person114, person115, person116, person117, …, person198, and person199)
      [36mℹ[39m I07R (100 cases: person100, person101, person102, person103, person104, person105, person106, person107, person108, person109, person110, person111, person112, person113, person114, person115, person116, person117, …, person198, and person199)

# throws danger messages when booklet names in booklets do not equal those in rotation [plain]

    Code
      checkDesignTest(booklets = test_booklet_booklet)
    Message <cliMessage>
      
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
      v No deviations from design detected!

---

    Code
      checkDesignTest(rotation = test_rotation_booklet)
    Message <cliMessage>
      
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
      v No deviations from design detected!

# throws danger messages when booklet names in booklets do not equal those in rotation [ansi]

    Code
      checkDesignTest(booklets = test_booklet_booklet)
    Message <cliMessage>
      
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
      [32mv[39m No deviations from design detected!

---

    Code
      checkDesignTest(rotation = test_rotation_booklet)
    Message <cliMessage>
      
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
      [32mv[39m No deviations from design detected!

# throws danger messages when booklet names in booklets do not equal those in rotation [unicode]

    Code
      checkDesignTest(booklets = test_booklet_booklet)
    Message <cliMessage>
      
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
      ✔ No deviations from design detected!

---

    Code
      checkDesignTest(rotation = test_rotation_booklet)
    Message <cliMessage>
      
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
      ✔ No deviations from design detected!

# throws danger messages when booklet names in booklets do not equal those in rotation [fancy]

    Code
      checkDesignTest(booklets = test_booklet_booklet)
    Message <cliMessage>
      
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
      [32m✔[39m No deviations from design detected!

---

    Code
      checkDesignTest(rotation = test_rotation_booklet)
    Message <cliMessage>
      
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
      [32m✔[39m No deviations from design detected!

# throws warning when more variables in dataset available than in blocks$subunit [plain]

    Code
      checkDesignTest(dat = within(prepDat, hisei <- NULL))
    Message <cliMessage>
      
      -- Check: Subunit recoding 
      i Use names for recoded subunits.
      v No deviations from design detected!

---

    Code
      checkDesignTest(dat = within(prepDat, {
        hisei <- NULL
        testB <- 2
        testA <- 1
      }))
    Message <cliMessage>
      
      -- Check: Subunit recoding 
      i Use names for recoded subunits.
      
      -- Check: Variables in the dataset 
      i The following 2 variables are not in info (`subunit` in blocks) but in
      dataset. They will be ignored during check: `testA` and `testB`
      v No deviations from design detected!

# throws warning when more variables in dataset available than in blocks$subunit [ansi]

    Code
      checkDesignTest(dat = within(prepDat, hisei <- NULL))
    Message <cliMessage>
      
      -- [1m[1mCheck:[1m[22m Subunit recoding 
      [36mi[39m Use names for recoded subunits.
      [32mv[39m No deviations from design detected!

---

    Code
      checkDesignTest(dat = within(prepDat, {
        hisei <- NULL
        testB <- 2
        testA <- 1
      }))
    Message <cliMessage>
      
      -- [1m[1mCheck:[1m[22m Subunit recoding 
      [36mi[39m Use names for recoded subunits.
      
      -- [1m[1mCheck:[1m[22m Variables in the dataset 
      [36mi[39m The following 2 variables are not in info (`subunit` in [32mblocks[39m) but in
      dataset. They will be ignored during check: `testA` and `testB`
      [32mv[39m No deviations from design detected!

# throws warning when more variables in dataset available than in blocks$subunit [unicode]

    Code
      checkDesignTest(dat = within(prepDat, hisei <- NULL))
    Message <cliMessage>
      
      ── Check: Subunit recoding 
      ℹ Use names for recoded subunits.
      ✔ No deviations from design detected!

---

    Code
      checkDesignTest(dat = within(prepDat, {
        hisei <- NULL
        testB <- 2
        testA <- 1
      }))
    Message <cliMessage>
      
      ── Check: Subunit recoding 
      ℹ Use names for recoded subunits.
      
      ── Check: Variables in the dataset 
      ℹ The following 2 variables are not in info (`subunit` in blocks) but in
      dataset. They will be ignored during check: `testA` and `testB`
      ✔ No deviations from design detected!

# throws warning when more variables in dataset available than in blocks$subunit [fancy]

    Code
      checkDesignTest(dat = within(prepDat, hisei <- NULL))
    Message <cliMessage>
      
      ── [1m[1mCheck:[1m[22m Subunit recoding 
      [36mℹ[39m Use names for recoded subunits.
      [32m✔[39m No deviations from design detected!

---

    Code
      checkDesignTest(dat = within(prepDat, {
        hisei <- NULL
        testB <- 2
        testA <- 1
      }))
    Message <cliMessage>
      
      ── [1m[1mCheck:[1m[22m Subunit recoding 
      [36mℹ[39m Use names for recoded subunits.
      
      ── [1m[1mCheck:[1m[22m Variables in the dataset 
      [36mℹ[39m The following 2 variables are not in info (`subunit` in [32mblocks[39m) but in
      dataset. They will be ignored during check: `testA` and `testB`
      [32m✔[39m No deviations from design detected!

# identifies sysMis or vc [plain]

    Code
      checkDesignTest(dat = within(prepDat, I01R <- ifelse(I01R == 0, NA, I01R)))
    Message <cliMessage>
      
      -- Check: Subunit recoding 
      i Use names for recoded subunits.
      
      -- Check: Variables in the dataset 
      i The following 1 variable is not in info (`subunit` in blocks) but in dataset.
      It will be ignored during check: `hisei`
      v No deviations from design detected!

# identifies sysMis or vc [ansi]

    Code
      checkDesignTest(dat = within(prepDat, I01R <- ifelse(I01R == 0, NA, I01R)))
    Message <cliMessage>
      
      -- [1m[1mCheck:[1m[22m Subunit recoding 
      [36mi[39m Use names for recoded subunits.
      
      -- [1m[1mCheck:[1m[22m Variables in the dataset 
      [36mi[39m The following 1 variable is not in info (`subunit` in [32mblocks[39m) but in dataset.
      It will be ignored during check: `hisei`
      [32mv[39m No deviations from design detected!

# identifies sysMis or vc [unicode]

    Code
      checkDesignTest(dat = within(prepDat, I01R <- ifelse(I01R == 0, NA, I01R)))
    Message <cliMessage>
      
      ── Check: Subunit recoding 
      ℹ Use names for recoded subunits.
      
      ── Check: Variables in the dataset 
      ℹ The following 1 variable is not in info (`subunit` in blocks) but in dataset.
      It will be ignored during check: `hisei`
      ✔ No deviations from design detected!

# identifies sysMis or vc [fancy]

    Code
      checkDesignTest(dat = within(prepDat, I01R <- ifelse(I01R == 0, NA, I01R)))
    Message <cliMessage>
      
      ── [1m[1mCheck:[1m[22m Subunit recoding 
      [36mℹ[39m Use names for recoded subunits.
      
      ── [1m[1mCheck:[1m[22m Variables in the dataset 
      [36mℹ[39m The following 1 variable is not in info (`subunit` in [32mblocks[39m) but in dataset.
      It will be ignored during check: `hisei`
      [32m✔[39m No deviations from design detected!

