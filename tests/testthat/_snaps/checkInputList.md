# returns default messages and TRUE when everything is okay [plain]

    Code
      checkInputList(prepList)
    Message
      
      -- Check: Value Recoding 
      v Missing types `mnr`, `mbd`, `mir`, and `mbi` are defined for all items in
      valueRecode.
      i value contains the following values over all items: `0`, `1`, `2`, `3`, `4`,
      `6`, `7`, `8`, and `9`
      v valueRecode contains only 0, 1, and the mistypes: `0`, `1`, `mbd`, `mbi`,
      `mir`, and `mnr`
      
      -- Check: Value Types 
      v No other values than `vc` and the mistypes in valueType.
      
      -- Check: Unit Equivalence 
      v All 4 units in units sheet are also defined in subunits.
      
      -- Check: Subunit Equivalence 
      v All 6 subunits in subunits sheet are also defined in values.
      
      -- Check: Unit Recoding 
      i Units with only one subunit: 3
      i Units with more than one subunit: 1 (`I03`)
      v All units with more than one subunit are defined in unitRecodings sheet.
    Output
      [1] TRUE

# returns default messages and TRUE when everything is okay [ansi]

    Code
      checkInputList(prepList)
    Message
      
      -- Check: Value Recoding 
      [32mv[39m Missing types `mnr`, `mbd`, `mir`, and `mbi` are defined for all items in
      [32mvalueRecode[39m.
      [36mi[39m [32mvalue[39m contains the following values over all items: `0`, `1`, `2`, `3`, `4`,
      `6`, `7`, `8`, and `9`
      [32mv[39m [32mvalueRecode[39m contains only 0, 1, and the mistypes: `0`, `1`, `mbd`, `mbi`,
      `mir`, and `mnr`
      
      -- Check: Value Types 
      [32mv[39m No other values than `vc` and the mistypes in [32mvalueType[39m.
      
      -- Check: Unit Equivalence 
      [32mv[39m All 4 units in [32munits[39m sheet are also defined in [32msubunits[39m.
      
      -- Check: Subunit Equivalence 
      [32mv[39m All 6 subunits in [32msubunits[39m sheet are also defined in [32mvalues[39m.
      
      -- Check: Unit Recoding 
      [36mi[39m Units with only one subunit: 3
      [36mi[39m Units with more than one subunit: 1 (`I03`)
      [32mv[39m All units with more than one subunit are defined in [32munitRecodings[39m sheet.
    Output
      [1] TRUE

# returns default messages and TRUE when everything is okay [unicode]

    Code
      checkInputList(prepList)
    Message
      
      ── Check: Value Recoding 
      ✔ Missing types `mnr`, `mbd`, `mir`, and `mbi` are defined for all items in
      valueRecode.
      ℹ value contains the following values over all items: `0`, `1`, `2`, `3`, `4`,
      `6`, `7`, `8`, and `9`
      ✔ valueRecode contains only 0, 1, and the mistypes: `0`, `1`, `mbd`, `mbi`,
      `mir`, and `mnr`
      
      ── Check: Value Types 
      ✔ No other values than `vc` and the mistypes in valueType.
      
      ── Check: Unit Equivalence 
      ✔ All 4 units in units sheet are also defined in subunits.
      
      ── Check: Subunit Equivalence 
      ✔ All 6 subunits in subunits sheet are also defined in values.
      
      ── Check: Unit Recoding 
      ℹ Units with only one subunit: 3
      ℹ Units with more than one subunit: 1 (`I03`)
      ✔ All units with more than one subunit are defined in unitRecodings sheet.
    Output
      [1] TRUE

# returns default messages and TRUE when everything is okay [fancy]

    Code
      checkInputList(prepList)
    Message
      
      ── Check: Value Recoding 
      [32m✔[39m Missing types `mnr`, `mbd`, `mir`, and `mbi` are defined for all items in
      [32mvalueRecode[39m.
      [36mℹ[39m [32mvalue[39m contains the following values over all items: `0`, `1`, `2`, `3`, `4`,
      `6`, `7`, `8`, and `9`
      [32m✔[39m [32mvalueRecode[39m contains only 0, 1, and the mistypes: `0`, `1`, `mbd`, `mbi`,
      `mir`, and `mnr`
      
      ── Check: Value Types 
      [32m✔[39m No other values than `vc` and the mistypes in [32mvalueType[39m.
      
      ── Check: Unit Equivalence 
      [32m✔[39m All 4 units in [32munits[39m sheet are also defined in [32msubunits[39m.
      
      ── Check: Subunit Equivalence 
      [32m✔[39m All 6 subunits in [32msubunits[39m sheet are also defined in [32mvalues[39m.
      
      ── Check: Unit Recoding 
      [36mℹ[39m Units with only one subunit: 3
      [36mℹ[39m Units with more than one subunit: 1 (`I03`)
      [32m✔[39m All units with more than one subunit are defined in [32munitRecodings[39m sheet.
    Output
      [1] TRUE

# identifies and flags missing sheets with consequences for checks [plain]

    Code
      checkInputList(prepList)
    Message
      
      -- Checking sheets 
      x Did not find 1 sheet: `units`
      > No checks for unit equivalence available.
      
      -- Check: Value Recoding 
      v Missing types `mnr`, `mbd`, `mir`, and `mbi` are defined for all items in
      valueRecode.
      i value contains the following values over all items: `0`, `1`, `2`, `3`, `4`,
      `6`, `7`, `8`, and `9`
      v valueRecode contains only 0, 1, and the mistypes: `0`, `1`, `mbd`, `mbi`,
      `mir`, and `mnr`
      
      -- Check: Value Types 
      v No other values than `vc` and the mistypes in valueType.
      
      -- Check: Subunit Equivalence 
      v All 6 subunits in subunits sheet are also defined in values.
      
      -- Check: Unit Recoding 
      i Units with only one subunit: 3
      i Units with more than one subunit: 1 (`I03`)
      v All units with more than one subunit are defined in unitRecodings sheet.
    Output
      [1] FALSE

---

    Code
      checkInputList(prepList)
    Message
      
      -- Checking sheets 
      x Did not find 1 sheet: `subunits`
      > No checks for unit equivalence and subunit equivalence available.
      
      -- Check: Value Recoding 
      v Missing types `mnr`, `mbd`, `mir`, and `mbi` are defined for all items in
      valueRecode.
      i value contains the following values over all items: `0`, `1`, `2`, `3`, `4`,
      `6`, `7`, `8`, and `9`
      v valueRecode contains only 0, 1, and the mistypes: `0`, `1`, `mbd`, `mbi`,
      `mir`, and `mnr`
      
      -- Check: Value Types 
      v No other values than `vc` and the mistypes in valueType.
    Output
      [1] FALSE

---

    Code
      checkInputList(prepList)
    Message
      
      -- Checking sheets 
      x Did not find 1 sheet: `values`
      > No checks for subunit equivalence, value recoding, and value types available.
      
      -- Check: Unit Equivalence 
      v All 4 units in units sheet are also defined in subunits.
    Output
      [1] FALSE

---

    Code
      checkInputList(prepList)
    Message
      
      -- Checking sheets 
      x Did not find 1 sheet: `unitRecodings`
      > No checks for unit recoding available.
      
      -- Check: Value Recoding 
      v Missing types `mnr`, `mbd`, `mir`, and `mbi` are defined for all items in
      valueRecode.
      i value contains the following values over all items: `0`, `1`, `2`, `3`, `4`,
      `6`, `7`, `8`, and `9`
      v valueRecode contains only 0, 1, and the mistypes: `0`, `1`, `mbd`, `mbi`,
      `mir`, and `mnr`
      
      -- Check: Value Types 
      v No other values than `vc` and the mistypes in valueType.
      
      -- Check: Unit Equivalence 
      v All 4 units in units sheet are also defined in subunits.
      
      -- Check: Subunit Equivalence 
      v All 6 subunits in subunits sheet are also defined in values.
      
      -- Check: Unit Recoding 
      i Units with only one subunit: 3
      i Units with more than one subunit: 1 (`I03`)
      x Not all units with more than one subunit are defined in unitRecodings sheet:
      `I03`
    Output
      [1] FALSE

---

    Code
      checkInputList(prepList)
    Message
      
      -- Checking sheets 
      x Did not find 1 sheet: `savFiles`
      
      -- Check: Value Recoding 
      v Missing types `mnr`, `mbd`, `mir`, and `mbi` are defined for all items in
      valueRecode.
      i value contains the following values over all items: `0`, `1`, `2`, `3`, `4`,
      `6`, `7`, `8`, and `9`
      v valueRecode contains only 0, 1, and the mistypes: `0`, `1`, `mbd`, `mbi`,
      `mir`, and `mnr`
      
      -- Check: Value Types 
      v No other values than `vc` and the mistypes in valueType.
      
      -- Check: Unit Equivalence 
      v All 4 units in units sheet are also defined in subunits.
      
      -- Check: Subunit Equivalence 
      v All 6 subunits in subunits sheet are also defined in values.
      
      -- Check: Unit Recoding 
      i Units with only one subunit: 3
      i Units with more than one subunit: 1 (`I03`)
      v All units with more than one subunit are defined in unitRecodings sheet.
    Output
      [1] FALSE

---

    Code
      checkInputList(prepList)
    Message
      
      -- Checking sheets 
      x Did not find 1 sheet: `newID`
      
      -- Check: Value Recoding 
      v Missing types `mnr`, `mbd`, `mir`, and `mbi` are defined for all items in
      valueRecode.
      i value contains the following values over all items: `0`, `1`, `2`, `3`, `4`,
      `6`, `7`, `8`, and `9`
      v valueRecode contains only 0, 1, and the mistypes: `0`, `1`, `mbd`, `mbi`,
      `mir`, and `mnr`
      
      -- Check: Value Types 
      v No other values than `vc` and the mistypes in valueType.
      
      -- Check: Unit Equivalence 
      v All 4 units in units sheet are also defined in subunits.
      
      -- Check: Subunit Equivalence 
      v All 6 subunits in subunits sheet are also defined in values.
      
      -- Check: Unit Recoding 
      i Units with only one subunit: 3
      i Units with more than one subunit: 1 (`I03`)
      v All units with more than one subunit are defined in unitRecodings sheet.
    Output
      [1] FALSE

---

    Code
      checkInputList(prepList)
    Message
      
      -- Checking sheets 
      x Did not find 1 sheet: `aggrMiss`
      
      -- Check: Value Recoding 
      v Missing types `mnr`, `mbd`, `mir`, and `mbi` are defined for all items in
      valueRecode.
      i value contains the following values over all items: `0`, `1`, `2`, `3`, `4`,
      `6`, `7`, `8`, and `9`
      v valueRecode contains only 0, 1, and the mistypes: `0`, `1`, `mbd`, `mbi`,
      `mir`, and `mnr`
      
      -- Check: Value Types 
      v No other values than `vc` and the mistypes in valueType.
      
      -- Check: Unit Equivalence 
      v All 4 units in units sheet are also defined in subunits.
      
      -- Check: Subunit Equivalence 
      v All 6 subunits in subunits sheet are also defined in values.
      
      -- Check: Unit Recoding 
      i Units with only one subunit: 3
      i Units with more than one subunit: 1 (`I03`)
      v All units with more than one subunit are defined in unitRecodings sheet.
    Output
      [1] FALSE

---

    Code
      checkInputList(prepList)
    Message
      
      -- Checking sheets 
      x Did not find 1 sheet: `blocks`
      
      -- Check: Value Recoding 
      v Missing types `mnr`, `mbd`, `mir`, and `mbi` are defined for all items in
      valueRecode.
      i value contains the following values over all items: `0`, `1`, `2`, `3`, `4`,
      `6`, `7`, `8`, and `9`
      v valueRecode contains only 0, 1, and the mistypes: `0`, `1`, `mbd`, `mbi`,
      `mir`, and `mnr`
      
      -- Check: Value Types 
      v No other values than `vc` and the mistypes in valueType.
      
      -- Check: Unit Equivalence 
      v All 4 units in units sheet are also defined in subunits.
      
      -- Check: Subunit Equivalence 
      v All 6 subunits in subunits sheet are also defined in values.
      
      -- Check: Unit Recoding 
      i Units with only one subunit: 3
      i Units with more than one subunit: 1 (`I03`)
      v All units with more than one subunit are defined in unitRecodings sheet.
    Output
      [1] FALSE

---

    Code
      checkInputList(prepList)
    Message
      
      -- Checking sheets 
      x Did not find 1 sheet: `booklets`
      
      -- Check: Value Recoding 
      v Missing types `mnr`, `mbd`, `mir`, and `mbi` are defined for all items in
      valueRecode.
      i value contains the following values over all items: `0`, `1`, `2`, `3`, `4`,
      `6`, `7`, `8`, and `9`
      v valueRecode contains only 0, 1, and the mistypes: `0`, `1`, `mbd`, `mbi`,
      `mir`, and `mnr`
      
      -- Check: Value Types 
      v No other values than `vc` and the mistypes in valueType.
      
      -- Check: Unit Equivalence 
      v All 4 units in units sheet are also defined in subunits.
      
      -- Check: Subunit Equivalence 
      v All 6 subunits in subunits sheet are also defined in values.
      
      -- Check: Unit Recoding 
      i Units with only one subunit: 3
      i Units with more than one subunit: 1 (`I03`)
      v All units with more than one subunit are defined in unitRecodings sheet.
    Output
      [1] FALSE

# identifies and flags missing sheets with consequences for checks [ansi]

    Code
      checkInputList(prepList)
    Message
      
      -- Checking sheets 
      [31mx[39m Did not find 1 sheet: `units`
      > No checks for unit equivalence available.
      
      -- Check: Value Recoding 
      [32mv[39m Missing types `mnr`, `mbd`, `mir`, and `mbi` are defined for all items in
      [32mvalueRecode[39m.
      [36mi[39m [32mvalue[39m contains the following values over all items: `0`, `1`, `2`, `3`, `4`,
      `6`, `7`, `8`, and `9`
      [32mv[39m [32mvalueRecode[39m contains only 0, 1, and the mistypes: `0`, `1`, `mbd`, `mbi`,
      `mir`, and `mnr`
      
      -- Check: Value Types 
      [32mv[39m No other values than `vc` and the mistypes in [32mvalueType[39m.
      
      -- Check: Subunit Equivalence 
      [32mv[39m All 6 subunits in [32msubunits[39m sheet are also defined in [32mvalues[39m.
      
      -- Check: Unit Recoding 
      [36mi[39m Units with only one subunit: 3
      [36mi[39m Units with more than one subunit: 1 (`I03`)
      [32mv[39m All units with more than one subunit are defined in [32munitRecodings[39m sheet.
    Output
      [1] FALSE

---

    Code
      checkInputList(prepList)
    Message
      
      -- Checking sheets 
      [31mx[39m Did not find 1 sheet: `subunits`
      > No checks for unit equivalence and subunit equivalence available.
      
      -- Check: Value Recoding 
      [32mv[39m Missing types `mnr`, `mbd`, `mir`, and `mbi` are defined for all items in
      [32mvalueRecode[39m.
      [36mi[39m [32mvalue[39m contains the following values over all items: `0`, `1`, `2`, `3`, `4`,
      `6`, `7`, `8`, and `9`
      [32mv[39m [32mvalueRecode[39m contains only 0, 1, and the mistypes: `0`, `1`, `mbd`, `mbi`,
      `mir`, and `mnr`
      
      -- Check: Value Types 
      [32mv[39m No other values than `vc` and the mistypes in [32mvalueType[39m.
    Output
      [1] FALSE

---

    Code
      checkInputList(prepList)
    Message
      
      -- Checking sheets 
      [31mx[39m Did not find 1 sheet: `values`
      > No checks for subunit equivalence, value recoding, and value types available.
      
      -- Check: Unit Equivalence 
      [32mv[39m All 4 units in [32munits[39m sheet are also defined in [32msubunits[39m.
    Output
      [1] FALSE

---

    Code
      checkInputList(prepList)
    Message
      
      -- Checking sheets 
      [31mx[39m Did not find 1 sheet: `unitRecodings`
      > No checks for unit recoding available.
      
      -- Check: Value Recoding 
      [32mv[39m Missing types `mnr`, `mbd`, `mir`, and `mbi` are defined for all items in
      [32mvalueRecode[39m.
      [36mi[39m [32mvalue[39m contains the following values over all items: `0`, `1`, `2`, `3`, `4`,
      `6`, `7`, `8`, and `9`
      [32mv[39m [32mvalueRecode[39m contains only 0, 1, and the mistypes: `0`, `1`, `mbd`, `mbi`,
      `mir`, and `mnr`
      
      -- Check: Value Types 
      [32mv[39m No other values than `vc` and the mistypes in [32mvalueType[39m.
      
      -- Check: Unit Equivalence 
      [32mv[39m All 4 units in [32munits[39m sheet are also defined in [32msubunits[39m.
      
      -- Check: Subunit Equivalence 
      [32mv[39m All 6 subunits in [32msubunits[39m sheet are also defined in [32mvalues[39m.
      
      -- Check: Unit Recoding 
      [36mi[39m Units with only one subunit: 3
      [36mi[39m Units with more than one subunit: 1 (`I03`)
      [31mx[39m Not all units with more than one subunit are defined in [32munitRecodings[39m sheet:
      `I03`
    Output
      [1] FALSE

---

    Code
      checkInputList(prepList)
    Message
      
      -- Checking sheets 
      [31mx[39m Did not find 1 sheet: `savFiles`
      
      -- Check: Value Recoding 
      [32mv[39m Missing types `mnr`, `mbd`, `mir`, and `mbi` are defined for all items in
      [32mvalueRecode[39m.
      [36mi[39m [32mvalue[39m contains the following values over all items: `0`, `1`, `2`, `3`, `4`,
      `6`, `7`, `8`, and `9`
      [32mv[39m [32mvalueRecode[39m contains only 0, 1, and the mistypes: `0`, `1`, `mbd`, `mbi`,
      `mir`, and `mnr`
      
      -- Check: Value Types 
      [32mv[39m No other values than `vc` and the mistypes in [32mvalueType[39m.
      
      -- Check: Unit Equivalence 
      [32mv[39m All 4 units in [32munits[39m sheet are also defined in [32msubunits[39m.
      
      -- Check: Subunit Equivalence 
      [32mv[39m All 6 subunits in [32msubunits[39m sheet are also defined in [32mvalues[39m.
      
      -- Check: Unit Recoding 
      [36mi[39m Units with only one subunit: 3
      [36mi[39m Units with more than one subunit: 1 (`I03`)
      [32mv[39m All units with more than one subunit are defined in [32munitRecodings[39m sheet.
    Output
      [1] FALSE

---

    Code
      checkInputList(prepList)
    Message
      
      -- Checking sheets 
      [31mx[39m Did not find 1 sheet: `newID`
      
      -- Check: Value Recoding 
      [32mv[39m Missing types `mnr`, `mbd`, `mir`, and `mbi` are defined for all items in
      [32mvalueRecode[39m.
      [36mi[39m [32mvalue[39m contains the following values over all items: `0`, `1`, `2`, `3`, `4`,
      `6`, `7`, `8`, and `9`
      [32mv[39m [32mvalueRecode[39m contains only 0, 1, and the mistypes: `0`, `1`, `mbd`, `mbi`,
      `mir`, and `mnr`
      
      -- Check: Value Types 
      [32mv[39m No other values than `vc` and the mistypes in [32mvalueType[39m.
      
      -- Check: Unit Equivalence 
      [32mv[39m All 4 units in [32munits[39m sheet are also defined in [32msubunits[39m.
      
      -- Check: Subunit Equivalence 
      [32mv[39m All 6 subunits in [32msubunits[39m sheet are also defined in [32mvalues[39m.
      
      -- Check: Unit Recoding 
      [36mi[39m Units with only one subunit: 3
      [36mi[39m Units with more than one subunit: 1 (`I03`)
      [32mv[39m All units with more than one subunit are defined in [32munitRecodings[39m sheet.
    Output
      [1] FALSE

---

    Code
      checkInputList(prepList)
    Message
      
      -- Checking sheets 
      [31mx[39m Did not find 1 sheet: `aggrMiss`
      
      -- Check: Value Recoding 
      [32mv[39m Missing types `mnr`, `mbd`, `mir`, and `mbi` are defined for all items in
      [32mvalueRecode[39m.
      [36mi[39m [32mvalue[39m contains the following values over all items: `0`, `1`, `2`, `3`, `4`,
      `6`, `7`, `8`, and `9`
      [32mv[39m [32mvalueRecode[39m contains only 0, 1, and the mistypes: `0`, `1`, `mbd`, `mbi`,
      `mir`, and `mnr`
      
      -- Check: Value Types 
      [32mv[39m No other values than `vc` and the mistypes in [32mvalueType[39m.
      
      -- Check: Unit Equivalence 
      [32mv[39m All 4 units in [32munits[39m sheet are also defined in [32msubunits[39m.
      
      -- Check: Subunit Equivalence 
      [32mv[39m All 6 subunits in [32msubunits[39m sheet are also defined in [32mvalues[39m.
      
      -- Check: Unit Recoding 
      [36mi[39m Units with only one subunit: 3
      [36mi[39m Units with more than one subunit: 1 (`I03`)
      [32mv[39m All units with more than one subunit are defined in [32munitRecodings[39m sheet.
    Output
      [1] FALSE

---

    Code
      checkInputList(prepList)
    Message
      
      -- Checking sheets 
      [31mx[39m Did not find 1 sheet: `blocks`
      
      -- Check: Value Recoding 
      [32mv[39m Missing types `mnr`, `mbd`, `mir`, and `mbi` are defined for all items in
      [32mvalueRecode[39m.
      [36mi[39m [32mvalue[39m contains the following values over all items: `0`, `1`, `2`, `3`, `4`,
      `6`, `7`, `8`, and `9`
      [32mv[39m [32mvalueRecode[39m contains only 0, 1, and the mistypes: `0`, `1`, `mbd`, `mbi`,
      `mir`, and `mnr`
      
      -- Check: Value Types 
      [32mv[39m No other values than `vc` and the mistypes in [32mvalueType[39m.
      
      -- Check: Unit Equivalence 
      [32mv[39m All 4 units in [32munits[39m sheet are also defined in [32msubunits[39m.
      
      -- Check: Subunit Equivalence 
      [32mv[39m All 6 subunits in [32msubunits[39m sheet are also defined in [32mvalues[39m.
      
      -- Check: Unit Recoding 
      [36mi[39m Units with only one subunit: 3
      [36mi[39m Units with more than one subunit: 1 (`I03`)
      [32mv[39m All units with more than one subunit are defined in [32munitRecodings[39m sheet.
    Output
      [1] FALSE

---

    Code
      checkInputList(prepList)
    Message
      
      -- Checking sheets 
      [31mx[39m Did not find 1 sheet: `booklets`
      
      -- Check: Value Recoding 
      [32mv[39m Missing types `mnr`, `mbd`, `mir`, and `mbi` are defined for all items in
      [32mvalueRecode[39m.
      [36mi[39m [32mvalue[39m contains the following values over all items: `0`, `1`, `2`, `3`, `4`,
      `6`, `7`, `8`, and `9`
      [32mv[39m [32mvalueRecode[39m contains only 0, 1, and the mistypes: `0`, `1`, `mbd`, `mbi`,
      `mir`, and `mnr`
      
      -- Check: Value Types 
      [32mv[39m No other values than `vc` and the mistypes in [32mvalueType[39m.
      
      -- Check: Unit Equivalence 
      [32mv[39m All 4 units in [32munits[39m sheet are also defined in [32msubunits[39m.
      
      -- Check: Subunit Equivalence 
      [32mv[39m All 6 subunits in [32msubunits[39m sheet are also defined in [32mvalues[39m.
      
      -- Check: Unit Recoding 
      [36mi[39m Units with only one subunit: 3
      [36mi[39m Units with more than one subunit: 1 (`I03`)
      [32mv[39m All units with more than one subunit are defined in [32munitRecodings[39m sheet.
    Output
      [1] FALSE

# identifies and flags missing sheets with consequences for checks [unicode]

    Code
      checkInputList(prepList)
    Message
      
      ── Checking sheets 
      ✖ Did not find 1 sheet: `units`
      → No checks for unit equivalence available.
      
      ── Check: Value Recoding 
      ✔ Missing types `mnr`, `mbd`, `mir`, and `mbi` are defined for all items in
      valueRecode.
      ℹ value contains the following values over all items: `0`, `1`, `2`, `3`, `4`,
      `6`, `7`, `8`, and `9`
      ✔ valueRecode contains only 0, 1, and the mistypes: `0`, `1`, `mbd`, `mbi`,
      `mir`, and `mnr`
      
      ── Check: Value Types 
      ✔ No other values than `vc` and the mistypes in valueType.
      
      ── Check: Subunit Equivalence 
      ✔ All 6 subunits in subunits sheet are also defined in values.
      
      ── Check: Unit Recoding 
      ℹ Units with only one subunit: 3
      ℹ Units with more than one subunit: 1 (`I03`)
      ✔ All units with more than one subunit are defined in unitRecodings sheet.
    Output
      [1] FALSE

---

    Code
      checkInputList(prepList)
    Message
      
      ── Checking sheets 
      ✖ Did not find 1 sheet: `subunits`
      → No checks for unit equivalence and subunit equivalence available.
      
      ── Check: Value Recoding 
      ✔ Missing types `mnr`, `mbd`, `mir`, and `mbi` are defined for all items in
      valueRecode.
      ℹ value contains the following values over all items: `0`, `1`, `2`, `3`, `4`,
      `6`, `7`, `8`, and `9`
      ✔ valueRecode contains only 0, 1, and the mistypes: `0`, `1`, `mbd`, `mbi`,
      `mir`, and `mnr`
      
      ── Check: Value Types 
      ✔ No other values than `vc` and the mistypes in valueType.
    Output
      [1] FALSE

---

    Code
      checkInputList(prepList)
    Message
      
      ── Checking sheets 
      ✖ Did not find 1 sheet: `values`
      → No checks for subunit equivalence, value recoding, and value types available.
      
      ── Check: Unit Equivalence 
      ✔ All 4 units in units sheet are also defined in subunits.
    Output
      [1] FALSE

---

    Code
      checkInputList(prepList)
    Message
      
      ── Checking sheets 
      ✖ Did not find 1 sheet: `unitRecodings`
      → No checks for unit recoding available.
      
      ── Check: Value Recoding 
      ✔ Missing types `mnr`, `mbd`, `mir`, and `mbi` are defined for all items in
      valueRecode.
      ℹ value contains the following values over all items: `0`, `1`, `2`, `3`, `4`,
      `6`, `7`, `8`, and `9`
      ✔ valueRecode contains only 0, 1, and the mistypes: `0`, `1`, `mbd`, `mbi`,
      `mir`, and `mnr`
      
      ── Check: Value Types 
      ✔ No other values than `vc` and the mistypes in valueType.
      
      ── Check: Unit Equivalence 
      ✔ All 4 units in units sheet are also defined in subunits.
      
      ── Check: Subunit Equivalence 
      ✔ All 6 subunits in subunits sheet are also defined in values.
      
      ── Check: Unit Recoding 
      ℹ Units with only one subunit: 3
      ℹ Units with more than one subunit: 1 (`I03`)
      ✖ Not all units with more than one subunit are defined in unitRecodings sheet:
      `I03`
    Output
      [1] FALSE

---

    Code
      checkInputList(prepList)
    Message
      
      ── Checking sheets 
      ✖ Did not find 1 sheet: `savFiles`
      
      ── Check: Value Recoding 
      ✔ Missing types `mnr`, `mbd`, `mir`, and `mbi` are defined for all items in
      valueRecode.
      ℹ value contains the following values over all items: `0`, `1`, `2`, `3`, `4`,
      `6`, `7`, `8`, and `9`
      ✔ valueRecode contains only 0, 1, and the mistypes: `0`, `1`, `mbd`, `mbi`,
      `mir`, and `mnr`
      
      ── Check: Value Types 
      ✔ No other values than `vc` and the mistypes in valueType.
      
      ── Check: Unit Equivalence 
      ✔ All 4 units in units sheet are also defined in subunits.
      
      ── Check: Subunit Equivalence 
      ✔ All 6 subunits in subunits sheet are also defined in values.
      
      ── Check: Unit Recoding 
      ℹ Units with only one subunit: 3
      ℹ Units with more than one subunit: 1 (`I03`)
      ✔ All units with more than one subunit are defined in unitRecodings sheet.
    Output
      [1] FALSE

---

    Code
      checkInputList(prepList)
    Message
      
      ── Checking sheets 
      ✖ Did not find 1 sheet: `newID`
      
      ── Check: Value Recoding 
      ✔ Missing types `mnr`, `mbd`, `mir`, and `mbi` are defined for all items in
      valueRecode.
      ℹ value contains the following values over all items: `0`, `1`, `2`, `3`, `4`,
      `6`, `7`, `8`, and `9`
      ✔ valueRecode contains only 0, 1, and the mistypes: `0`, `1`, `mbd`, `mbi`,
      `mir`, and `mnr`
      
      ── Check: Value Types 
      ✔ No other values than `vc` and the mistypes in valueType.
      
      ── Check: Unit Equivalence 
      ✔ All 4 units in units sheet are also defined in subunits.
      
      ── Check: Subunit Equivalence 
      ✔ All 6 subunits in subunits sheet are also defined in values.
      
      ── Check: Unit Recoding 
      ℹ Units with only one subunit: 3
      ℹ Units with more than one subunit: 1 (`I03`)
      ✔ All units with more than one subunit are defined in unitRecodings sheet.
    Output
      [1] FALSE

---

    Code
      checkInputList(prepList)
    Message
      
      ── Checking sheets 
      ✖ Did not find 1 sheet: `aggrMiss`
      
      ── Check: Value Recoding 
      ✔ Missing types `mnr`, `mbd`, `mir`, and `mbi` are defined for all items in
      valueRecode.
      ℹ value contains the following values over all items: `0`, `1`, `2`, `3`, `4`,
      `6`, `7`, `8`, and `9`
      ✔ valueRecode contains only 0, 1, and the mistypes: `0`, `1`, `mbd`, `mbi`,
      `mir`, and `mnr`
      
      ── Check: Value Types 
      ✔ No other values than `vc` and the mistypes in valueType.
      
      ── Check: Unit Equivalence 
      ✔ All 4 units in units sheet are also defined in subunits.
      
      ── Check: Subunit Equivalence 
      ✔ All 6 subunits in subunits sheet are also defined in values.
      
      ── Check: Unit Recoding 
      ℹ Units with only one subunit: 3
      ℹ Units with more than one subunit: 1 (`I03`)
      ✔ All units with more than one subunit are defined in unitRecodings sheet.
    Output
      [1] FALSE

---

    Code
      checkInputList(prepList)
    Message
      
      ── Checking sheets 
      ✖ Did not find 1 sheet: `blocks`
      
      ── Check: Value Recoding 
      ✔ Missing types `mnr`, `mbd`, `mir`, and `mbi` are defined for all items in
      valueRecode.
      ℹ value contains the following values over all items: `0`, `1`, `2`, `3`, `4`,
      `6`, `7`, `8`, and `9`
      ✔ valueRecode contains only 0, 1, and the mistypes: `0`, `1`, `mbd`, `mbi`,
      `mir`, and `mnr`
      
      ── Check: Value Types 
      ✔ No other values than `vc` and the mistypes in valueType.
      
      ── Check: Unit Equivalence 
      ✔ All 4 units in units sheet are also defined in subunits.
      
      ── Check: Subunit Equivalence 
      ✔ All 6 subunits in subunits sheet are also defined in values.
      
      ── Check: Unit Recoding 
      ℹ Units with only one subunit: 3
      ℹ Units with more than one subunit: 1 (`I03`)
      ✔ All units with more than one subunit are defined in unitRecodings sheet.
    Output
      [1] FALSE

---

    Code
      checkInputList(prepList)
    Message
      
      ── Checking sheets 
      ✖ Did not find 1 sheet: `booklets`
      
      ── Check: Value Recoding 
      ✔ Missing types `mnr`, `mbd`, `mir`, and `mbi` are defined for all items in
      valueRecode.
      ℹ value contains the following values over all items: `0`, `1`, `2`, `3`, `4`,
      `6`, `7`, `8`, and `9`
      ✔ valueRecode contains only 0, 1, and the mistypes: `0`, `1`, `mbd`, `mbi`,
      `mir`, and `mnr`
      
      ── Check: Value Types 
      ✔ No other values than `vc` and the mistypes in valueType.
      
      ── Check: Unit Equivalence 
      ✔ All 4 units in units sheet are also defined in subunits.
      
      ── Check: Subunit Equivalence 
      ✔ All 6 subunits in subunits sheet are also defined in values.
      
      ── Check: Unit Recoding 
      ℹ Units with only one subunit: 3
      ℹ Units with more than one subunit: 1 (`I03`)
      ✔ All units with more than one subunit are defined in unitRecodings sheet.
    Output
      [1] FALSE

# identifies and flags missing sheets with consequences for checks [fancy]

    Code
      checkInputList(prepList)
    Message
      
      ── Checking sheets 
      [31m✖[39m Did not find 1 sheet: `units`
      → No checks for unit equivalence available.
      
      ── Check: Value Recoding 
      [32m✔[39m Missing types `mnr`, `mbd`, `mir`, and `mbi` are defined for all items in
      [32mvalueRecode[39m.
      [36mℹ[39m [32mvalue[39m contains the following values over all items: `0`, `1`, `2`, `3`, `4`,
      `6`, `7`, `8`, and `9`
      [32m✔[39m [32mvalueRecode[39m contains only 0, 1, and the mistypes: `0`, `1`, `mbd`, `mbi`,
      `mir`, and `mnr`
      
      ── Check: Value Types 
      [32m✔[39m No other values than `vc` and the mistypes in [32mvalueType[39m.
      
      ── Check: Subunit Equivalence 
      [32m✔[39m All 6 subunits in [32msubunits[39m sheet are also defined in [32mvalues[39m.
      
      ── Check: Unit Recoding 
      [36mℹ[39m Units with only one subunit: 3
      [36mℹ[39m Units with more than one subunit: 1 (`I03`)
      [32m✔[39m All units with more than one subunit are defined in [32munitRecodings[39m sheet.
    Output
      [1] FALSE

---

    Code
      checkInputList(prepList)
    Message
      
      ── Checking sheets 
      [31m✖[39m Did not find 1 sheet: `subunits`
      → No checks for unit equivalence and subunit equivalence available.
      
      ── Check: Value Recoding 
      [32m✔[39m Missing types `mnr`, `mbd`, `mir`, and `mbi` are defined for all items in
      [32mvalueRecode[39m.
      [36mℹ[39m [32mvalue[39m contains the following values over all items: `0`, `1`, `2`, `3`, `4`,
      `6`, `7`, `8`, and `9`
      [32m✔[39m [32mvalueRecode[39m contains only 0, 1, and the mistypes: `0`, `1`, `mbd`, `mbi`,
      `mir`, and `mnr`
      
      ── Check: Value Types 
      [32m✔[39m No other values than `vc` and the mistypes in [32mvalueType[39m.
    Output
      [1] FALSE

---

    Code
      checkInputList(prepList)
    Message
      
      ── Checking sheets 
      [31m✖[39m Did not find 1 sheet: `values`
      → No checks for subunit equivalence, value recoding, and value types available.
      
      ── Check: Unit Equivalence 
      [32m✔[39m All 4 units in [32munits[39m sheet are also defined in [32msubunits[39m.
    Output
      [1] FALSE

---

    Code
      checkInputList(prepList)
    Message
      
      ── Checking sheets 
      [31m✖[39m Did not find 1 sheet: `unitRecodings`
      → No checks for unit recoding available.
      
      ── Check: Value Recoding 
      [32m✔[39m Missing types `mnr`, `mbd`, `mir`, and `mbi` are defined for all items in
      [32mvalueRecode[39m.
      [36mℹ[39m [32mvalue[39m contains the following values over all items: `0`, `1`, `2`, `3`, `4`,
      `6`, `7`, `8`, and `9`
      [32m✔[39m [32mvalueRecode[39m contains only 0, 1, and the mistypes: `0`, `1`, `mbd`, `mbi`,
      `mir`, and `mnr`
      
      ── Check: Value Types 
      [32m✔[39m No other values than `vc` and the mistypes in [32mvalueType[39m.
      
      ── Check: Unit Equivalence 
      [32m✔[39m All 4 units in [32munits[39m sheet are also defined in [32msubunits[39m.
      
      ── Check: Subunit Equivalence 
      [32m✔[39m All 6 subunits in [32msubunits[39m sheet are also defined in [32mvalues[39m.
      
      ── Check: Unit Recoding 
      [36mℹ[39m Units with only one subunit: 3
      [36mℹ[39m Units with more than one subunit: 1 (`I03`)
      [31m✖[39m Not all units with more than one subunit are defined in [32munitRecodings[39m sheet:
      `I03`
    Output
      [1] FALSE

---

    Code
      checkInputList(prepList)
    Message
      
      ── Checking sheets 
      [31m✖[39m Did not find 1 sheet: `savFiles`
      
      ── Check: Value Recoding 
      [32m✔[39m Missing types `mnr`, `mbd`, `mir`, and `mbi` are defined for all items in
      [32mvalueRecode[39m.
      [36mℹ[39m [32mvalue[39m contains the following values over all items: `0`, `1`, `2`, `3`, `4`,
      `6`, `7`, `8`, and `9`
      [32m✔[39m [32mvalueRecode[39m contains only 0, 1, and the mistypes: `0`, `1`, `mbd`, `mbi`,
      `mir`, and `mnr`
      
      ── Check: Value Types 
      [32m✔[39m No other values than `vc` and the mistypes in [32mvalueType[39m.
      
      ── Check: Unit Equivalence 
      [32m✔[39m All 4 units in [32munits[39m sheet are also defined in [32msubunits[39m.
      
      ── Check: Subunit Equivalence 
      [32m✔[39m All 6 subunits in [32msubunits[39m sheet are also defined in [32mvalues[39m.
      
      ── Check: Unit Recoding 
      [36mℹ[39m Units with only one subunit: 3
      [36mℹ[39m Units with more than one subunit: 1 (`I03`)
      [32m✔[39m All units with more than one subunit are defined in [32munitRecodings[39m sheet.
    Output
      [1] FALSE

---

    Code
      checkInputList(prepList)
    Message
      
      ── Checking sheets 
      [31m✖[39m Did not find 1 sheet: `newID`
      
      ── Check: Value Recoding 
      [32m✔[39m Missing types `mnr`, `mbd`, `mir`, and `mbi` are defined for all items in
      [32mvalueRecode[39m.
      [36mℹ[39m [32mvalue[39m contains the following values over all items: `0`, `1`, `2`, `3`, `4`,
      `6`, `7`, `8`, and `9`
      [32m✔[39m [32mvalueRecode[39m contains only 0, 1, and the mistypes: `0`, `1`, `mbd`, `mbi`,
      `mir`, and `mnr`
      
      ── Check: Value Types 
      [32m✔[39m No other values than `vc` and the mistypes in [32mvalueType[39m.
      
      ── Check: Unit Equivalence 
      [32m✔[39m All 4 units in [32munits[39m sheet are also defined in [32msubunits[39m.
      
      ── Check: Subunit Equivalence 
      [32m✔[39m All 6 subunits in [32msubunits[39m sheet are also defined in [32mvalues[39m.
      
      ── Check: Unit Recoding 
      [36mℹ[39m Units with only one subunit: 3
      [36mℹ[39m Units with more than one subunit: 1 (`I03`)
      [32m✔[39m All units with more than one subunit are defined in [32munitRecodings[39m sheet.
    Output
      [1] FALSE

---

    Code
      checkInputList(prepList)
    Message
      
      ── Checking sheets 
      [31m✖[39m Did not find 1 sheet: `aggrMiss`
      
      ── Check: Value Recoding 
      [32m✔[39m Missing types `mnr`, `mbd`, `mir`, and `mbi` are defined for all items in
      [32mvalueRecode[39m.
      [36mℹ[39m [32mvalue[39m contains the following values over all items: `0`, `1`, `2`, `3`, `4`,
      `6`, `7`, `8`, and `9`
      [32m✔[39m [32mvalueRecode[39m contains only 0, 1, and the mistypes: `0`, `1`, `mbd`, `mbi`,
      `mir`, and `mnr`
      
      ── Check: Value Types 
      [32m✔[39m No other values than `vc` and the mistypes in [32mvalueType[39m.
      
      ── Check: Unit Equivalence 
      [32m✔[39m All 4 units in [32munits[39m sheet are also defined in [32msubunits[39m.
      
      ── Check: Subunit Equivalence 
      [32m✔[39m All 6 subunits in [32msubunits[39m sheet are also defined in [32mvalues[39m.
      
      ── Check: Unit Recoding 
      [36mℹ[39m Units with only one subunit: 3
      [36mℹ[39m Units with more than one subunit: 1 (`I03`)
      [32m✔[39m All units with more than one subunit are defined in [32munitRecodings[39m sheet.
    Output
      [1] FALSE

---

    Code
      checkInputList(prepList)
    Message
      
      ── Checking sheets 
      [31m✖[39m Did not find 1 sheet: `blocks`
      
      ── Check: Value Recoding 
      [32m✔[39m Missing types `mnr`, `mbd`, `mir`, and `mbi` are defined for all items in
      [32mvalueRecode[39m.
      [36mℹ[39m [32mvalue[39m contains the following values over all items: `0`, `1`, `2`, `3`, `4`,
      `6`, `7`, `8`, and `9`
      [32m✔[39m [32mvalueRecode[39m contains only 0, 1, and the mistypes: `0`, `1`, `mbd`, `mbi`,
      `mir`, and `mnr`
      
      ── Check: Value Types 
      [32m✔[39m No other values than `vc` and the mistypes in [32mvalueType[39m.
      
      ── Check: Unit Equivalence 
      [32m✔[39m All 4 units in [32munits[39m sheet are also defined in [32msubunits[39m.
      
      ── Check: Subunit Equivalence 
      [32m✔[39m All 6 subunits in [32msubunits[39m sheet are also defined in [32mvalues[39m.
      
      ── Check: Unit Recoding 
      [36mℹ[39m Units with only one subunit: 3
      [36mℹ[39m Units with more than one subunit: 1 (`I03`)
      [32m✔[39m All units with more than one subunit are defined in [32munitRecodings[39m sheet.
    Output
      [1] FALSE

---

    Code
      checkInputList(prepList)
    Message
      
      ── Checking sheets 
      [31m✖[39m Did not find 1 sheet: `booklets`
      
      ── Check: Value Recoding 
      [32m✔[39m Missing types `mnr`, `mbd`, `mir`, and `mbi` are defined for all items in
      [32mvalueRecode[39m.
      [36mℹ[39m [32mvalue[39m contains the following values over all items: `0`, `1`, `2`, `3`, `4`,
      `6`, `7`, `8`, and `9`
      [32m✔[39m [32mvalueRecode[39m contains only 0, 1, and the mistypes: `0`, `1`, `mbd`, `mbi`,
      `mir`, and `mnr`
      
      ── Check: Value Types 
      [32m✔[39m No other values than `vc` and the mistypes in [32mvalueType[39m.
      
      ── Check: Unit Equivalence 
      [32m✔[39m All 4 units in [32munits[39m sheet are also defined in [32msubunits[39m.
      
      ── Check: Subunit Equivalence 
      [32m✔[39m All 6 subunits in [32msubunits[39m sheet are also defined in [32mvalues[39m.
      
      ── Check: Unit Recoding 
      [36mℹ[39m Units with only one subunit: 3
      [36mℹ[39m Units with more than one subunit: 1 (`I03`)
      [32m✔[39m All units with more than one subunit are defined in [32munitRecodings[39m sheet.
    Output
      [1] FALSE

# identifies and flags missing columns with consequences for checks [plain]

    Code
      checkInputList(prepList)
    Message
      x Sheet units does not contain all expected columns.
      > Expected: `unit`, `unitType`, and `unitAggregateRule`
      > Found:    `unit` and `unitType`
      > Missing:  `unitAggregateRule`
      
      -- Check: Value Recoding 
      v Missing types `mnr`, `mbd`, `mir`, and `mbi` are defined for all items in
      valueRecode.
      i value contains the following values over all items: `0`, `1`, `2`, `3`, `4`,
      `6`, `7`, `8`, and `9`
      v valueRecode contains only 0, 1, and the mistypes: `0`, `1`, `mbd`, `mbi`,
      `mir`, and `mnr`
      
      -- Check: Value Types 
      v No other values than `vc` and the mistypes in valueType.
      
      -- Check: Unit Equivalence 
      v All 4 units in units sheet are also defined in subunits.
      
      -- Check: Subunit Equivalence 
      v All 6 subunits in subunits sheet are also defined in values.
      
      -- Check: Unit Recoding 
      i Units with only one subunit: 3
      i Units with more than one subunit: 1 (`I03`)
      v All units with more than one subunit are defined in unitRecodings sheet.
    Output
      [1] FALSE

---

    Code
      checkInputList(prepList)
    Message
      x Sheet units does not contain all expected columns.
      > Expected: `unit`, `unitType`, and `unitAggregateRule`
      > Found:    `unit` and `unitType`
      > Missing:  `unitAggregateRule`
      x Sheet values does not contain all expected columns.
      > Expected: `subunit`, `value`, `valueRecode`, and `valueType`
      > Found:    `subunit`, `value`, and `valueType`
      > Missing:  `valueRecode`
      > No checks for value recoding available.
      
      -- Check: Value Types 
      v No other values than `vc` and the mistypes in valueType.
      
      -- Check: Unit Equivalence 
      v All 4 units in units sheet are also defined in subunits.
      
      -- Check: Subunit Equivalence 
      v All 6 subunits in subunits sheet are also defined in values.
      
      -- Check: Unit Recoding 
      i Units with only one subunit: 3
      i Units with more than one subunit: 1 (`I03`)
      v All units with more than one subunit are defined in unitRecodings sheet.
    Output
      [1] FALSE

---

    Code
      checkInputList(prepList)
    Message
      x Sheet units does not contain all expected columns.
      > Expected: `unit`, `unitType`, and `unitAggregateRule`
      > Found:    `unit` and `unitType`
      > Missing:  `unitAggregateRule`
      x Sheet values does not contain all expected columns.
      > Expected: `subunit`, `value`, `valueRecode`, and `valueType`
      > Found:    `subunit` and `value`
      > Missing:  `valueRecode` and `valueType`
      > No checks for value recoding and value types available.
      
      -- Check: Unit Equivalence 
      v All 4 units in units sheet are also defined in subunits.
      
      -- Check: Subunit Equivalence 
      v All 6 subunits in subunits sheet are also defined in values.
      
      -- Check: Unit Recoding 
      i Units with only one subunit: 3
      i Units with more than one subunit: 1 (`I03`)
      v All units with more than one subunit are defined in unitRecodings sheet.
    Output
      [1] FALSE

---

    Code
      checkInputList(prepList)
    Message
      x Sheet units does not contain all expected columns.
      > Expected: `unit`, `unitType`, and `unitAggregateRule`
      > Found:    `unit` and `unitType`
      > Missing:  `unitAggregateRule`
      x Sheet values does not contain all expected columns.
      > Expected: `subunit`, `value`, `valueRecode`, and `valueType`
      > Found:    `subunit`
      > Missing:  `value`, `valueRecode`, and `valueType`
      > No checks for value recoding and value types available.
      
      -- Check: Unit Equivalence 
      v All 4 units in units sheet are also defined in subunits.
      
      -- Check: Subunit Equivalence 
      v All 6 subunits in subunits sheet are also defined in values.
      
      -- Check: Unit Recoding 
      i Units with only one subunit: 3
      i Units with more than one subunit: 1 (`I03`)
      v All units with more than one subunit are defined in unitRecodings sheet.
    Output
      [1] FALSE

---

    Code
      checkInputList(prepList)
    Message
      x Sheet units does not contain all expected columns.
      > Expected: `unit`, `unitType`, and `unitAggregateRule`
      > Found:    `unitType` and `unitAggregateRule`
      > Missing:  `unit`
      > No checks for unit equivalence available.
      
      -- Check: Value Recoding 
      v Missing types `mnr`, `mbd`, `mir`, and `mbi` are defined for all items in
      valueRecode.
      i value contains the following values over all items: `0`, `1`, `2`, `3`, `4`,
      `6`, `7`, `8`, and `9`
      v valueRecode contains only 0, 1, and the mistypes: `0`, `1`, `mbd`, `mbi`,
      `mir`, and `mnr`
      
      -- Check: Value Types 
      v No other values than `vc` and the mistypes in valueType.
      
      -- Check: Subunit Equivalence 
      v All 6 subunits in subunits sheet are also defined in values.
      
      -- Check: Unit Recoding 
      i Units with only one subunit: 3
      i Units with more than one subunit: 1 (`I03`)
      v All units with more than one subunit are defined in unitRecodings sheet.
    Output
      [1] FALSE

---

    Code
      checkInputList(prepList)
    Message
      x Sheet units does not contain all expected columns.
      > Expected: `unit`, `unitType`, and `unitAggregateRule`
      > Found:    `unitType` and `unitAggregateRule`
      > Missing:  `unit`
      > No checks for unit equivalence available.
      x Sheet subunits does not contain all expected columns.
      > Expected: `unit`, `subunit`, and `subunitRecoded`
      > Found:    `unit` and `subunitRecoded`
      > Missing:  `subunit`
      > No checks for subunit equivalence available.
      
      -- Check: Value Recoding 
      v Missing types `mnr`, `mbd`, `mir`, and `mbi` are defined for all items in
      valueRecode.
      i value contains the following values over all items: `0`, `1`, `2`, `3`, `4`,
      `6`, `7`, `8`, and `9`
      v valueRecode contains only 0, 1, and the mistypes: `0`, `1`, `mbd`, `mbi`,
      `mir`, and `mnr`
      
      -- Check: Value Types 
      v No other values than `vc` and the mistypes in valueType.
    Output
      [1] FALSE

# identifies and flags missing columns with consequences for checks [ansi]

    Code
      checkInputList(prepList)
    Message
      [31mx[39m Sheet [32munits[39m does not contain all expected columns.
      > Expected: `unit`, `unitType`, and `unitAggregateRule`
      > Found:    `unit` and `unitType`
      > Missing:  `unitAggregateRule`
      
      -- Check: Value Recoding 
      [32mv[39m Missing types `mnr`, `mbd`, `mir`, and `mbi` are defined for all items in
      [32mvalueRecode[39m.
      [36mi[39m [32mvalue[39m contains the following values over all items: `0`, `1`, `2`, `3`, `4`,
      `6`, `7`, `8`, and `9`
      [32mv[39m [32mvalueRecode[39m contains only 0, 1, and the mistypes: `0`, `1`, `mbd`, `mbi`,
      `mir`, and `mnr`
      
      -- Check: Value Types 
      [32mv[39m No other values than `vc` and the mistypes in [32mvalueType[39m.
      
      -- Check: Unit Equivalence 
      [32mv[39m All 4 units in [32munits[39m sheet are also defined in [32msubunits[39m.
      
      -- Check: Subunit Equivalence 
      [32mv[39m All 6 subunits in [32msubunits[39m sheet are also defined in [32mvalues[39m.
      
      -- Check: Unit Recoding 
      [36mi[39m Units with only one subunit: 3
      [36mi[39m Units with more than one subunit: 1 (`I03`)
      [32mv[39m All units with more than one subunit are defined in [32munitRecodings[39m sheet.
    Output
      [1] FALSE

---

    Code
      checkInputList(prepList)
    Message
      [31mx[39m Sheet [32munits[39m does not contain all expected columns.
      > Expected: `unit`, `unitType`, and `unitAggregateRule`
      > Found:    `unit` and `unitType`
      > Missing:  `unitAggregateRule`
      [31mx[39m Sheet [32mvalues[39m does not contain all expected columns.
      > Expected: `subunit`, `value`, `valueRecode`, and `valueType`
      > Found:    `subunit`, `value`, and `valueType`
      > Missing:  `valueRecode`
      > No checks for value recoding available.
      
      -- Check: Value Types 
      [32mv[39m No other values than `vc` and the mistypes in [32mvalueType[39m.
      
      -- Check: Unit Equivalence 
      [32mv[39m All 4 units in [32munits[39m sheet are also defined in [32msubunits[39m.
      
      -- Check: Subunit Equivalence 
      [32mv[39m All 6 subunits in [32msubunits[39m sheet are also defined in [32mvalues[39m.
      
      -- Check: Unit Recoding 
      [36mi[39m Units with only one subunit: 3
      [36mi[39m Units with more than one subunit: 1 (`I03`)
      [32mv[39m All units with more than one subunit are defined in [32munitRecodings[39m sheet.
    Output
      [1] FALSE

---

    Code
      checkInputList(prepList)
    Message
      [31mx[39m Sheet [32munits[39m does not contain all expected columns.
      > Expected: `unit`, `unitType`, and `unitAggregateRule`
      > Found:    `unit` and `unitType`
      > Missing:  `unitAggregateRule`
      [31mx[39m Sheet [32mvalues[39m does not contain all expected columns.
      > Expected: `subunit`, `value`, `valueRecode`, and `valueType`
      > Found:    `subunit` and `value`
      > Missing:  `valueRecode` and `valueType`
      > No checks for value recoding and value types available.
      
      -- Check: Unit Equivalence 
      [32mv[39m All 4 units in [32munits[39m sheet are also defined in [32msubunits[39m.
      
      -- Check: Subunit Equivalence 
      [32mv[39m All 6 subunits in [32msubunits[39m sheet are also defined in [32mvalues[39m.
      
      -- Check: Unit Recoding 
      [36mi[39m Units with only one subunit: 3
      [36mi[39m Units with more than one subunit: 1 (`I03`)
      [32mv[39m All units with more than one subunit are defined in [32munitRecodings[39m sheet.
    Output
      [1] FALSE

---

    Code
      checkInputList(prepList)
    Message
      [31mx[39m Sheet [32munits[39m does not contain all expected columns.
      > Expected: `unit`, `unitType`, and `unitAggregateRule`
      > Found:    `unit` and `unitType`
      > Missing:  `unitAggregateRule`
      [31mx[39m Sheet [32mvalues[39m does not contain all expected columns.
      > Expected: `subunit`, `value`, `valueRecode`, and `valueType`
      > Found:    `subunit`
      > Missing:  `value`, `valueRecode`, and `valueType`
      > No checks for value recoding and value types available.
      
      -- Check: Unit Equivalence 
      [32mv[39m All 4 units in [32munits[39m sheet are also defined in [32msubunits[39m.
      
      -- Check: Subunit Equivalence 
      [32mv[39m All 6 subunits in [32msubunits[39m sheet are also defined in [32mvalues[39m.
      
      -- Check: Unit Recoding 
      [36mi[39m Units with only one subunit: 3
      [36mi[39m Units with more than one subunit: 1 (`I03`)
      [32mv[39m All units with more than one subunit are defined in [32munitRecodings[39m sheet.
    Output
      [1] FALSE

---

    Code
      checkInputList(prepList)
    Message
      [31mx[39m Sheet [32munits[39m does not contain all expected columns.
      > Expected: `unit`, `unitType`, and `unitAggregateRule`
      > Found:    `unitType` and `unitAggregateRule`
      > Missing:  `unit`
      > No checks for unit equivalence available.
      
      -- Check: Value Recoding 
      [32mv[39m Missing types `mnr`, `mbd`, `mir`, and `mbi` are defined for all items in
      [32mvalueRecode[39m.
      [36mi[39m [32mvalue[39m contains the following values over all items: `0`, `1`, `2`, `3`, `4`,
      `6`, `7`, `8`, and `9`
      [32mv[39m [32mvalueRecode[39m contains only 0, 1, and the mistypes: `0`, `1`, `mbd`, `mbi`,
      `mir`, and `mnr`
      
      -- Check: Value Types 
      [32mv[39m No other values than `vc` and the mistypes in [32mvalueType[39m.
      
      -- Check: Subunit Equivalence 
      [32mv[39m All 6 subunits in [32msubunits[39m sheet are also defined in [32mvalues[39m.
      
      -- Check: Unit Recoding 
      [36mi[39m Units with only one subunit: 3
      [36mi[39m Units with more than one subunit: 1 (`I03`)
      [32mv[39m All units with more than one subunit are defined in [32munitRecodings[39m sheet.
    Output
      [1] FALSE

---

    Code
      checkInputList(prepList)
    Message
      [31mx[39m Sheet [32munits[39m does not contain all expected columns.
      > Expected: `unit`, `unitType`, and `unitAggregateRule`
      > Found:    `unitType` and `unitAggregateRule`
      > Missing:  `unit`
      > No checks for unit equivalence available.
      [31mx[39m Sheet [32msubunits[39m does not contain all expected columns.
      > Expected: `unit`, `subunit`, and `subunitRecoded`
      > Found:    `unit` and `subunitRecoded`
      > Missing:  `subunit`
      > No checks for subunit equivalence available.
      
      -- Check: Value Recoding 
      [32mv[39m Missing types `mnr`, `mbd`, `mir`, and `mbi` are defined for all items in
      [32mvalueRecode[39m.
      [36mi[39m [32mvalue[39m contains the following values over all items: `0`, `1`, `2`, `3`, `4`,
      `6`, `7`, `8`, and `9`
      [32mv[39m [32mvalueRecode[39m contains only 0, 1, and the mistypes: `0`, `1`, `mbd`, `mbi`,
      `mir`, and `mnr`
      
      -- Check: Value Types 
      [32mv[39m No other values than `vc` and the mistypes in [32mvalueType[39m.
    Output
      [1] FALSE

# identifies and flags missing columns with consequences for checks [unicode]

    Code
      checkInputList(prepList)
    Message
      ✖ Sheet units does not contain all expected columns.
      → Expected: `unit`, `unitType`, and `unitAggregateRule`
      → Found:    `unit` and `unitType`
      → Missing:  `unitAggregateRule`
      
      ── Check: Value Recoding 
      ✔ Missing types `mnr`, `mbd`, `mir`, and `mbi` are defined for all items in
      valueRecode.
      ℹ value contains the following values over all items: `0`, `1`, `2`, `3`, `4`,
      `6`, `7`, `8`, and `9`
      ✔ valueRecode contains only 0, 1, and the mistypes: `0`, `1`, `mbd`, `mbi`,
      `mir`, and `mnr`
      
      ── Check: Value Types 
      ✔ No other values than `vc` and the mistypes in valueType.
      
      ── Check: Unit Equivalence 
      ✔ All 4 units in units sheet are also defined in subunits.
      
      ── Check: Subunit Equivalence 
      ✔ All 6 subunits in subunits sheet are also defined in values.
      
      ── Check: Unit Recoding 
      ℹ Units with only one subunit: 3
      ℹ Units with more than one subunit: 1 (`I03`)
      ✔ All units with more than one subunit are defined in unitRecodings sheet.
    Output
      [1] FALSE

---

    Code
      checkInputList(prepList)
    Message
      ✖ Sheet units does not contain all expected columns.
      → Expected: `unit`, `unitType`, and `unitAggregateRule`
      → Found:    `unit` and `unitType`
      → Missing:  `unitAggregateRule`
      ✖ Sheet values does not contain all expected columns.
      → Expected: `subunit`, `value`, `valueRecode`, and `valueType`
      → Found:    `subunit`, `value`, and `valueType`
      → Missing:  `valueRecode`
      → No checks for value recoding available.
      
      ── Check: Value Types 
      ✔ No other values than `vc` and the mistypes in valueType.
      
      ── Check: Unit Equivalence 
      ✔ All 4 units in units sheet are also defined in subunits.
      
      ── Check: Subunit Equivalence 
      ✔ All 6 subunits in subunits sheet are also defined in values.
      
      ── Check: Unit Recoding 
      ℹ Units with only one subunit: 3
      ℹ Units with more than one subunit: 1 (`I03`)
      ✔ All units with more than one subunit are defined in unitRecodings sheet.
    Output
      [1] FALSE

---

    Code
      checkInputList(prepList)
    Message
      ✖ Sheet units does not contain all expected columns.
      → Expected: `unit`, `unitType`, and `unitAggregateRule`
      → Found:    `unit` and `unitType`
      → Missing:  `unitAggregateRule`
      ✖ Sheet values does not contain all expected columns.
      → Expected: `subunit`, `value`, `valueRecode`, and `valueType`
      → Found:    `subunit` and `value`
      → Missing:  `valueRecode` and `valueType`
      → No checks for value recoding and value types available.
      
      ── Check: Unit Equivalence 
      ✔ All 4 units in units sheet are also defined in subunits.
      
      ── Check: Subunit Equivalence 
      ✔ All 6 subunits in subunits sheet are also defined in values.
      
      ── Check: Unit Recoding 
      ℹ Units with only one subunit: 3
      ℹ Units with more than one subunit: 1 (`I03`)
      ✔ All units with more than one subunit are defined in unitRecodings sheet.
    Output
      [1] FALSE

---

    Code
      checkInputList(prepList)
    Message
      ✖ Sheet units does not contain all expected columns.
      → Expected: `unit`, `unitType`, and `unitAggregateRule`
      → Found:    `unit` and `unitType`
      → Missing:  `unitAggregateRule`
      ✖ Sheet values does not contain all expected columns.
      → Expected: `subunit`, `value`, `valueRecode`, and `valueType`
      → Found:    `subunit`
      → Missing:  `value`, `valueRecode`, and `valueType`
      → No checks for value recoding and value types available.
      
      ── Check: Unit Equivalence 
      ✔ All 4 units in units sheet are also defined in subunits.
      
      ── Check: Subunit Equivalence 
      ✔ All 6 subunits in subunits sheet are also defined in values.
      
      ── Check: Unit Recoding 
      ℹ Units with only one subunit: 3
      ℹ Units with more than one subunit: 1 (`I03`)
      ✔ All units with more than one subunit are defined in unitRecodings sheet.
    Output
      [1] FALSE

---

    Code
      checkInputList(prepList)
    Message
      ✖ Sheet units does not contain all expected columns.
      → Expected: `unit`, `unitType`, and `unitAggregateRule`
      → Found:    `unitType` and `unitAggregateRule`
      → Missing:  `unit`
      → No checks for unit equivalence available.
      
      ── Check: Value Recoding 
      ✔ Missing types `mnr`, `mbd`, `mir`, and `mbi` are defined for all items in
      valueRecode.
      ℹ value contains the following values over all items: `0`, `1`, `2`, `3`, `4`,
      `6`, `7`, `8`, and `9`
      ✔ valueRecode contains only 0, 1, and the mistypes: `0`, `1`, `mbd`, `mbi`,
      `mir`, and `mnr`
      
      ── Check: Value Types 
      ✔ No other values than `vc` and the mistypes in valueType.
      
      ── Check: Subunit Equivalence 
      ✔ All 6 subunits in subunits sheet are also defined in values.
      
      ── Check: Unit Recoding 
      ℹ Units with only one subunit: 3
      ℹ Units with more than one subunit: 1 (`I03`)
      ✔ All units with more than one subunit are defined in unitRecodings sheet.
    Output
      [1] FALSE

---

    Code
      checkInputList(prepList)
    Message
      ✖ Sheet units does not contain all expected columns.
      → Expected: `unit`, `unitType`, and `unitAggregateRule`
      → Found:    `unitType` and `unitAggregateRule`
      → Missing:  `unit`
      → No checks for unit equivalence available.
      ✖ Sheet subunits does not contain all expected columns.
      → Expected: `unit`, `subunit`, and `subunitRecoded`
      → Found:    `unit` and `subunitRecoded`
      → Missing:  `subunit`
      → No checks for subunit equivalence available.
      
      ── Check: Value Recoding 
      ✔ Missing types `mnr`, `mbd`, `mir`, and `mbi` are defined for all items in
      valueRecode.
      ℹ value contains the following values over all items: `0`, `1`, `2`, `3`, `4`,
      `6`, `7`, `8`, and `9`
      ✔ valueRecode contains only 0, 1, and the mistypes: `0`, `1`, `mbd`, `mbi`,
      `mir`, and `mnr`
      
      ── Check: Value Types 
      ✔ No other values than `vc` and the mistypes in valueType.
    Output
      [1] FALSE

# identifies and flags missing columns with consequences for checks [fancy]

    Code
      checkInputList(prepList)
    Message
      [31m✖[39m Sheet [32munits[39m does not contain all expected columns.
      → Expected: `unit`, `unitType`, and `unitAggregateRule`
      → Found:    `unit` and `unitType`
      → Missing:  `unitAggregateRule`
      
      ── Check: Value Recoding 
      [32m✔[39m Missing types `mnr`, `mbd`, `mir`, and `mbi` are defined for all items in
      [32mvalueRecode[39m.
      [36mℹ[39m [32mvalue[39m contains the following values over all items: `0`, `1`, `2`, `3`, `4`,
      `6`, `7`, `8`, and `9`
      [32m✔[39m [32mvalueRecode[39m contains only 0, 1, and the mistypes: `0`, `1`, `mbd`, `mbi`,
      `mir`, and `mnr`
      
      ── Check: Value Types 
      [32m✔[39m No other values than `vc` and the mistypes in [32mvalueType[39m.
      
      ── Check: Unit Equivalence 
      [32m✔[39m All 4 units in [32munits[39m sheet are also defined in [32msubunits[39m.
      
      ── Check: Subunit Equivalence 
      [32m✔[39m All 6 subunits in [32msubunits[39m sheet are also defined in [32mvalues[39m.
      
      ── Check: Unit Recoding 
      [36mℹ[39m Units with only one subunit: 3
      [36mℹ[39m Units with more than one subunit: 1 (`I03`)
      [32m✔[39m All units with more than one subunit are defined in [32munitRecodings[39m sheet.
    Output
      [1] FALSE

---

    Code
      checkInputList(prepList)
    Message
      [31m✖[39m Sheet [32munits[39m does not contain all expected columns.
      → Expected: `unit`, `unitType`, and `unitAggregateRule`
      → Found:    `unit` and `unitType`
      → Missing:  `unitAggregateRule`
      [31m✖[39m Sheet [32mvalues[39m does not contain all expected columns.
      → Expected: `subunit`, `value`, `valueRecode`, and `valueType`
      → Found:    `subunit`, `value`, and `valueType`
      → Missing:  `valueRecode`
      → No checks for value recoding available.
      
      ── Check: Value Types 
      [32m✔[39m No other values than `vc` and the mistypes in [32mvalueType[39m.
      
      ── Check: Unit Equivalence 
      [32m✔[39m All 4 units in [32munits[39m sheet are also defined in [32msubunits[39m.
      
      ── Check: Subunit Equivalence 
      [32m✔[39m All 6 subunits in [32msubunits[39m sheet are also defined in [32mvalues[39m.
      
      ── Check: Unit Recoding 
      [36mℹ[39m Units with only one subunit: 3
      [36mℹ[39m Units with more than one subunit: 1 (`I03`)
      [32m✔[39m All units with more than one subunit are defined in [32munitRecodings[39m sheet.
    Output
      [1] FALSE

---

    Code
      checkInputList(prepList)
    Message
      [31m✖[39m Sheet [32munits[39m does not contain all expected columns.
      → Expected: `unit`, `unitType`, and `unitAggregateRule`
      → Found:    `unit` and `unitType`
      → Missing:  `unitAggregateRule`
      [31m✖[39m Sheet [32mvalues[39m does not contain all expected columns.
      → Expected: `subunit`, `value`, `valueRecode`, and `valueType`
      → Found:    `subunit` and `value`
      → Missing:  `valueRecode` and `valueType`
      → No checks for value recoding and value types available.
      
      ── Check: Unit Equivalence 
      [32m✔[39m All 4 units in [32munits[39m sheet are also defined in [32msubunits[39m.
      
      ── Check: Subunit Equivalence 
      [32m✔[39m All 6 subunits in [32msubunits[39m sheet are also defined in [32mvalues[39m.
      
      ── Check: Unit Recoding 
      [36mℹ[39m Units with only one subunit: 3
      [36mℹ[39m Units with more than one subunit: 1 (`I03`)
      [32m✔[39m All units with more than one subunit are defined in [32munitRecodings[39m sheet.
    Output
      [1] FALSE

---

    Code
      checkInputList(prepList)
    Message
      [31m✖[39m Sheet [32munits[39m does not contain all expected columns.
      → Expected: `unit`, `unitType`, and `unitAggregateRule`
      → Found:    `unit` and `unitType`
      → Missing:  `unitAggregateRule`
      [31m✖[39m Sheet [32mvalues[39m does not contain all expected columns.
      → Expected: `subunit`, `value`, `valueRecode`, and `valueType`
      → Found:    `subunit`
      → Missing:  `value`, `valueRecode`, and `valueType`
      → No checks for value recoding and value types available.
      
      ── Check: Unit Equivalence 
      [32m✔[39m All 4 units in [32munits[39m sheet are also defined in [32msubunits[39m.
      
      ── Check: Subunit Equivalence 
      [32m✔[39m All 6 subunits in [32msubunits[39m sheet are also defined in [32mvalues[39m.
      
      ── Check: Unit Recoding 
      [36mℹ[39m Units with only one subunit: 3
      [36mℹ[39m Units with more than one subunit: 1 (`I03`)
      [32m✔[39m All units with more than one subunit are defined in [32munitRecodings[39m sheet.
    Output
      [1] FALSE

---

    Code
      checkInputList(prepList)
    Message
      [31m✖[39m Sheet [32munits[39m does not contain all expected columns.
      → Expected: `unit`, `unitType`, and `unitAggregateRule`
      → Found:    `unitType` and `unitAggregateRule`
      → Missing:  `unit`
      → No checks for unit equivalence available.
      
      ── Check: Value Recoding 
      [32m✔[39m Missing types `mnr`, `mbd`, `mir`, and `mbi` are defined for all items in
      [32mvalueRecode[39m.
      [36mℹ[39m [32mvalue[39m contains the following values over all items: `0`, `1`, `2`, `3`, `4`,
      `6`, `7`, `8`, and `9`
      [32m✔[39m [32mvalueRecode[39m contains only 0, 1, and the mistypes: `0`, `1`, `mbd`, `mbi`,
      `mir`, and `mnr`
      
      ── Check: Value Types 
      [32m✔[39m No other values than `vc` and the mistypes in [32mvalueType[39m.
      
      ── Check: Subunit Equivalence 
      [32m✔[39m All 6 subunits in [32msubunits[39m sheet are also defined in [32mvalues[39m.
      
      ── Check: Unit Recoding 
      [36mℹ[39m Units with only one subunit: 3
      [36mℹ[39m Units with more than one subunit: 1 (`I03`)
      [32m✔[39m All units with more than one subunit are defined in [32munitRecodings[39m sheet.
    Output
      [1] FALSE

---

    Code
      checkInputList(prepList)
    Message
      [31m✖[39m Sheet [32munits[39m does not contain all expected columns.
      → Expected: `unit`, `unitType`, and `unitAggregateRule`
      → Found:    `unitType` and `unitAggregateRule`
      → Missing:  `unit`
      → No checks for unit equivalence available.
      [31m✖[39m Sheet [32msubunits[39m does not contain all expected columns.
      → Expected: `unit`, `subunit`, and `subunitRecoded`
      → Found:    `unit` and `subunitRecoded`
      → Missing:  `subunit`
      → No checks for subunit equivalence available.
      
      ── Check: Value Recoding 
      [32m✔[39m Missing types `mnr`, `mbd`, `mir`, and `mbi` are defined for all items in
      [32mvalueRecode[39m.
      [36mℹ[39m [32mvalue[39m contains the following values over all items: `0`, `1`, `2`, `3`, `4`,
      `6`, `7`, `8`, and `9`
      [32m✔[39m [32mvalueRecode[39m contains only 0, 1, and the mistypes: `0`, `1`, `mbd`, `mbi`,
      `mir`, and `mnr`
      
      ── Check: Value Types 
      [32m✔[39m No other values than `vc` and the mistypes in [32mvalueType[39m.
    Output
      [1] FALSE

# checks for missing correct and false codes per unit [plain]

    Code
      checkInputList(prepList)
    Message
      
      -- Check: Value Recoding 
      x Not all items in values sheet contain at least one correct score in
      valueRecode: `I01`
      v Missing types `mnr`, `mbd`, `mir`, and `mbi` are defined for all items in
      valueRecode.
      i value contains the following values over all items: `0`, `1`, `2`, `3`, `4`,
      `6`, `7`, `8`, and `9`
      v valueRecode contains only 0, 1, and the mistypes: `0`, `1`, `mbd`, `mbi`,
      `mir`, and `mnr`
      
      -- Check: Value Types 
      v No other values than `vc` and the mistypes in valueType.
      
      -- Check: Unit Equivalence 
      v All 4 units in units sheet are also defined in subunits.
      
      -- Check: Subunit Equivalence 
      v All 6 subunits in subunits sheet are also defined in values.
      
      -- Check: Unit Recoding 
      i Units with only one subunit: 3
      i Units with more than one subunit: 1 (`I03`)
      v All units with more than one subunit are defined in unitRecodings sheet.
    Output
      [1] FALSE

---

    Code
      checkInputList(prepList)
    Message
      
      -- Check: Value Recoding 
      x Not all items in values sheet contain at least one 'false' score in
      valueRecode: `I01`
      v Missing types `mnr`, `mbd`, `mir`, and `mbi` are defined for all items in
      valueRecode.
      i value contains the following values over all items: `0`, `1`, `2`, `3`, `4`,
      `6`, `7`, `8`, and `9`
      v valueRecode contains only 0, 1, and the mistypes: `0`, `1`, `mbd`, `mbi`,
      `mir`, and `mnr`
      
      -- Check: Value Types 
      v No other values than `vc` and the mistypes in valueType.
      
      -- Check: Unit Equivalence 
      v All 4 units in units sheet are also defined in subunits.
      
      -- Check: Subunit Equivalence 
      v All 6 subunits in subunits sheet are also defined in values.
      
      -- Check: Unit Recoding 
      i Units with only one subunit: 3
      i Units with more than one subunit: 1 (`I03`)
      v All units with more than one subunit are defined in unitRecodings sheet.
    Output
      [1] FALSE

# checks for missing correct and false codes per unit [ansi]

    Code
      checkInputList(prepList)
    Message
      
      -- Check: Value Recoding 
      [31mx[39m Not all items in [32mvalues[39m sheet contain at least one correct score in
      [32mvalueRecode[39m: `I01`
      [32mv[39m Missing types `mnr`, `mbd`, `mir`, and `mbi` are defined for all items in
      [32mvalueRecode[39m.
      [36mi[39m [32mvalue[39m contains the following values over all items: `0`, `1`, `2`, `3`, `4`,
      `6`, `7`, `8`, and `9`
      [32mv[39m [32mvalueRecode[39m contains only 0, 1, and the mistypes: `0`, `1`, `mbd`, `mbi`,
      `mir`, and `mnr`
      
      -- Check: Value Types 
      [32mv[39m No other values than `vc` and the mistypes in [32mvalueType[39m.
      
      -- Check: Unit Equivalence 
      [32mv[39m All 4 units in [32munits[39m sheet are also defined in [32msubunits[39m.
      
      -- Check: Subunit Equivalence 
      [32mv[39m All 6 subunits in [32msubunits[39m sheet are also defined in [32mvalues[39m.
      
      -- Check: Unit Recoding 
      [36mi[39m Units with only one subunit: 3
      [36mi[39m Units with more than one subunit: 1 (`I03`)
      [32mv[39m All units with more than one subunit are defined in [32munitRecodings[39m sheet.
    Output
      [1] FALSE

---

    Code
      checkInputList(prepList)
    Message
      
      -- Check: Value Recoding 
      [31mx[39m Not all items in [32mvalues[39m sheet contain at least one 'false' score in
      [32mvalueRecode[39m: `I01`
      [32mv[39m Missing types `mnr`, `mbd`, `mir`, and `mbi` are defined for all items in
      [32mvalueRecode[39m.
      [36mi[39m [32mvalue[39m contains the following values over all items: `0`, `1`, `2`, `3`, `4`,
      `6`, `7`, `8`, and `9`
      [32mv[39m [32mvalueRecode[39m contains only 0, 1, and the mistypes: `0`, `1`, `mbd`, `mbi`,
      `mir`, and `mnr`
      
      -- Check: Value Types 
      [32mv[39m No other values than `vc` and the mistypes in [32mvalueType[39m.
      
      -- Check: Unit Equivalence 
      [32mv[39m All 4 units in [32munits[39m sheet are also defined in [32msubunits[39m.
      
      -- Check: Subunit Equivalence 
      [32mv[39m All 6 subunits in [32msubunits[39m sheet are also defined in [32mvalues[39m.
      
      -- Check: Unit Recoding 
      [36mi[39m Units with only one subunit: 3
      [36mi[39m Units with more than one subunit: 1 (`I03`)
      [32mv[39m All units with more than one subunit are defined in [32munitRecodings[39m sheet.
    Output
      [1] FALSE

# checks for missing correct and false codes per unit [unicode]

    Code
      checkInputList(prepList)
    Message
      
      ── Check: Value Recoding 
      ✖ Not all items in values sheet contain at least one correct score in
      valueRecode: `I01`
      ✔ Missing types `mnr`, `mbd`, `mir`, and `mbi` are defined for all items in
      valueRecode.
      ℹ value contains the following values over all items: `0`, `1`, `2`, `3`, `4`,
      `6`, `7`, `8`, and `9`
      ✔ valueRecode contains only 0, 1, and the mistypes: `0`, `1`, `mbd`, `mbi`,
      `mir`, and `mnr`
      
      ── Check: Value Types 
      ✔ No other values than `vc` and the mistypes in valueType.
      
      ── Check: Unit Equivalence 
      ✔ All 4 units in units sheet are also defined in subunits.
      
      ── Check: Subunit Equivalence 
      ✔ All 6 subunits in subunits sheet are also defined in values.
      
      ── Check: Unit Recoding 
      ℹ Units with only one subunit: 3
      ℹ Units with more than one subunit: 1 (`I03`)
      ✔ All units with more than one subunit are defined in unitRecodings sheet.
    Output
      [1] FALSE

---

    Code
      checkInputList(prepList)
    Message
      
      ── Check: Value Recoding 
      ✖ Not all items in values sheet contain at least one 'false' score in
      valueRecode: `I01`
      ✔ Missing types `mnr`, `mbd`, `mir`, and `mbi` are defined for all items in
      valueRecode.
      ℹ value contains the following values over all items: `0`, `1`, `2`, `3`, `4`,
      `6`, `7`, `8`, and `9`
      ✔ valueRecode contains only 0, 1, and the mistypes: `0`, `1`, `mbd`, `mbi`,
      `mir`, and `mnr`
      
      ── Check: Value Types 
      ✔ No other values than `vc` and the mistypes in valueType.
      
      ── Check: Unit Equivalence 
      ✔ All 4 units in units sheet are also defined in subunits.
      
      ── Check: Subunit Equivalence 
      ✔ All 6 subunits in subunits sheet are also defined in values.
      
      ── Check: Unit Recoding 
      ℹ Units with only one subunit: 3
      ℹ Units with more than one subunit: 1 (`I03`)
      ✔ All units with more than one subunit are defined in unitRecodings sheet.
    Output
      [1] FALSE

# checks for missing correct and false codes per unit [fancy]

    Code
      checkInputList(prepList)
    Message
      
      ── Check: Value Recoding 
      [31m✖[39m Not all items in [32mvalues[39m sheet contain at least one correct score in
      [32mvalueRecode[39m: `I01`
      [32m✔[39m Missing types `mnr`, `mbd`, `mir`, and `mbi` are defined for all items in
      [32mvalueRecode[39m.
      [36mℹ[39m [32mvalue[39m contains the following values over all items: `0`, `1`, `2`, `3`, `4`,
      `6`, `7`, `8`, and `9`
      [32m✔[39m [32mvalueRecode[39m contains only 0, 1, and the mistypes: `0`, `1`, `mbd`, `mbi`,
      `mir`, and `mnr`
      
      ── Check: Value Types 
      [32m✔[39m No other values than `vc` and the mistypes in [32mvalueType[39m.
      
      ── Check: Unit Equivalence 
      [32m✔[39m All 4 units in [32munits[39m sheet are also defined in [32msubunits[39m.
      
      ── Check: Subunit Equivalence 
      [32m✔[39m All 6 subunits in [32msubunits[39m sheet are also defined in [32mvalues[39m.
      
      ── Check: Unit Recoding 
      [36mℹ[39m Units with only one subunit: 3
      [36mℹ[39m Units with more than one subunit: 1 (`I03`)
      [32m✔[39m All units with more than one subunit are defined in [32munitRecodings[39m sheet.
    Output
      [1] FALSE

---

    Code
      checkInputList(prepList)
    Message
      
      ── Check: Value Recoding 
      [31m✖[39m Not all items in [32mvalues[39m sheet contain at least one 'false' score in
      [32mvalueRecode[39m: `I01`
      [32m✔[39m Missing types `mnr`, `mbd`, `mir`, and `mbi` are defined for all items in
      [32mvalueRecode[39m.
      [36mℹ[39m [32mvalue[39m contains the following values over all items: `0`, `1`, `2`, `3`, `4`,
      `6`, `7`, `8`, and `9`
      [32m✔[39m [32mvalueRecode[39m contains only 0, 1, and the mistypes: `0`, `1`, `mbd`, `mbi`,
      `mir`, and `mnr`
      
      ── Check: Value Types 
      [32m✔[39m No other values than `vc` and the mistypes in [32mvalueType[39m.
      
      ── Check: Unit Equivalence 
      [32m✔[39m All 4 units in [32munits[39m sheet are also defined in [32msubunits[39m.
      
      ── Check: Subunit Equivalence 
      [32m✔[39m All 6 subunits in [32msubunits[39m sheet are also defined in [32mvalues[39m.
      
      ── Check: Unit Recoding 
      [36mℹ[39m Units with only one subunit: 3
      [36mℹ[39m Units with more than one subunit: 1 (`I03`)
      [32m✔[39m All units with more than one subunit are defined in [32munitRecodings[39m sheet.
    Output
      [1] FALSE

# checks for missing mistype codes per unit

    Code
      checkInputList(prepList)
    Message
      
      -- Check: Value Recoding 
      v Missing types `mbi` is defined for all items in valueRecode.
      x Missing type `mnr` is not defined as valueRecode for items: `I01` and `I02`.
      x Missing type `mbd` is not defined as valueRecode for items: `I02`.
      x Missing type `mir` is not defined as valueRecode for items: `I02`.
      i value contains the following values over all items: `0`, `1`, `2`, `3`, `4`,
      `6`, `7`, `8`, and `9`
      v valueRecode contains only 0, 1, and the mistypes: `0`, `1`, `mbd`, `mbi`,
      `mir`, and `mnr`
      
      -- Check: Value Types 
      v No other values than `vc` and the mistypes in valueType.
      
      -- Check: Unit Equivalence 
      v All 4 units in units sheet are also defined in subunits.
      
      -- Check: Subunit Equivalence 
      v All 6 subunits in subunits sheet are also defined in values.
      
      -- Check: Unit Recoding 
      i Units with only one subunit: 3
      i Units with more than one subunit: 1 (`I03`)
      v All units with more than one subunit are defined in unitRecodings sheet.
    Output
      [1] FALSE

# checks for valueRecodes other than 0, 1, and the mistypes

    Code
      checkInputList(prepList)
    Message
      
      -- Check: Value Recoding 
      v Missing type `mnr`, `mir`, and `mbi` are defined for all items in
      valueRecode.
      x Missing type `mbd` is not defined as valueRecode for items: `I01`.
      i value contains the following values over all items: `0`, `1`, `2`, `3`, `4`,
      `6`, `7`, `8`, and `9`
      x valueRecode contains other values than 0, 1, and the mistypes.
      > It contains 1 other value: `2`
      
      -- Check: Value Types 
      v No other values than `vc` and the mistypes in valueType.
      
      -- Check: Unit Equivalence 
      v All 4 units in units sheet are also defined in subunits.
      
      -- Check: Subunit Equivalence 
      v All 6 subunits in subunits sheet are also defined in values.
      
      -- Check: Unit Recoding 
      i Units with only one subunit: 3
      i Units with more than one subunit: 1 (`I03`)
      v All units with more than one subunit are defined in unitRecodings sheet.
    Output
      [1] TRUE

# identifies other value types than vc and mistypes

    Code
      checkInputList(prepList)
    Message
      
      -- Check: Value Recoding 
      v Missing types `mnr`, `mbd`, `mir`, and `mbi` are defined for all items in
      valueRecode.
      i value contains the following values over all items: `0`, `1`, `2`, `3`, `4`,
      `6`, `7`, `8`, and `9`
      v valueRecode contains only 0, 1, and the mistypes: `0`, `1`, `mbd`, `mbi`,
      `mir`, and `mnr`
      
      -- Check: Value Types 
      x Unexpected value other than `vc` and the mistypes in valueType: `test`
      
      -- Check: Unit Equivalence 
      v All 4 units in units sheet are also defined in subunits.
      
      -- Check: Subunit Equivalence 
      v All 6 subunits in subunits sheet are also defined in values.
      
      -- Check: Unit Recoding 
      i Units with only one subunit: 3
      i Units with more than one subunit: 1 (`I03`)
      v All units with more than one subunit are defined in unitRecodings sheet.
    Output
      [1] FALSE

# checks for unit inequivalence

    Code
      checkInputList(prepList)
    Message
      
      -- Check: Value Recoding 
      v Missing types `mnr`, `mbd`, `mir`, and `mbi` are defined for all items in
      valueRecode.
      i value contains the following values over all items: `0`, `1`, `2`, `3`, `4`,
      `6`, `7`, `8`, and `9`
      v valueRecode contains only 0, 1, and the mistypes: `0`, `1`, `mbd`, `mbi`,
      `mir`, and `mnr`
      
      -- Check: Value Types 
      v No other values than `vc` and the mistypes in valueType.
      
      -- Check: Unit Equivalence 
      x More units in units sheet than in subunits sheet: `I99`
      x More units in subunits sheet than in units sheet: `I01`
      
      -- Check: Subunit Equivalence 
      v All 6 subunits in subunits sheet are also defined in values.
      
      -- Check: Unit Recoding 
      i Units with only one subunit: 3
      i Units with more than one subunit: 1 (`I03`)
      v All units with more than one subunit are defined in unitRecodings sheet.
    Output
      [1] FALSE

---

    Code
      checkInputList(prepList)
    Message
      
      -- Check: Value Recoding 
      v Missing types `mnr`, `mbd`, `mir`, and `mbi` are defined for all items in
      valueRecode.
      i value contains the following values over all items: `0`, `1`, `2`, `3`, `4`,
      `6`, `7`, `8`, and `9`
      v valueRecode contains only 0, 1, and the mistypes: `0`, `1`, `mbd`, `mbi`,
      `mir`, and `mnr`
      
      -- Check: Value Types 
      v No other values than `vc` and the mistypes in valueType.
      
      -- Check: Unit Equivalence 
      x More units in units sheet than in subunits sheet: `I01`
      x More units in subunits sheet than in units sheet: `I77`
      
      -- Check: Subunit Equivalence 
      v All 6 subunits in subunits sheet are also defined in values.
      
      -- Check: Unit Recoding 
      i Units with only one subunit: 3
      i Units with more than one subunit: 1 (`I03`)
      v All units with more than one subunit are defined in unitRecodings sheet.
    Output
      [1] FALSE

# checks for subunit inequivalence

    Code
      checkInputList(prepList)
    Message
      
      -- Check: Value Recoding 
      v Missing types `mnr`, `mbd`, `mir`, and `mbi` are defined for all items in
      valueRecode.
      i value contains the following values over all items: `0`, `1`, `2`, `3`, `4`,
      `6`, `7`, `8`, and `9`
      v valueRecode contains only 0, 1, and the mistypes: `0`, `1`, `mbd`, `mbi`,
      `mir`, and `mnr`
      
      -- Check: Value Types 
      v No other values than `vc` and the mistypes in valueType.
      
      -- Check: Unit Equivalence 
      v All 4 units in units sheet are also defined in subunits.
      
      -- Check: Subunit Equivalence 
      x More subunits in subunits sheet than in values sheet: `I03d`
      
      -- Check: Unit Recoding 
      i Units with only one subunit: 3
      i Units with more than one subunit: 1 (`I03`)
      v All units with more than one subunit are defined in unitRecodings sheet.
    Output
      [1] FALSE

---

    Code
      checkInputList(prepList)
    Message
      
      -- Check: Value Recoding 
      v Missing types `mnr`, `mbd`, `mir`, and `mbi` are defined for all items in
      valueRecode.
      i value contains the following values over all items: `0`, `1`, `2`, `3`, `4`,
      `6`, `7`, `8`, and `9`
      v valueRecode contains only 0, 1, and the mistypes: `0`, `1`, `mbd`, `mbi`,
      `mir`, and `mnr`
      
      -- Check: Value Types 
      v No other values than `vc` and the mistypes in valueType.
      
      -- Check: Unit Equivalence 
      v All 4 units in units sheet are also defined in subunits.
      
      -- Check: Subunit Equivalence 
      x More subunits in values sheet than in subunits sheet: `I03a`
      x More subunits in subunits sheet than in values sheet: `I03z`
      
      -- Check: Unit Recoding 
      i Units with only one subunit: 3
      i Units with more than one subunit: 1 (`I03`)
      v All units with more than one subunit are defined in unitRecodings sheet.
    Output
      [1] FALSE

---

    Code
      checkInputList(prepList)
    Message
      
      -- Check: Value Recoding 
      v Missing types `mnr`, `mbd`, `mir`, and `mbi` are defined for all items in
      valueRecode.
      i value contains the following values over all items: `0`, `1`, `2`, `3`, `4`,
      `6`, `7`, `8`, and `9`
      v valueRecode contains only 0, 1, and the mistypes: `0`, `1`, `mbd`, `mbi`,
      `mir`, and `mnr`
      
      -- Check: Value Types 
      v No other values than `vc` and the mistypes in valueType.
      
      -- Check: Unit Equivalence 
      v All 4 units in units sheet are also defined in subunits.
      
      -- Check: Subunit Equivalence 
      x More subunits in values sheet than in subunits sheet: `I03d`
      
      -- Check: Unit Recoding 
      i Units with only one subunit: 3
      i Units with more than one subunit: 1 (`I03`)
      v All units with more than one subunit are defined in unitRecodings sheet.
    Output
      [1] FALSE

---

    Code
      checkInputList(prepList)
    Message
      
      -- Check: Value Recoding 
      v Missing types `mnr`, `mbd`, `mir`, and `mbi` are defined for all items in
      valueRecode.
      i value contains the following values over all items: `0`, `1`, `2`, `3`, `4`,
      `6`, `7`, `8`, and `9`
      v valueRecode contains only 0, 1, and the mistypes: `0`, `1`, `mbd`, `mbi`,
      `mir`, and `mnr`
      
      -- Check: Value Types 
      v No other values than `vc` and the mistypes in valueType.
      
      -- Check: Unit Equivalence 
      v All 4 units in units sheet are also defined in subunits.
      
      -- Check: Subunit Equivalence 
      x More subunits in values sheet than in subunits sheet: `I03x`
      x More subunits in subunits sheet than in values sheet: `I03a`
      
      -- Check: Unit Recoding 
      i Units with only one subunit: 3
      i Units with more than one subunit: 1 (`I03`)
      v All units with more than one subunit are defined in unitRecodings sheet.
    Output
      [1] FALSE

# identifies problems with unit recodings

    Code
      checkInputList(prepList)
    Message
      
      -- Check: Value Recoding 
      v Missing types `mnr`, `mbd`, `mir`, and `mbi` are defined for all items in
      valueRecode.
      i value contains the following values over all items: `0`, `1`, `2`, `3`, `4`,
      `6`, `7`, `8`, and `9`
      v valueRecode contains only 0, 1, and the mistypes: `0`, `1`, `mbd`, `mbi`,
      `mir`, and `mnr`
      
      -- Check: Value Types 
      v No other values than `vc` and the mistypes in valueType.
      
      -- Check: Unit Equivalence 
      x More units in subunits sheet than in units sheet: `I05`
      
      -- Check: Subunit Equivalence 
      x More subunits in subunits sheet than in values sheet: `I05a`, `I05b`, and
      `I05c`
      
      -- Check: Unit Recoding 
      i Units with only one subunit: 3
      i Units with more than one subunit: 2 (`I03` and `I05`)
      x Not all units with more than one subunit are defined in unitRecodings sheet:
      `I05`
    Output
      [1] FALSE

# check mbo compatibility when correctly specifying mistypes

    Code
      checkInputList(iL2)
    Message
      
      -- Checking sheets 
      
      -- Check: Value Recoding 
      v Missing types `mir` is defined for all items in valueRecode.
      x Missing type `mnr` is not defined as valueRecode for items: `I14`.
      x Missing type `mbd` is not defined as valueRecode for items: `I14`.
      x Missing type `mbi` is not defined as valueRecode for items: `I01`, `I02`,
      `I03`, `I04`, `I05`, `I06`, `I07`, `I08`, `I09`, `I10`, `I11`, `I12a`, `I12b`,
      `I12c`, `I13`, `I14`, `I15`, `I16`, `I17`, `I18`, `I19`, `I20`, `I21`, `I22`,
      `I23`, `I24`, `I25`, `I26`, `I27`, and `I28`.
      i value contains the following values over all items: `0`, `1`, `2`, `3`, `4`,
      `5`, `6`, `7`, `8`, and `9`
      x valueRecode contains other values than 0, 1, and the mistypes.
      > It contains 1 other value: `mbo`
      
      -- Check: Value Types 
      x Unexpected value other than `vc` and the mistypes in valueType: `mbo`
      
      -- Check: Unit Equivalence 
      v All 28 units in units sheet are also defined in subunits.
      
      -- Check: Subunit Equivalence 
      v All 30 subunits in subunits sheet are also defined in values.
      
      -- Check: Unit Recoding 
      i Units with only one subunit: 27
      i Units with more than one subunit: 1 (`I12`)
      v All units with more than one subunit are defined in unitRecodings sheet.
    Output
      [1] FALSE

# check mbo compatibility when not correctly specifying mistypes

    Code
      checkInputList(iL2)
    Message
      
      -- Checking sheets 
      
      -- Check: Value Recoding 
      v Missing types `mir` is defined for all items in valueRecode.
      x Missing type `mnr` is not defined as valueRecode for items: `I14`.
      x Missing type `mbd` is not defined as valueRecode for items: `I14`.
      x Missing type `mbi` is not defined as valueRecode for items: `I01`, `I02`,
      `I03`, `I04`, `I05`, `I06`, `I07`, `I08`, `I09`, `I10`, `I11`, `I12a`, `I12b`,
      `I12c`, `I13`, `I14`, `I15`, `I16`, `I17`, `I18`, `I19`, `I20`, `I21`, `I22`,
      `I23`, `I24`, `I25`, `I26`, `I27`, and `I28`.
      i value contains the following values over all items: `0`, `1`, `2`, `3`, `4`,
      `5`, `6`, `7`, `8`, and `9`
      x valueRecode contains other values than 0, 1, and the mistypes.
      > It contains 1 other value: `mbo`
      
      -- Check: Value Types 
      x Unexpected value other than `vc` and the mistypes in valueType: `mbo`
      
      -- Check: Unit Equivalence 
      v All 28 units in units sheet are also defined in subunits.
      
      -- Check: Subunit Equivalence 
      v All 30 subunits in subunits sheet are also defined in values.
      
      -- Check: Unit Recoding 
      i Units with only one subunit: 27
      i Units with more than one subunit: 1 (`I12`)
      v All units with more than one subunit are defined in unitRecodings sheet.
    Output
      [1] FALSE

