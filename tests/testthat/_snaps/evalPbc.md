# evalPbc identifies non-problematic frequency and correlation pattern [plain]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi"))
    Message <cliMessage>
      v Excellent, no attractors (score 1) were chosen with a frequency of zero.
      v Excellent, no distractors (score 0) were chosen with a frequency of zero.

# evalPbc identifies non-problematic frequency and correlation pattern [ansi]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi"))
    Message <cliMessage>
      [32mv[39m Excellent, no attractors (score 1) were chosen with a frequency of zero.
      [32mv[39m Excellent, no distractors (score 0) were chosen with a frequency of zero.

# evalPbc identifies non-problematic frequency and correlation pattern [unicode]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi"))
    Message <cliMessage>
      ✔ Excellent, no attractors (score 1) were chosen with a frequency of zero.
      ✔ Excellent, no distractors (score 0) were chosen with a frequency of zero.

# evalPbc identifies non-problematic frequency and correlation pattern [fancy]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi"))
    Message <cliMessage>
      [32m✔[39m Excellent, no attractors (score 1) were chosen with a frequency of zero.
      [32m✔[39m Excellent, no distractors (score 0) were chosen with a frequency of zero.

# evalPbc identifies zero-frequencies for attractors and throws message [plain]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi"))
    Message <cliMessage>
      x The attractors (score 1) of the following 3 items were chosen with a
      frequency of zero: I1, I2, and I3. This should not happen. Please check.
      v Excellent, no distractors (score 0) were chosen with a frequency of zero.
      i For a list of problematic items, save the `output` of this function and
      return the item names as a vector:
      * output$lowFreqAtt

# evalPbc identifies zero-frequencies for attractors and throws message [ansi]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi"))
    Message <cliMessage>
      [31mx[39m The attractors (score 1) of the following 3 items were chosen with a
      frequency of zero: [32mI1[39m, [32mI2[39m, and [32mI3[39m. This should not happen. Please check.
      [32mv[39m Excellent, no distractors (score 0) were chosen with a frequency of zero.
      [36mi[39m For a list of problematic items, save the `output` of this function and
      return the item names as a vector:
      * output$lowFreqAtt

# evalPbc identifies zero-frequencies for attractors and throws message [unicode]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi"))
    Message <cliMessage>
      ✖ The attractors (score 1) of the following 3 items were chosen with a
      frequency of zero: I1, I2, and I3. This should not happen. Please check.
      ✔ Excellent, no distractors (score 0) were chosen with a frequency of zero.
      ℹ For a list of problematic items, save the `output` of this function and
      return the item names as a vector:
      • output$lowFreqAtt

# evalPbc identifies zero-frequencies for attractors and throws message [fancy]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi"))
    Message <cliMessage>
      [31m✖[39m The attractors (score 1) of the following 3 items were chosen with a
      frequency of zero: [32mI1[39m, [32mI2[39m, and [32mI3[39m. This should not happen. Please check.
      [32m✔[39m Excellent, no distractors (score 0) were chosen with a frequency of zero.
      [36mℹ[39m For a list of problematic items, save the `output` of this function and
      return the item names as a vector:
      • output$lowFreqAtt

# evalPbc identifies (unproblematic) zero-frequencies for distractors and throws message [plain]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi"))
    Message <cliMessage>
      v Excellent, no attractors (score 1) were chosen with a frequency of zero.
      ! The distractors (score 0) of the following 3 items were chosen with a
      frequency of zero: I1_1, I2_2, I3_1, I1_2, I2_1, and I3_2. This may happen, but
      is probably not intended.
      i For a list of problematic items, save the `output` of this function and
      return the item names as a vector:
      * output$highFreqDis

# evalPbc identifies (unproblematic) zero-frequencies for distractors and throws message [ansi]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi"))
    Message <cliMessage>
      [32mv[39m Excellent, no attractors (score 1) were chosen with a frequency of zero.
      [33m![39m The distractors (score 0) of the following 3 items were chosen with a
      frequency of zero: [32mI1_1[39m, [32mI2_2[39m, [32mI3_1[39m, [32mI1_2[39m, [32mI2_1[39m, and [32mI3_2[39m. This may happen, but
      is probably not intended.
      [36mi[39m For a list of problematic items, save the `output` of this function and
      return the item names as a vector:
      * output$highFreqDis

# evalPbc identifies (unproblematic) zero-frequencies for distractors and throws message [unicode]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi"))
    Message <cliMessage>
      ✔ Excellent, no attractors (score 1) were chosen with a frequency of zero.
      ! The distractors (score 0) of the following 3 items were chosen with a
      frequency of zero: I1_1, I2_2, I3_1, I1_2, I2_1, and I3_2. This may happen, but
      is probably not intended.
      ℹ For a list of problematic items, save the `output` of this function and
      return the item names as a vector:
      • output$highFreqDis

# evalPbc identifies (unproblematic) zero-frequencies for distractors and throws message [fancy]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi"))
    Message <cliMessage>
      [32m✔[39m Excellent, no attractors (score 1) were chosen with a frequency of zero.
      [33m![39m The distractors (score 0) of the following 3 items were chosen with a
      frequency of zero: [32mI1_1[39m, [32mI2_2[39m, [32mI3_1[39m, [32mI1_2[39m, [32mI2_1[39m, and [32mI3_2[39m. This may happen, but
      is probably not intended.
      [36mℹ[39m For a list of problematic items, save the `output` of this function and
      return the item names as a vector:
      • output$highFreqDis

# evalPbc identifies low correlations (< .05) for attractors per default [plain]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi"))
    Message <cliMessage>
      v Excellent, no attractors (score 1) were chosen with a frequency of zero.
      v Excellent, no distractors (score 0) were chosen with a frequency of zero.
      x catPbcs for attractors (score 1) of the following 1 item are worrisome low (< 0.05) or missing: I1:_0.05
      i For a list of problematic items, save the `output` of this function and
      return the item names as a vector:
      * output$lowMisPbcAtt

# evalPbc identifies low correlations (< .05) for attractors per default [ansi]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi"))
    Message <cliMessage>
      [32mv[39m Excellent, no attractors (score 1) were chosen with a frequency of zero.
      [32mv[39m Excellent, no distractors (score 0) were chosen with a frequency of zero.
      [31mx[39m catPbcs for attractors (score 1) of the following 1 item are worrisome low (< 0.05) or missing: [32m[32mI1:_0.05[32m[39m
      [36mi[39m For a list of problematic items, save the `output` of this function and
      return the item names as a vector:
      * output$lowMisPbcAtt

# evalPbc identifies low correlations (< .05) for attractors per default [unicode]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi"))
    Message <cliMessage>
      ✔ Excellent, no attractors (score 1) were chosen with a frequency of zero.
      ✔ Excellent, no distractors (score 0) were chosen with a frequency of zero.
      ✖ catPbcs for attractors (score 1) of the following 1 item are worrisome low (< 0.05) or missing: I1:_0.05
      ℹ For a list of problematic items, save the `output` of this function and
      return the item names as a vector:
      • output$lowMisPbcAtt

# evalPbc identifies low correlations (< .05) for attractors per default [fancy]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi"))
    Message <cliMessage>
      [32m✔[39m Excellent, no attractors (score 1) were chosen with a frequency of zero.
      [32m✔[39m Excellent, no distractors (score 0) were chosen with a frequency of zero.
      [31m✖[39m catPbcs for attractors (score 1) of the following 1 item are worrisome low (< 0.05) or missing: [32m[32mI1:_0.05[32m[39m
      [36mℹ[39m For a list of problematic items, save the `output` of this function and
      return the item names as a vector:
      • output$lowMisPbcAtt

# evalPbc accepts user-defined correlation cutoffs for attractors [plain]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi"))
    Message <cliMessage>
      v Excellent, no attractors (score 1) were chosen with a frequency of zero.
      v Excellent, no distractors (score 0) were chosen with a frequency of zero.
      x catPbcs for attractors (score 1) of the following 1 item are worrisome low (< 0.05) or missing: I1:_0.02
      i For a list of problematic items, save the `output` of this function and
      return the item names as a vector:
      * output$lowMisPbcAtt

# evalPbc accepts user-defined correlation cutoffs for attractors [ansi]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi"))
    Message <cliMessage>
      [32mv[39m Excellent, no attractors (score 1) were chosen with a frequency of zero.
      [32mv[39m Excellent, no distractors (score 0) were chosen with a frequency of zero.
      [31mx[39m catPbcs for attractors (score 1) of the following 1 item are worrisome low (< 0.05) or missing: [32m[32mI1:_0.02[32m[39m
      [36mi[39m For a list of problematic items, save the `output` of this function and
      return the item names as a vector:
      * output$lowMisPbcAtt

# evalPbc accepts user-defined correlation cutoffs for attractors [unicode]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi"))
    Message <cliMessage>
      ✔ Excellent, no attractors (score 1) were chosen with a frequency of zero.
      ✔ Excellent, no distractors (score 0) were chosen with a frequency of zero.
      ✖ catPbcs for attractors (score 1) of the following 1 item are worrisome low (< 0.05) or missing: I1:_0.02
      ℹ For a list of problematic items, save the `output` of this function and
      return the item names as a vector:
      • output$lowMisPbcAtt

# evalPbc accepts user-defined correlation cutoffs for attractors [fancy]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi"))
    Message <cliMessage>
      [32m✔[39m Excellent, no attractors (score 1) were chosen with a frequency of zero.
      [32m✔[39m Excellent, no distractors (score 0) were chosen with a frequency of zero.
      [31m✖[39m catPbcs for attractors (score 1) of the following 1 item are worrisome low (< 0.05) or missing: [32m[32mI1:_0.02[32m[39m
      [36mℹ[39m For a list of problematic items, save the `output` of this function and
      return the item names as a vector:
      • output$lowMisPbcAtt

# evalPbc identifies low user-defined correlations for attractors [plain]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi"), minPbcAtt = 0.1)
    Message <cliMessage>
      v Excellent, no attractors (score 1) were chosen with a frequency of zero.
      v Excellent, no distractors (score 0) were chosen with a frequency of zero.
      x catPbcs for attractors (score 1) of the following 1 item are worrisome low (< 0.1) or missing: I1:_0.09
      i For a list of problematic items, save the `output` of this function and
      return the item names as a vector:
      * output$lowMisPbcAtt

# evalPbc identifies low user-defined correlations for attractors [ansi]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi"), minPbcAtt = 0.1)
    Message <cliMessage>
      [32mv[39m Excellent, no attractors (score 1) were chosen with a frequency of zero.
      [32mv[39m Excellent, no distractors (score 0) were chosen with a frequency of zero.
      [31mx[39m catPbcs for attractors (score 1) of the following 1 item are worrisome low (< 0.1) or missing: [32m[32mI1:_0.09[32m[39m
      [36mi[39m For a list of problematic items, save the `output` of this function and
      return the item names as a vector:
      * output$lowMisPbcAtt

# evalPbc identifies low user-defined correlations for attractors [unicode]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi"), minPbcAtt = 0.1)
    Message <cliMessage>
      ✔ Excellent, no attractors (score 1) were chosen with a frequency of zero.
      ✔ Excellent, no distractors (score 0) were chosen with a frequency of zero.
      ✖ catPbcs for attractors (score 1) of the following 1 item are worrisome low (< 0.1) or missing: I1:_0.09
      ℹ For a list of problematic items, save the `output` of this function and
      return the item names as a vector:
      • output$lowMisPbcAtt

# evalPbc identifies low user-defined correlations for attractors [fancy]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi"), minPbcAtt = 0.1)
    Message <cliMessage>
      [32m✔[39m Excellent, no attractors (score 1) were chosen with a frequency of zero.
      [32m✔[39m Excellent, no distractors (score 0) were chosen with a frequency of zero.
      [31m✖[39m catPbcs for attractors (score 1) of the following 1 item are worrisome low (< 0.1) or missing: [32m[32mI1:_0.09[32m[39m
      [36mℹ[39m For a list of problematic items, save the `output` of this function and
      return the item names as a vector:
      • output$lowMisPbcAtt

# evalPbc identifies missing correlations for attractors [plain]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi"))
    Message <cliMessage>
      v Excellent, no attractors (score 1) were chosen with a frequency of zero.
      v Excellent, no distractors (score 0) were chosen with a frequency of zero.
      x catPbcs for attractors (score 1) of the following 1 item are worrisome low (< 0.05) or missing: I1:_NA
      i For a list of problematic items, save the `output` of this function and
      return the item names as a vector:
      * output$lowMisPbcAtt

# evalPbc identifies missing correlations for attractors [ansi]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi"))
    Message <cliMessage>
      [32mv[39m Excellent, no attractors (score 1) were chosen with a frequency of zero.
      [32mv[39m Excellent, no distractors (score 0) were chosen with a frequency of zero.
      [31mx[39m catPbcs for attractors (score 1) of the following 1 item are worrisome low (< 0.05) or missing: [32m[32mI1:_NA[32m[39m
      [36mi[39m For a list of problematic items, save the `output` of this function and
      return the item names as a vector:
      * output$lowMisPbcAtt

# evalPbc identifies missing correlations for attractors [unicode]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi"))
    Message <cliMessage>
      ✔ Excellent, no attractors (score 1) were chosen with a frequency of zero.
      ✔ Excellent, no distractors (score 0) were chosen with a frequency of zero.
      ✖ catPbcs for attractors (score 1) of the following 1 item are worrisome low (< 0.05) or missing: I1:_NA
      ℹ For a list of problematic items, save the `output` of this function and
      return the item names as a vector:
      • output$lowMisPbcAtt

# evalPbc identifies missing correlations for attractors [fancy]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi"))
    Message <cliMessage>
      [32m✔[39m Excellent, no attractors (score 1) were chosen with a frequency of zero.
      [32m✔[39m Excellent, no distractors (score 0) were chosen with a frequency of zero.
      [31m✖[39m catPbcs for attractors (score 1) of the following 1 item are worrisome low (< 0.05) or missing: [32m[32mI1:_NA[32m[39m
      [36mℹ[39m For a list of problematic items, save the `output` of this function and
      return the item names as a vector:
      • output$lowMisPbcAtt

# evalPbc identifies too high correlations (> .005) for distractors per default [plain]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi"))
    Message <cliMessage>
      v Excellent, no attractors (score 1) were chosen with a frequency of zero.
      v Excellent, no distractors (score 0) were chosen with a frequency of zero.
      x catPbcs for distractors (score 0) of the following 1 item are unexpectedly high (> 0.005): I1_1_0.01
      i For a list of problematic items, save the `output` of this function and
      return the item names as a vector:
      * output$highPbcDis

# evalPbc identifies too high correlations (> .005) for distractors per default [ansi]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi"))
    Message <cliMessage>
      [32mv[39m Excellent, no attractors (score 1) were chosen with a frequency of zero.
      [32mv[39m Excellent, no distractors (score 0) were chosen with a frequency of zero.
      [31mx[39m catPbcs for distractors (score 0) of the following 1 item are unexpectedly high (> 0.005): [32m[32mI1_1_0.01[32m[39m
      [36mi[39m For a list of problematic items, save the `output` of this function and
      return the item names as a vector:
      * output$highPbcDis

# evalPbc identifies too high correlations (> .005) for distractors per default [unicode]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi"))
    Message <cliMessage>
      ✔ Excellent, no attractors (score 1) were chosen with a frequency of zero.
      ✔ Excellent, no distractors (score 0) were chosen with a frequency of zero.
      ✖ catPbcs for distractors (score 0) of the following 1 item are unexpectedly high (> 0.005): I1_1_0.01
      ℹ For a list of problematic items, save the `output` of this function and
      return the item names as a vector:
      • output$highPbcDis

# evalPbc identifies too high correlations (> .005) for distractors per default [fancy]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi"))
    Message <cliMessage>
      [32m✔[39m Excellent, no attractors (score 1) were chosen with a frequency of zero.
      [32m✔[39m Excellent, no distractors (score 0) were chosen with a frequency of zero.
      [31m✖[39m catPbcs for distractors (score 0) of the following 1 item are unexpectedly high (> 0.005): [32m[32mI1_1_0.01[32m[39m
      [36mℹ[39m For a list of problematic items, save the `output` of this function and
      return the item names as a vector:
      • output$highPbcDis

# evalPbc accepts user-defined correlation cutoffs for distractors [plain]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi"), maxPbcDis = 0.1)
    Message <cliMessage>
      v Excellent, no attractors (score 1) were chosen with a frequency of zero.
      v Excellent, no distractors (score 0) were chosen with a frequency of zero.

# evalPbc accepts user-defined correlation cutoffs for distractors [ansi]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi"), maxPbcDis = 0.1)
    Message <cliMessage>
      [32mv[39m Excellent, no attractors (score 1) were chosen with a frequency of zero.
      [32mv[39m Excellent, no distractors (score 0) were chosen with a frequency of zero.

# evalPbc accepts user-defined correlation cutoffs for distractors [unicode]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi"), maxPbcDis = 0.1)
    Message <cliMessage>
      ✔ Excellent, no attractors (score 1) were chosen with a frequency of zero.
      ✔ Excellent, no distractors (score 0) were chosen with a frequency of zero.

# evalPbc accepts user-defined correlation cutoffs for distractors [fancy]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi"), maxPbcDis = 0.1)
    Message <cliMessage>
      [32m✔[39m Excellent, no attractors (score 1) were chosen with a frequency of zero.
      [32m✔[39m Excellent, no distractors (score 0) were chosen with a frequency of zero.

# evalPbc identifies too high user defined correlations for distractors [plain]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi"), maxPbcDis = 1e-04)
    Message <cliMessage>
      v Excellent, no attractors (score 1) were chosen with a frequency of zero.
      v Excellent, no distractors (score 0) were chosen with a frequency of zero.
      x catPbcs for distractors (score 0) of the following 1 item are unexpectedly high (> 0.0001): I1_1_0
      i For a list of problematic items, save the `output` of this function and
      return the item names as a vector:
      * output$highPbcDis

# evalPbc identifies too high user defined correlations for distractors [ansi]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi"), maxPbcDis = 1e-04)
    Message <cliMessage>
      [32mv[39m Excellent, no attractors (score 1) were chosen with a frequency of zero.
      [32mv[39m Excellent, no distractors (score 0) were chosen with a frequency of zero.
      [31mx[39m catPbcs for distractors (score 0) of the following 1 item are unexpectedly high (> 0.0001): [32m[32mI1_1_0[32m[39m
      [36mi[39m For a list of problematic items, save the `output` of this function and
      return the item names as a vector:
      * output$highPbcDis

# evalPbc identifies too high user defined correlations for distractors [unicode]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi"), maxPbcDis = 1e-04)
    Message <cliMessage>
      ✔ Excellent, no attractors (score 1) were chosen with a frequency of zero.
      ✔ Excellent, no distractors (score 0) were chosen with a frequency of zero.
      ✖ catPbcs for distractors (score 0) of the following 1 item are unexpectedly high (> 0.0001): I1_1_0
      ℹ For a list of problematic items, save the `output` of this function and
      return the item names as a vector:
      • output$highPbcDis

# evalPbc identifies too high user defined correlations for distractors [fancy]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi"), maxPbcDis = 1e-04)
    Message <cliMessage>
      [32m✔[39m Excellent, no attractors (score 1) were chosen with a frequency of zero.
      [32m✔[39m Excellent, no distractors (score 0) were chosen with a frequency of zero.
      [31m✖[39m catPbcs for distractors (score 0) of the following 1 item are unexpectedly high (> 0.0001): [32m[32mI1_1_0[32m[39m
      [36mℹ[39m For a list of problematic items, save the `output` of this function and
      return the item names as a vector:
      • output$highPbcDis

# evalPbc ignores missing correlations for distractors [plain]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi"))
    Message <cliMessage>
      v Excellent, no attractors (score 1) were chosen with a frequency of zero.
      v Excellent, no distractors (score 0) were chosen with a frequency of zero.

# evalPbc ignores missing correlations for distractors [ansi]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi"))
    Message <cliMessage>
      [32mv[39m Excellent, no attractors (score 1) were chosen with a frequency of zero.
      [32mv[39m Excellent, no distractors (score 0) were chosen with a frequency of zero.

# evalPbc ignores missing correlations for distractors [unicode]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi"))
    Message <cliMessage>
      ✔ Excellent, no attractors (score 1) were chosen with a frequency of zero.
      ✔ Excellent, no distractors (score 0) were chosen with a frequency of zero.

# evalPbc ignores missing correlations for distractors [fancy]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi"))
    Message <cliMessage>
      [32m✔[39m Excellent, no attractors (score 1) were chosen with a frequency of zero.
      [32m✔[39m Excellent, no distractors (score 0) were chosen with a frequency of zero.

# evalPbc identifies too high correlations (> .07) for missings per default [plain]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi"))
    Message <cliMessage>
      v Excellent, no attractors (score 1) were chosen with a frequency of zero.
      v Excellent, no distractors (score 0) were chosen with a frequency of zero.
      ! catPbcs for mistype 'mir' of the following 1 item are relatively high (>
      0.07): I1_8_0.08
      i For a list of problematic items, save the `output` of this function and
      return the item names as a vector:
      * output$highPbcMis$mir

# evalPbc identifies too high correlations (> .07) for missings per default [ansi]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi"))
    Message <cliMessage>
      [32mv[39m Excellent, no attractors (score 1) were chosen with a frequency of zero.
      [32mv[39m Excellent, no distractors (score 0) were chosen with a frequency of zero.
      [33m![39m catPbcs for mistype 'mir' of the following 1 item are relatively high (>
      0.07): [32mI1_8_0.08[39m
      [36mi[39m For a list of problematic items, save the `output` of this function and
      return the item names as a vector:
      * output$highPbcMis$mir

# evalPbc identifies too high correlations (> .07) for missings per default [unicode]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi"))
    Message <cliMessage>
      ✔ Excellent, no attractors (score 1) were chosen with a frequency of zero.
      ✔ Excellent, no distractors (score 0) were chosen with a frequency of zero.
      ! catPbcs for mistype 'mir' of the following 1 item are relatively high (>
      0.07): I1_8_0.08
      ℹ For a list of problematic items, save the `output` of this function and
      return the item names as a vector:
      • output$highPbcMis$mir

# evalPbc identifies too high correlations (> .07) for missings per default [fancy]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi"))
    Message <cliMessage>
      [32m✔[39m Excellent, no attractors (score 1) were chosen with a frequency of zero.
      [32m✔[39m Excellent, no distractors (score 0) were chosen with a frequency of zero.
      [33m![39m catPbcs for mistype 'mir' of the following 1 item are relatively high (>
      0.07): [32mI1_8_0.08[39m
      [36mℹ[39m For a list of problematic items, save the `output` of this function and
      return the item names as a vector:
      • output$highPbcMis$mir

# evalPbc accepts user-defined correlation cutoffs for missings [plain]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi"), maxPbcMis = 0.11)
    Message <cliMessage>
      v Excellent, no attractors (score 1) were chosen with a frequency of zero.
      v Excellent, no distractors (score 0) were chosen with a frequency of zero.

# evalPbc accepts user-defined correlation cutoffs for missings [ansi]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi"), maxPbcMis = 0.11)
    Message <cliMessage>
      [32mv[39m Excellent, no attractors (score 1) were chosen with a frequency of zero.
      [32mv[39m Excellent, no distractors (score 0) were chosen with a frequency of zero.

# evalPbc accepts user-defined correlation cutoffs for missings [unicode]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi"), maxPbcMis = 0.11)
    Message <cliMessage>
      ✔ Excellent, no attractors (score 1) were chosen with a frequency of zero.
      ✔ Excellent, no distractors (score 0) were chosen with a frequency of zero.

# evalPbc accepts user-defined correlation cutoffs for missings [fancy]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi"), maxPbcMis = 0.11)
    Message <cliMessage>
      [32m✔[39m Excellent, no attractors (score 1) were chosen with a frequency of zero.
      [32m✔[39m Excellent, no distractors (score 0) were chosen with a frequency of zero.

# evalPbc identifies too high user-defined correlations for missings [plain]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi"), maxPbcMis = 0.01)
    Message <cliMessage>
      v Excellent, no attractors (score 1) were chosen with a frequency of zero.
      v Excellent, no distractors (score 0) were chosen with a frequency of zero.
      ! catPbcs for mistype 'mir' of the following 1 item are relatively high (>
      0.01): I1_8_0.05
      i For a list of problematic items, save the `output` of this function and
      return the item names as a vector:
      * output$highPbcMis$mir

# evalPbc identifies too high user-defined correlations for missings [ansi]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi"), maxPbcMis = 0.01)
    Message <cliMessage>
      [32mv[39m Excellent, no attractors (score 1) were chosen with a frequency of zero.
      [32mv[39m Excellent, no distractors (score 0) were chosen with a frequency of zero.
      [33m![39m catPbcs for mistype 'mir' of the following 1 item are relatively high (>
      0.01): [32mI1_8_0.05[39m
      [36mi[39m For a list of problematic items, save the `output` of this function and
      return the item names as a vector:
      * output$highPbcMis$mir

# evalPbc identifies too high user-defined correlations for missings [unicode]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi"), maxPbcMis = 0.01)
    Message <cliMessage>
      ✔ Excellent, no attractors (score 1) were chosen with a frequency of zero.
      ✔ Excellent, no distractors (score 0) were chosen with a frequency of zero.
      ! catPbcs for mistype 'mir' of the following 1 item are relatively high (>
      0.01): I1_8_0.05
      ℹ For a list of problematic items, save the `output` of this function and
      return the item names as a vector:
      • output$highPbcMis$mir

# evalPbc identifies too high user-defined correlations for missings [fancy]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi"), maxPbcMis = 0.01)
    Message <cliMessage>
      [32m✔[39m Excellent, no attractors (score 1) were chosen with a frequency of zero.
      [32m✔[39m Excellent, no distractors (score 0) were chosen with a frequency of zero.
      [33m![39m catPbcs for mistype 'mir' of the following 1 item are relatively high (>
      0.01): [32mI1_8_0.05[39m
      [36mℹ[39m For a list of problematic items, save the `output` of this function and
      return the item names as a vector:
      • output$highPbcMis$mir

# evalPbc ignores missing correlations for missings [plain]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi"))
    Message <cliMessage>
      v Excellent, no attractors (score 1) were chosen with a frequency of zero.
      v Excellent, no distractors (score 0) were chosen with a frequency of zero.

# evalPbc ignores missing correlations for missings [ansi]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi"))
    Message <cliMessage>
      [32mv[39m Excellent, no attractors (score 1) were chosen with a frequency of zero.
      [32mv[39m Excellent, no distractors (score 0) were chosen with a frequency of zero.

# evalPbc ignores missing correlations for missings [unicode]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi"))
    Message <cliMessage>
      ✔ Excellent, no attractors (score 1) were chosen with a frequency of zero.
      ✔ Excellent, no distractors (score 0) were chosen with a frequency of zero.

# evalPbc ignores missing correlations for missings [fancy]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi"))
    Message <cliMessage>
      [32m✔[39m Excellent, no attractors (score 1) were chosen with a frequency of zero.
      [32m✔[39m Excellent, no distractors (score 0) were chosen with a frequency of zero.

# evalPbc allows for user-defined missing codes [plain]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mycode", "mbi"))
    Message <cliMessage>
      v Excellent, no attractors (score 1) were chosen with a frequency of zero.
      v Excellent, no distractors (score 0) were chosen with a frequency of zero.

# evalPbc allows for user-defined missing codes [ansi]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mycode", "mbi"))
    Message <cliMessage>
      [32mv[39m Excellent, no attractors (score 1) were chosen with a frequency of zero.
      [32mv[39m Excellent, no distractors (score 0) were chosen with a frequency of zero.

# evalPbc allows for user-defined missing codes [unicode]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mycode", "mbi"))
    Message <cliMessage>
      ✔ Excellent, no attractors (score 1) were chosen with a frequency of zero.
      ✔ Excellent, no distractors (score 0) were chosen with a frequency of zero.

# evalPbc allows for user-defined missing codes [fancy]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mycode", "mbi"))
    Message <cliMessage>
      [32m✔[39m Excellent, no attractors (score 1) were chosen with a frequency of zero.
      [32m✔[39m Excellent, no distractors (score 0) were chosen with a frequency of zero.

# evalPbc throws an error if the data frame does not contain freq, recodevalue, and catPbc (with the exact spelling [plain]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi"))
    Error <rlang_error>
      'pbcs' should be a data.frame as generated by eatPrep::catPbc()

# evalPbc throws an error if the data frame does not contain freq, recodevalue, and catPbc (with the exact spelling [ansi]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi"))
    Error <rlang_error>
      [1m[22m'pbcs' should be a [34mdata.frame[39m as generated by [34meatPrep::catPbc()[39m

# evalPbc throws an error if the data frame does not contain freq, recodevalue, and catPbc (with the exact spelling [unicode]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi"))
    Error <rlang_error>
      'pbcs' should be a data.frame as generated by eatPrep::catPbc()

# evalPbc throws an error if the data frame does not contain freq, recodevalue, and catPbc (with the exact spelling [fancy]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi"))
    Error <rlang_error>
      [1m[22m'pbcs' should be a [34mdata.frame[39m as generated by [34meatPrep::catPbc()[39m

# evalPbc throws a message if the data frame contains missing types that are not specified in the mistypes argument [plain]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi"))
    Message <cliMessage>
      i 'catPbc' contains other values than 0, 1 and the specified mistypes: Other
      value(s): mycode
      v Excellent, no attractors (score 1) were chosen with a frequency of zero.
      v Excellent, no distractors (score 0) were chosen with a frequency of zero.

# evalPbc throws a message if the data frame contains missing types that are not specified in the mistypes argument [ansi]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi"))
    Message <cliMessage>
      [36mi[39m 'catPbc' contains other values than 0, 1 and the specified mistypes: Other
      value(s): [32mmycode[39m
      [32mv[39m Excellent, no attractors (score 1) were chosen with a frequency of zero.
      [32mv[39m Excellent, no distractors (score 0) were chosen with a frequency of zero.

# evalPbc throws a message if the data frame contains missing types that are not specified in the mistypes argument [unicode]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi"))
    Message <cliMessage>
      ℹ 'catPbc' contains other values than 0, 1 and the specified mistypes: Other
      value(s): mycode
      ✔ Excellent, no attractors (score 1) were chosen with a frequency of zero.
      ✔ Excellent, no distractors (score 0) were chosen with a frequency of zero.

# evalPbc throws a message if the data frame contains missing types that are not specified in the mistypes argument [fancy]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mir", "mbi"))
    Message <cliMessage>
      [36mℹ[39m 'catPbc' contains other values than 0, 1 and the specified mistypes: Other
      value(s): [32mmycode[39m
      [32m✔[39m Excellent, no attractors (score 1) were chosen with a frequency of zero.
      [32m✔[39m Excellent, no distractors (score 0) were chosen with a frequency of zero.

# evalPbc throws an error if the mistypes specification contains missing types that are not specified in the data frame [plain]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mycode", "mbi"))
    Message <cliMessage>
      i 'catPbc' contains other values than 0, 1 and the specified mistypes: Other
      value(s): mir
      v Excellent, no attractors (score 1) were chosen with a frequency of zero.
      v Excellent, no distractors (score 0) were chosen with a frequency of zero.

# evalPbc throws an error if the mistypes specification contains missing types that are not specified in the data frame [ansi]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mycode", "mbi"))
    Message <cliMessage>
      [36mi[39m 'catPbc' contains other values than 0, 1 and the specified mistypes: Other
      value(s): [32mmir[39m
      [32mv[39m Excellent, no attractors (score 1) were chosen with a frequency of zero.
      [32mv[39m Excellent, no distractors (score 0) were chosen with a frequency of zero.

# evalPbc throws an error if the mistypes specification contains missing types that are not specified in the data frame [unicode]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mycode", "mbi"))
    Message <cliMessage>
      ℹ 'catPbc' contains other values than 0, 1 and the specified mistypes: Other
      value(s): mir
      ✔ Excellent, no attractors (score 1) were chosen with a frequency of zero.
      ✔ Excellent, no distractors (score 0) were chosen with a frequency of zero.

# evalPbc throws an error if the mistypes specification contains missing types that are not specified in the data frame [fancy]

    Code
      evalPbc(test_pbc, mistypes = c("mnr", "mbd", "mycode", "mbi"))
    Message <cliMessage>
      [36mℹ[39m 'catPbc' contains other values than 0, 1 and the specified mistypes: Other
      value(s): [32mmir[39m
      [32m✔[39m Excellent, no attractors (score 1) were chosen with a frequency of zero.
      [32m✔[39m Excellent, no distractors (score 0) were chosen with a frequency of zero.

