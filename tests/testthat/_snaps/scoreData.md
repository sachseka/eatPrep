# returns no errors if everything is correct [plain]

    Code
      scoreDataTest(testScore)
    Message <cliMessage>
      v 2 units were scored: `I02` and `I03`.
    Output
               ID I01 I02 I03 I04
      1 person100   0   0   0   0
      2 person101   1   0   0   1
      3 person102   1   0   0   0
      4 person103 mbi   1   1   1
      5 person104 mir mbd mbd mbi
      6 person105 mbd mir mbd mbd

# returns no errors if everything is correct [ansi]

    Code
      scoreDataTest(testScore)
    Message <cliMessage>
      [32mv[39m 2 units were scored: `I02` and `I03`.
    Output
               ID I01 I02 I03 I04
      1 person100   0   0   0   0
      2 person101   1   0   0   1
      3 person102   1   0   0   0
      4 person103 mbi   1   1   1
      5 person104 mir mbd mbd mbi
      6 person105 mbd mir mbd mbd

# returns no errors if everything is correct [unicode]

    Code
      scoreDataTest(testScore)
    Message <cliMessage>
      ✔ 2 units were scored: `I02` and `I03`.
    Output
               ID I01 I02 I03 I04
      1 person100   0   0   0   0
      2 person101   1   0   0   1
      3 person102   1   0   0   0
      4 person103 mbi   1   1   1
      5 person104 mir mbd mbd mbi
      6 person105 mbd mir mbd mbd

# returns no errors if everything is correct [fancy]

    Code
      scoreDataTest(testScore)
    Message <cliMessage>
      [32m✔[39m 2 units were scored: `I02` and `I03`.
    Output
               ID I01 I02 I03 I04
      1 person100   0   0   0   0
      2 person101   1   0   0   1
      3 person102   1   0   0   0
      4 person103 mbi   1   1   1
      5 person104 mir mbd mbd mbi
      6 person105 mbd mir mbd mbd

# checks for data.frame [plain]

    Code
      scoreDataTest(testScore)
    Error <rlang_error>
      dat must be a `data.frame`.

# checks for data.frame [ansi]

    Code
      scoreDataTest(testScore)
    Error <rlang_error>
      [1m[22m[32mdat[39m must be a `data.frame`.

# checks for data.frame [unicode]

    Code
      scoreDataTest(testScore)
    Error <rlang_error>
      dat must be a `data.frame`.

# checks for data.frame [fancy]

    Code
      scoreDataTest(testScore)
    Error <rlang_error>
      [1m[22m[32mdat[39m must be a `data.frame`.

# throws no error if there are less items to score in the data.frame [plain]

    Code
      scoreDataTest(testScore)
    Message <cliMessage>
      v 2 units were scored: `I02` and `I03`.
    Output
               ID I01 I03 I04
      1 person100   0   0   0
      2 person101   1   0   1
      3 person102   1   0   0
      4 person103 mbi   1   1
      5 person104 mir mbd mbi
      6 person105 mbd mbd mbd

# throws no error if there are less items to score in the data.frame [ansi]

    Code
      scoreDataTest(testScore)
    Message <cliMessage>
      [32mv[39m 2 units were scored: `I02` and `I03`.
    Output
               ID I01 I03 I04
      1 person100   0   0   0
      2 person101   1   0   1
      3 person102   1   0   0
      4 person103 mbi   1   1
      5 person104 mir mbd mbi
      6 person105 mbd mbd mbd

# throws no error if there are less items to score in the data.frame [unicode]

    Code
      scoreDataTest(testScore)
    Message <cliMessage>
      ✔ 2 units were scored: `I02` and `I03`.
    Output
               ID I01 I03 I04
      1 person100   0   0   0
      2 person101   1   0   1
      3 person102   1   0   0
      4 person103 mbi   1   1
      5 person104 mir mbd mbi
      6 person105 mbd mbd mbd

# throws no error if there are less items to score in the data.frame [fancy]

    Code
      scoreDataTest(testScore)
    Message <cliMessage>
      [32m✔[39m 2 units were scored: `I02` and `I03`.
    Output
               ID I01 I03 I04
      1 person100   0   0   0
      2 person101   1   0   1
      3 person102   1   0   0
      4 person103 mbi   1   1
      5 person104 mir mbd mbi
      6 person105 mbd mbd mbd

# throws an error if there are less items to score in the unitrecodings [plain]

    Code
      scoreDataTest(testScore, unitrecodings = falseUnitRecodings)
    Message <cliMessage>
      ! Found no scoring information for 1 variable: `I02`. This variable will not be
      scored.
      v 1 unit was scored: `I03`.
    Output
               ID I01 I02 I03 I04
      1 person100   0   0   0   0
      2 person101   1   1   0   1
      3 person102   1   2   0   0
      4 person103 mbi   3   1   1
      5 person104 mir mbd mbd mbi
      6 person105 mbd mir mbd mbd

# throws an error if there are less items to score in the unitrecodings [ansi]

    Code
      scoreDataTest(testScore, unitrecodings = falseUnitRecodings)
    Message <cliMessage>
      [33m![39m Found no scoring information for 1 variable: `I02`. This variable will not be
      scored.
      [32mv[39m 1 unit was scored: `I03`.
    Output
               ID I01 I02 I03 I04
      1 person100   0   0   0   0
      2 person101   1   1   0   1
      3 person102   1   2   0   0
      4 person103 mbi   3   1   1
      5 person104 mir mbd mbd mbi
      6 person105 mbd mir mbd mbd

# throws an error if there are less items to score in the unitrecodings [unicode]

    Code
      scoreDataTest(testScore, unitrecodings = falseUnitRecodings)
    Message <cliMessage>
      ! Found no scoring information for 1 variable: `I02`. This variable will not be
      scored.
      ✔ 1 unit was scored: `I03`.
    Output
               ID I01 I02 I03 I04
      1 person100   0   0   0   0
      2 person101   1   1   0   1
      3 person102   1   2   0   0
      4 person103 mbi   3   1   1
      5 person104 mir mbd mbd mbi
      6 person105 mbd mir mbd mbd

# throws an error if there are less items to score in the unitrecodings [fancy]

    Code
      scoreDataTest(testScore, unitrecodings = falseUnitRecodings)
    Message <cliMessage>
      [33m![39m Found no scoring information for 1 variable: `I02`. This variable will not be
      scored.
      [32m✔[39m 1 unit was scored: `I03`.
    Output
               ID I01 I02 I03 I04
      1 person100   0   0   0   0
      2 person101   1   1   0   1
      3 person102   1   2   0   0
      4 person103 mbi   3   1   1
      5 person104 mir mbd mbd mbi
      6 person105 mbd mir mbd mbd

# throws an error if there are less items to score in the units [plain]

    Code
      scoreDataTest(testScore, units = falseUnits)
    Message <cliMessage>
      v 2 units were scored: `I02` and `I03`.
    Output
               ID I01 I02 I03 I04
      1 person100   0   0   0   0
      2 person101   1   1   0   1
      3 person102   1   2   0   0
      4 person103 mbi   3   1   1
      5 person104 mir mbd mbd mbi
      6 person105 mbd mir mbd mbd

# throws an error if there are less items to score in the units [ansi]

    Code
      scoreDataTest(testScore, units = falseUnits)
    Message <cliMessage>
      [32mv[39m 2 units were scored: `I02` and `I03`.
    Output
               ID I01 I02 I03 I04
      1 person100   0   0   0   0
      2 person101   1   1   0   1
      3 person102   1   2   0   0
      4 person103 mbi   3   1   1
      5 person104 mir mbd mbd mbi
      6 person105 mbd mir mbd mbd

# throws an error if there are less items to score in the units [unicode]

    Code
      scoreDataTest(testScore, units = falseUnits)
    Message <cliMessage>
      ✔ 2 units were scored: `I02` and `I03`.
    Output
               ID I01 I02 I03 I04
      1 person100   0   0   0   0
      2 person101   1   1   0   1
      3 person102   1   2   0   0
      4 person103 mbi   3   1   1
      5 person104 mir mbd mbd mbi
      6 person105 mbd mir mbd mbd

# throws an error if there are less items to score in the units [fancy]

    Code
      scoreDataTest(testScore, units = falseUnits)
    Message <cliMessage>
      [32m✔[39m 2 units were scored: `I02` and `I03`.
    Output
               ID I01 I02 I03 I04
      1 person100   0   0   0   0
      2 person101   1   1   0   1
      3 person102   1   2   0   0
      4 person103 mbi   3   1   1
      5 person104 mir mbd mbd mbi
      6 person105 mbd mir mbd mbd

# throws an error if the item codes items to score in the unitrecodings [plain]

    Code
      scoreDataTest(testScore, subunits = falseSubunits)
    Message <cliMessage>
      v 1 unit was scored: `I03`.
    Output
               ID I01 I02 I03 I04
      1 person100   0   0   0   0
      2 person101   1   0   0   1
      3 person102   1   0   0   0
      4 person103 mbi   1   1   1
      5 person104 mir mbd mbd mbi
      6 person105 mbd mir mbd mbd

# throws an error if the item codes items to score in the unitrecodings [ansi]

    Code
      scoreDataTest(testScore, subunits = falseSubunits)
    Message <cliMessage>
      [32mv[39m 1 unit was scored: `I03`.
    Output
               ID I01 I02 I03 I04
      1 person100   0   0   0   0
      2 person101   1   0   0   1
      3 person102   1   0   0   0
      4 person103 mbi   1   1   1
      5 person104 mir mbd mbd mbi
      6 person105 mbd mir mbd mbd

# throws an error if the item codes items to score in the unitrecodings [unicode]

    Code
      scoreDataTest(testScore, subunits = falseSubunits)
    Message <cliMessage>
      ✔ 1 unit was scored: `I03`.
    Output
               ID I01 I02 I03 I04
      1 person100   0   0   0   0
      2 person101   1   0   0   1
      3 person102   1   0   0   0
      4 person103 mbi   1   1   1
      5 person104 mir mbd mbd mbi
      6 person105 mbd mir mbd mbd

# throws an error if the item codes items to score in the unitrecodings [fancy]

    Code
      scoreDataTest(testScore, subunits = falseSubunits)
    Message <cliMessage>
      [32m✔[39m 1 unit was scored: `I03`.
    Output
               ID I01 I02 I03 I04
      1 person100   0   0   0   0
      2 person101   1   0   0   1
      3 person102   1   0   0   0
      4 person103 mbi   1   1   1
      5 person104 mir mbd mbd mbi
      6 person105 mbd mir mbd mbd

