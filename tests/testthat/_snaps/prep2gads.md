# checks for normal output and missing meta data info when scored [plain]

    Code
      prep2GADS(dat = preparedData, inputList = inputList[1:3], trafoType = "scored",
      verbose = TRUE)
    Message
      
      -- Check: Variables without info 
      i The following 2 variables are not in inputList ($units$unit) but in dataset,
      their meta data will be set to NA: `booklet` and `hisei`
    Output
      $dat
               ID  booklet hisei I01 I05 I06 I07 I08 I13 I15 I12
      1 person100 booklet1    49   0   0   0   0   0 -94 -94 -94
      2 person101 booklet1    NA -99   0 -99   0   1 -94 -94 -94
      3 person200 booklet2    69 -94 -94 -94 -94   0   0 -94   1
      4 person201 booklet2    76 -94 -94 -94 -94   0   1 -94   0
      5 person300 booklet3    49   0   0 -99 -98 -94 -94   0 -94
      6 person301 booklet3    NA   1   1   1   0 -94 -94 -99 -94
      
      $labels
          varName                               varLabel format display_width labeled
      1       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      2       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      3       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      4       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      5       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      6       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      25      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      26      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      27      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      28      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      29      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      30      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      31      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      32      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      33      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      34      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      35      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      36      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      37      I07                          Pizza: Choice   <NA>          <NA>     yes
      38      I07                          Pizza: Choice   <NA>          <NA>     yes
      39      I07                          Pizza: Choice   <NA>          <NA>     yes
      40      I07                          Pizza: Choice   <NA>          <NA>     yes
      41      I07                          Pizza: Choice   <NA>          <NA>     yes
      42      I07                          Pizza: Choice   <NA>          <NA>     yes
      43      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      44      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      45      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      46      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      47      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      48      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      67      I12                                 Shapes   <NA>          <NA>     yes
      68      I12                                 Shapes   <NA>          <NA>     yes
      69      I12                                 Shapes   <NA>          <NA>     yes
      70      I12                                 Shapes   <NA>          <NA>     yes
      71      I12                                 Shapes   <NA>          <NA>     yes
      72      I12                                 Shapes   <NA>          <NA>     yes
      73      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      74      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      75      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      76      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      77      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      78      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      83      I15                Shopping: Number prices   <NA>          <NA>     yes
      84      I15                Shopping: Number prices   <NA>          <NA>     yes
      85      I15                Shopping: Number prices   <NA>          <NA>     yes
      86      I15                Shopping: Number prices   <NA>          <NA>     yes
      87      I15                Shopping: Number prices   <NA>          <NA>     yes
      88      I15                Shopping: Number prices   <NA>          <NA>     yes
      167      ID                             Student ID   <NA>          <NA>     yes
      168 booklet                                   <NA>   <NA>          <NA>      no
      169   hisei                                   <NA>   <NA>          <NA>      no
          value
      1       0
      2       1
      3     -96
      4     -94
      5     -98
      6     -99
      25      0
      26      1
      27    -96
      28    -94
      29    -98
      30    -99
      31      0
      32      1
      33    -96
      34    -94
      35    -98
      36    -99
      37      1
      38      0
      39    -96
      40    -94
      41    -98
      42    -99
      43      0
      44      1
      45    -96
      46    -94
      47    -98
      48    -99
      67      0
      68      1
      69    -96
      70    -94
      71    -98
      72    -99
      73      0
      74      1
      75    -96
      76    -94
      77    -98
      78    -99
      83      1
      84      0
      85    -96
      86    -94
      87    -98
      88    -99
      167    NA
      168    NA
      169    NA
                                                                                        valLabel
      1                                  Response option 1 marked', or 'Response option 2 marked
      2                                                                 Response option 3 marked
      3                                                                      missing not reached
      4                                                                        missing by design
      5                                                                 missing invalid response
      6                                                                     missing by intention
      25                                                                                   other
      26                                                              14 mm (units not required)
      27                                                                     missing not reached
      28                                                                       missing by design
      29                                                                missing invalid response
      30                                                                    missing by intention
      31                                                                                   other
      32                                                                                      39
      33                                                                     missing not reached
      34                                                                       missing by design
      35                                                                missing invalid response
      36                                                                    missing by intention
      37                                                                Response option 1 marked
      38  Response option 2 marked', or 'Response option 3 marked', or 'Response option 4 marked
      39                                                                     missing not reached
      40                                                                       missing by design
      41                                                                missing invalid response
      42                                                                    missing by intention
      43                                                                                   other
      44                                          Surface area increases more rapidly than price
      45                                                                     missing not reached
      46                                                                       missing by design
      47                                                                missing invalid response
      48                                                                    missing by intention
      67                                                               wrong answer (aggregated)
      68                                                               right answer (aggregated)
      69                                                                     missing not reached
      70                                                                       missing by design
      71                                                                missing invalid response
      72                                                                    missing by intention
      73  Response option 1 marked', or 'Response option 3 marked', or 'Response option 4 marked
      74                                                                Response option 2 marked
      75                                                                     missing not reached
      76                                                                       missing by design
      77                                                                missing invalid response
      78                                                                    missing by intention
      83                                                                Response option 1 marked
      84  Response option 2 marked', or 'Response option 3 marked', or 'Response option 4 marked
      85                                                                     missing not reached
      86                                                                       missing by design
      87                                                                missing invalid response
      88                                                                    missing by intention
      167                                                                                   <NA>
      168                                                                                   <NA>
      169                                                                                   <NA>
          missings
      1      valid
      2      valid
      3       miss
      4       miss
      5       miss
      6       miss
      25     valid
      26     valid
      27      miss
      28      miss
      29      miss
      30      miss
      31     valid
      32     valid
      33      miss
      34      miss
      35      miss
      36      miss
      37     valid
      38     valid
      39      miss
      40      miss
      41      miss
      42      miss
      43     valid
      44     valid
      45      miss
      46      miss
      47      miss
      48      miss
      67     valid
      68     valid
      69      miss
      70      miss
      71      miss
      72      miss
      73     valid
      74     valid
      75      miss
      76      miss
      77      miss
      78      miss
      83     valid
      84     valid
      85      miss
      86      miss
      87      miss
      88      miss
      167     <NA>
      168     <NA>
      169     <NA>
      
      attr(,"class")
      [1] "GADSdat" "list"   

# checks for normal output and missing meta data info when scored [ansi]

    Code
      prep2GADS(dat = preparedData, inputList = inputList[1:3], trafoType = "scored",
      verbose = TRUE)
    Message
      
      -- [1m[1mCheck:[1m[22m Variables without info 
      [36mi[39m The following 2 variables are not in inputList ([32m$units$unit[39m) but in dataset,
      their meta data will be set to NA: `booklet` and `hisei`
    Output
      $dat
               ID  booklet hisei I01 I05 I06 I07 I08 I13 I15 I12
      1 person100 booklet1    49   0   0   0   0   0 -94 -94 -94
      2 person101 booklet1    NA -99   0 -99   0   1 -94 -94 -94
      3 person200 booklet2    69 -94 -94 -94 -94   0   0 -94   1
      4 person201 booklet2    76 -94 -94 -94 -94   0   1 -94   0
      5 person300 booklet3    49   0   0 -99 -98 -94 -94   0 -94
      6 person301 booklet3    NA   1   1   1   0 -94 -94 -99 -94
      
      $labels
          varName                               varLabel format display_width labeled
      1       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      2       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      3       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      4       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      5       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      6       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      25      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      26      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      27      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      28      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      29      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      30      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      31      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      32      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      33      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      34      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      35      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      36      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      37      I07                          Pizza: Choice   <NA>          <NA>     yes
      38      I07                          Pizza: Choice   <NA>          <NA>     yes
      39      I07                          Pizza: Choice   <NA>          <NA>     yes
      40      I07                          Pizza: Choice   <NA>          <NA>     yes
      41      I07                          Pizza: Choice   <NA>          <NA>     yes
      42      I07                          Pizza: Choice   <NA>          <NA>     yes
      43      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      44      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      45      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      46      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      47      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      48      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      67      I12                                 Shapes   <NA>          <NA>     yes
      68      I12                                 Shapes   <NA>          <NA>     yes
      69      I12                                 Shapes   <NA>          <NA>     yes
      70      I12                                 Shapes   <NA>          <NA>     yes
      71      I12                                 Shapes   <NA>          <NA>     yes
      72      I12                                 Shapes   <NA>          <NA>     yes
      73      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      74      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      75      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      76      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      77      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      78      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      83      I15                Shopping: Number prices   <NA>          <NA>     yes
      84      I15                Shopping: Number prices   <NA>          <NA>     yes
      85      I15                Shopping: Number prices   <NA>          <NA>     yes
      86      I15                Shopping: Number prices   <NA>          <NA>     yes
      87      I15                Shopping: Number prices   <NA>          <NA>     yes
      88      I15                Shopping: Number prices   <NA>          <NA>     yes
      167      ID                             Student ID   <NA>          <NA>     yes
      168 booklet                                   <NA>   <NA>          <NA>      no
      169   hisei                                   <NA>   <NA>          <NA>      no
          value
      1       0
      2       1
      3     -96
      4     -94
      5     -98
      6     -99
      25      0
      26      1
      27    -96
      28    -94
      29    -98
      30    -99
      31      0
      32      1
      33    -96
      34    -94
      35    -98
      36    -99
      37      1
      38      0
      39    -96
      40    -94
      41    -98
      42    -99
      43      0
      44      1
      45    -96
      46    -94
      47    -98
      48    -99
      67      0
      68      1
      69    -96
      70    -94
      71    -98
      72    -99
      73      0
      74      1
      75    -96
      76    -94
      77    -98
      78    -99
      83      1
      84      0
      85    -96
      86    -94
      87    -98
      88    -99
      167    NA
      168    NA
      169    NA
                                                                                        valLabel
      1                                  Response option 1 marked', or 'Response option 2 marked
      2                                                                 Response option 3 marked
      3                                                                      missing not reached
      4                                                                        missing by design
      5                                                                 missing invalid response
      6                                                                     missing by intention
      25                                                                                   other
      26                                                              14 mm (units not required)
      27                                                                     missing not reached
      28                                                                       missing by design
      29                                                                missing invalid response
      30                                                                    missing by intention
      31                                                                                   other
      32                                                                                      39
      33                                                                     missing not reached
      34                                                                       missing by design
      35                                                                missing invalid response
      36                                                                    missing by intention
      37                                                                Response option 1 marked
      38  Response option 2 marked', or 'Response option 3 marked', or 'Response option 4 marked
      39                                                                     missing not reached
      40                                                                       missing by design
      41                                                                missing invalid response
      42                                                                    missing by intention
      43                                                                                   other
      44                                          Surface area increases more rapidly than price
      45                                                                     missing not reached
      46                                                                       missing by design
      47                                                                missing invalid response
      48                                                                    missing by intention
      67                                                               wrong answer (aggregated)
      68                                                               right answer (aggregated)
      69                                                                     missing not reached
      70                                                                       missing by design
      71                                                                missing invalid response
      72                                                                    missing by intention
      73  Response option 1 marked', or 'Response option 3 marked', or 'Response option 4 marked
      74                                                                Response option 2 marked
      75                                                                     missing not reached
      76                                                                       missing by design
      77                                                                missing invalid response
      78                                                                    missing by intention
      83                                                                Response option 1 marked
      84  Response option 2 marked', or 'Response option 3 marked', or 'Response option 4 marked
      85                                                                     missing not reached
      86                                                                       missing by design
      87                                                                missing invalid response
      88                                                                    missing by intention
      167                                                                                   <NA>
      168                                                                                   <NA>
      169                                                                                   <NA>
          missings
      1      valid
      2      valid
      3       miss
      4       miss
      5       miss
      6       miss
      25     valid
      26     valid
      27      miss
      28      miss
      29      miss
      30      miss
      31     valid
      32     valid
      33      miss
      34      miss
      35      miss
      36      miss
      37     valid
      38     valid
      39      miss
      40      miss
      41      miss
      42      miss
      43     valid
      44     valid
      45      miss
      46      miss
      47      miss
      48      miss
      67     valid
      68     valid
      69      miss
      70      miss
      71      miss
      72      miss
      73     valid
      74     valid
      75      miss
      76      miss
      77      miss
      78      miss
      83     valid
      84     valid
      85      miss
      86      miss
      87      miss
      88      miss
      167     <NA>
      168     <NA>
      169     <NA>
      
      attr(,"class")
      [1] "GADSdat" "list"   

# checks for normal output and missing meta data info when scored [unicode]

    Code
      prep2GADS(dat = preparedData, inputList = inputList[1:3], trafoType = "scored",
      verbose = TRUE)
    Message
      
      ── Check: Variables without info 
      ℹ The following 2 variables are not in inputList ($units$unit) but in dataset,
      their meta data will be set to NA: `booklet` and `hisei`
    Output
      $dat
               ID  booklet hisei I01 I05 I06 I07 I08 I13 I15 I12
      1 person100 booklet1    49   0   0   0   0   0 -94 -94 -94
      2 person101 booklet1    NA -99   0 -99   0   1 -94 -94 -94
      3 person200 booklet2    69 -94 -94 -94 -94   0   0 -94   1
      4 person201 booklet2    76 -94 -94 -94 -94   0   1 -94   0
      5 person300 booklet3    49   0   0 -99 -98 -94 -94   0 -94
      6 person301 booklet3    NA   1   1   1   0 -94 -94 -99 -94
      
      $labels
          varName                               varLabel format display_width labeled
      1       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      2       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      3       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      4       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      5       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      6       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      25      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      26      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      27      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      28      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      29      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      30      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      31      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      32      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      33      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      34      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      35      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      36      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      37      I07                          Pizza: Choice   <NA>          <NA>     yes
      38      I07                          Pizza: Choice   <NA>          <NA>     yes
      39      I07                          Pizza: Choice   <NA>          <NA>     yes
      40      I07                          Pizza: Choice   <NA>          <NA>     yes
      41      I07                          Pizza: Choice   <NA>          <NA>     yes
      42      I07                          Pizza: Choice   <NA>          <NA>     yes
      43      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      44      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      45      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      46      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      47      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      48      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      67      I12                                 Shapes   <NA>          <NA>     yes
      68      I12                                 Shapes   <NA>          <NA>     yes
      69      I12                                 Shapes   <NA>          <NA>     yes
      70      I12                                 Shapes   <NA>          <NA>     yes
      71      I12                                 Shapes   <NA>          <NA>     yes
      72      I12                                 Shapes   <NA>          <NA>     yes
      73      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      74      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      75      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      76      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      77      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      78      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      83      I15                Shopping: Number prices   <NA>          <NA>     yes
      84      I15                Shopping: Number prices   <NA>          <NA>     yes
      85      I15                Shopping: Number prices   <NA>          <NA>     yes
      86      I15                Shopping: Number prices   <NA>          <NA>     yes
      87      I15                Shopping: Number prices   <NA>          <NA>     yes
      88      I15                Shopping: Number prices   <NA>          <NA>     yes
      167      ID                             Student ID   <NA>          <NA>     yes
      168 booklet                                   <NA>   <NA>          <NA>      no
      169   hisei                                   <NA>   <NA>          <NA>      no
          value
      1       0
      2       1
      3     -96
      4     -94
      5     -98
      6     -99
      25      0
      26      1
      27    -96
      28    -94
      29    -98
      30    -99
      31      0
      32      1
      33    -96
      34    -94
      35    -98
      36    -99
      37      1
      38      0
      39    -96
      40    -94
      41    -98
      42    -99
      43      0
      44      1
      45    -96
      46    -94
      47    -98
      48    -99
      67      0
      68      1
      69    -96
      70    -94
      71    -98
      72    -99
      73      0
      74      1
      75    -96
      76    -94
      77    -98
      78    -99
      83      1
      84      0
      85    -96
      86    -94
      87    -98
      88    -99
      167    NA
      168    NA
      169    NA
                                                                                        valLabel
      1                                  Response option 1 marked', or 'Response option 2 marked
      2                                                                 Response option 3 marked
      3                                                                      missing not reached
      4                                                                        missing by design
      5                                                                 missing invalid response
      6                                                                     missing by intention
      25                                                                                   other
      26                                                              14 mm (units not required)
      27                                                                     missing not reached
      28                                                                       missing by design
      29                                                                missing invalid response
      30                                                                    missing by intention
      31                                                                                   other
      32                                                                                      39
      33                                                                     missing not reached
      34                                                                       missing by design
      35                                                                missing invalid response
      36                                                                    missing by intention
      37                                                                Response option 1 marked
      38  Response option 2 marked', or 'Response option 3 marked', or 'Response option 4 marked
      39                                                                     missing not reached
      40                                                                       missing by design
      41                                                                missing invalid response
      42                                                                    missing by intention
      43                                                                                   other
      44                                          Surface area increases more rapidly than price
      45                                                                     missing not reached
      46                                                                       missing by design
      47                                                                missing invalid response
      48                                                                    missing by intention
      67                                                               wrong answer (aggregated)
      68                                                               right answer (aggregated)
      69                                                                     missing not reached
      70                                                                       missing by design
      71                                                                missing invalid response
      72                                                                    missing by intention
      73  Response option 1 marked', or 'Response option 3 marked', or 'Response option 4 marked
      74                                                                Response option 2 marked
      75                                                                     missing not reached
      76                                                                       missing by design
      77                                                                missing invalid response
      78                                                                    missing by intention
      83                                                                Response option 1 marked
      84  Response option 2 marked', or 'Response option 3 marked', or 'Response option 4 marked
      85                                                                     missing not reached
      86                                                                       missing by design
      87                                                                missing invalid response
      88                                                                    missing by intention
      167                                                                                   <NA>
      168                                                                                   <NA>
      169                                                                                   <NA>
          missings
      1      valid
      2      valid
      3       miss
      4       miss
      5       miss
      6       miss
      25     valid
      26     valid
      27      miss
      28      miss
      29      miss
      30      miss
      31     valid
      32     valid
      33      miss
      34      miss
      35      miss
      36      miss
      37     valid
      38     valid
      39      miss
      40      miss
      41      miss
      42      miss
      43     valid
      44     valid
      45      miss
      46      miss
      47      miss
      48      miss
      67     valid
      68     valid
      69      miss
      70      miss
      71      miss
      72      miss
      73     valid
      74     valid
      75      miss
      76      miss
      77      miss
      78      miss
      83     valid
      84     valid
      85      miss
      86      miss
      87      miss
      88      miss
      167     <NA>
      168     <NA>
      169     <NA>
      
      attr(,"class")
      [1] "GADSdat" "list"   

# checks for normal output and missing meta data info when scored [fancy]

    Code
      prep2GADS(dat = preparedData, inputList = inputList[1:3], trafoType = "scored",
      verbose = TRUE)
    Message
      
      ── [1m[1mCheck:[1m[22m Variables without info 
      [36mℹ[39m The following 2 variables are not in inputList ([32m$units$unit[39m) but in dataset,
      their meta data will be set to NA: `booklet` and `hisei`
    Output
      $dat
               ID  booklet hisei I01 I05 I06 I07 I08 I13 I15 I12
      1 person100 booklet1    49   0   0   0   0   0 -94 -94 -94
      2 person101 booklet1    NA -99   0 -99   0   1 -94 -94 -94
      3 person200 booklet2    69 -94 -94 -94 -94   0   0 -94   1
      4 person201 booklet2    76 -94 -94 -94 -94   0   1 -94   0
      5 person300 booklet3    49   0   0 -99 -98 -94 -94   0 -94
      6 person301 booklet3    NA   1   1   1   0 -94 -94 -99 -94
      
      $labels
          varName                               varLabel format display_width labeled
      1       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      2       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      3       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      4       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      5       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      6       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      25      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      26      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      27      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      28      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      29      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      30      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      31      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      32      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      33      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      34      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      35      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      36      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      37      I07                          Pizza: Choice   <NA>          <NA>     yes
      38      I07                          Pizza: Choice   <NA>          <NA>     yes
      39      I07                          Pizza: Choice   <NA>          <NA>     yes
      40      I07                          Pizza: Choice   <NA>          <NA>     yes
      41      I07                          Pizza: Choice   <NA>          <NA>     yes
      42      I07                          Pizza: Choice   <NA>          <NA>     yes
      43      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      44      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      45      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      46      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      47      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      48      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      67      I12                                 Shapes   <NA>          <NA>     yes
      68      I12                                 Shapes   <NA>          <NA>     yes
      69      I12                                 Shapes   <NA>          <NA>     yes
      70      I12                                 Shapes   <NA>          <NA>     yes
      71      I12                                 Shapes   <NA>          <NA>     yes
      72      I12                                 Shapes   <NA>          <NA>     yes
      73      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      74      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      75      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      76      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      77      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      78      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      83      I15                Shopping: Number prices   <NA>          <NA>     yes
      84      I15                Shopping: Number prices   <NA>          <NA>     yes
      85      I15                Shopping: Number prices   <NA>          <NA>     yes
      86      I15                Shopping: Number prices   <NA>          <NA>     yes
      87      I15                Shopping: Number prices   <NA>          <NA>     yes
      88      I15                Shopping: Number prices   <NA>          <NA>     yes
      167      ID                             Student ID   <NA>          <NA>     yes
      168 booklet                                   <NA>   <NA>          <NA>      no
      169   hisei                                   <NA>   <NA>          <NA>      no
          value
      1       0
      2       1
      3     -96
      4     -94
      5     -98
      6     -99
      25      0
      26      1
      27    -96
      28    -94
      29    -98
      30    -99
      31      0
      32      1
      33    -96
      34    -94
      35    -98
      36    -99
      37      1
      38      0
      39    -96
      40    -94
      41    -98
      42    -99
      43      0
      44      1
      45    -96
      46    -94
      47    -98
      48    -99
      67      0
      68      1
      69    -96
      70    -94
      71    -98
      72    -99
      73      0
      74      1
      75    -96
      76    -94
      77    -98
      78    -99
      83      1
      84      0
      85    -96
      86    -94
      87    -98
      88    -99
      167    NA
      168    NA
      169    NA
                                                                                        valLabel
      1                                  Response option 1 marked', or 'Response option 2 marked
      2                                                                 Response option 3 marked
      3                                                                      missing not reached
      4                                                                        missing by design
      5                                                                 missing invalid response
      6                                                                     missing by intention
      25                                                                                   other
      26                                                              14 mm (units not required)
      27                                                                     missing not reached
      28                                                                       missing by design
      29                                                                missing invalid response
      30                                                                    missing by intention
      31                                                                                   other
      32                                                                                      39
      33                                                                     missing not reached
      34                                                                       missing by design
      35                                                                missing invalid response
      36                                                                    missing by intention
      37                                                                Response option 1 marked
      38  Response option 2 marked', or 'Response option 3 marked', or 'Response option 4 marked
      39                                                                     missing not reached
      40                                                                       missing by design
      41                                                                missing invalid response
      42                                                                    missing by intention
      43                                                                                   other
      44                                          Surface area increases more rapidly than price
      45                                                                     missing not reached
      46                                                                       missing by design
      47                                                                missing invalid response
      48                                                                    missing by intention
      67                                                               wrong answer (aggregated)
      68                                                               right answer (aggregated)
      69                                                                     missing not reached
      70                                                                       missing by design
      71                                                                missing invalid response
      72                                                                    missing by intention
      73  Response option 1 marked', or 'Response option 3 marked', or 'Response option 4 marked
      74                                                                Response option 2 marked
      75                                                                     missing not reached
      76                                                                       missing by design
      77                                                                missing invalid response
      78                                                                    missing by intention
      83                                                                Response option 1 marked
      84  Response option 2 marked', or 'Response option 3 marked', or 'Response option 4 marked
      85                                                                     missing not reached
      86                                                                       missing by design
      87                                                                missing invalid response
      88                                                                    missing by intention
      167                                                                                   <NA>
      168                                                                                   <NA>
      169                                                                                   <NA>
          missings
      1      valid
      2      valid
      3       miss
      4       miss
      5       miss
      6       miss
      25     valid
      26     valid
      27      miss
      28      miss
      29      miss
      30      miss
      31     valid
      32     valid
      33      miss
      34      miss
      35      miss
      36      miss
      37     valid
      38     valid
      39      miss
      40      miss
      41      miss
      42      miss
      43     valid
      44     valid
      45      miss
      46      miss
      47      miss
      48      miss
      67     valid
      68     valid
      69      miss
      70      miss
      71      miss
      72      miss
      73     valid
      74     valid
      75      miss
      76      miss
      77      miss
      78      miss
      83     valid
      84     valid
      85      miss
      86      miss
      87      miss
      88      miss
      167     <NA>
      168     <NA>
      169     <NA>
      
      attr(,"class")
      [1] "GADSdat" "list"   

# checks for normal output and missing meta data info when raw [plain]

    Code
      prep2GADS(dat = preparedData2, inputList = inputList[1:3], trafoType = "raw",
      verbose = TRUE)
    Message
      
      -- Check: Variables without info 
      i The following 1 variable is not in inputList ($subunits$subunit or
      $units$unit) but in dataset, its meta data will be set to NA: `hisei`
    Output
      $dat
               ID hisei I01 I05 I06 I07 I08 I12a I12b I12c I13 I15
      1 person100    49   1   0   0   2   0   NA   NA   NA  NA  NA
      2 person101    NA   9   0   9   2   1   NA   NA   NA  NA  NA
      3 person200    69  NA  NA  NA  NA   0    1    1    4   4  NA
      4 person201    76  NA  NA  NA  NA   0    0    0    3   2  NA
      5 person300    49   2   0   9   8  NA   NA   NA   NA  NA   3
      6 person301    NA   3   1   1   2  NA   NA   NA   NA  NA   9
      
      $labels
          varName                               varLabel format display_width labeled
      1       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      2       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      3       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      4       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      5       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      6       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      7       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      30      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      31      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      32      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      33      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      34      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      35      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      36      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      37      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      38      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      39      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      40      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      41      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      42      I07                          Pizza: Choice   <NA>          <NA>     yes
      43      I07                          Pizza: Choice   <NA>          <NA>     yes
      44      I07                          Pizza: Choice   <NA>          <NA>     yes
      45      I07                          Pizza: Choice   <NA>          <NA>     yes
      46      I07                          Pizza: Choice   <NA>          <NA>     yes
      47      I07                          Pizza: Choice   <NA>          <NA>     yes
      48      I07                          Pizza: Choice   <NA>          <NA>     yes
      49      I07                          Pizza: Choice   <NA>          <NA>     yes
      50      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      51      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      52      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      53      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      54      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      55      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      80     I12a                  Shapes: Biggest shape   <NA>          <NA>     yes
      81     I12a                  Shapes: Biggest shape   <NA>          <NA>     yes
      82     I12a                  Shapes: Biggest shape   <NA>          <NA>     yes
      83     I12a                  Shapes: Biggest shape   <NA>          <NA>     yes
      84     I12a                  Shapes: Biggest shape   <NA>          <NA>     yes
      85     I12a                  Shapes: Biggest shape   <NA>          <NA>     yes
      86     I12b                  Shapes: Circumference   <NA>          <NA>     yes
      87     I12b                  Shapes: Circumference   <NA>          <NA>     yes
      88     I12b                  Shapes: Circumference   <NA>          <NA>     yes
      89     I12b                  Shapes: Circumference   <NA>          <NA>     yes
      90     I12b                  Shapes: Circumference   <NA>          <NA>     yes
      91     I12b                  Shapes: Circumference   <NA>          <NA>     yes
      92     I12c               Shapes: Size calculation   <NA>          <NA>     yes
      93     I12c               Shapes: Size calculation   <NA>          <NA>     yes
      94     I12c               Shapes: Size calculation   <NA>          <NA>     yes
      95     I12c               Shapes: Size calculation   <NA>          <NA>     yes
      96     I12c               Shapes: Size calculation   <NA>          <NA>     yes
      97     I12c               Shapes: Size calculation   <NA>          <NA>     yes
      98     I12c               Shapes: Size calculation   <NA>          <NA>     yes
      99     I12c               Shapes: Size calculation   <NA>          <NA>     yes
      100     I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      101     I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      102     I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      103     I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      104     I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      105     I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      106     I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      107     I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      117     I15                Shopping: Number prices   <NA>          <NA>     yes
      118     I15                Shopping: Number prices   <NA>          <NA>     yes
      119     I15                Shopping: Number prices   <NA>          <NA>     yes
      120     I15                Shopping: Number prices   <NA>          <NA>     yes
      121     I15                Shopping: Number prices   <NA>          <NA>     yes
      122     I15                Shopping: Number prices   <NA>          <NA>     yes
      123     I15                Shopping: Number prices   <NA>          <NA>     yes
      124     I15                Shopping: Number prices   <NA>          <NA>     yes
      221      ID                             Student ID   <NA>          <NA>     yes
      222   hisei                                   <NA>   <NA>          <NA>      no
          value                                       valLabel missings
      1       1                       Response option 1 marked    valid
      2       2                       Response option 2 marked    valid
      3       3                       Response option 3 marked    valid
      4       6                            missing not reached     miss
      5       7                              missing by design     miss
      6       8                       missing invalid response     miss
      7       9                           missing by intention     miss
      30      0                                          other    valid
      31      1                     14 mm (units not required)    valid
      32      6                            missing not reached     miss
      33      7                              missing by design     miss
      34      8                       missing invalid response     miss
      35      9                           missing by intention     miss
      36      0                                          other    valid
      37      1                                             39    valid
      38      6                            missing not reached     miss
      39      7                              missing by design     miss
      40      8                       missing invalid response     miss
      41      9                           missing by intention     miss
      42      1                       Response option 1 marked    valid
      43      2                       Response option 2 marked    valid
      44      3                       Response option 3 marked    valid
      45      4                       Response option 4 marked    valid
      46      6                            missing not reached     miss
      47      7                              missing by design     miss
      48      8                       missing invalid response     miss
      49      9                           missing by intention     miss
      50      0                                          other    valid
      51      1 Surface area increases more rapidly than price    valid
      52      6                            missing not reached     miss
      53      7                              missing by design     miss
      54      8                       missing invalid response     miss
      55      9                           missing by intention     miss
      80      0                                          other    valid
      81      1   Shape B, supported with plausible reasoning.    valid
      82      6                            missing not reached     miss
      83      7                              missing by design     miss
      84      8                       missing invalid response     miss
      85      9                           missing by intention     miss
      86      0                                          other    valid
      87      1               22.9 metres (units not required)    valid
      88      6                            missing not reached     miss
      89      7                              missing by design     miss
      90      8                       missing invalid response     miss
      91      9                           missing by intention     miss
      92      1                       Response option 1 marked    valid
      93      2                       Response option 2 marked    valid
      94      3                       Response option 3 marked    valid
      95      4                       Response option 4 marked    valid
      96      6                            missing not reached     miss
      97      7                              missing by design     miss
      98      8                       missing invalid response     miss
      99      9                           missing by intention     miss
      100     1                       Response option 1 marked    valid
      101     2                       Response option 2 marked    valid
      102     3                       Response option 3 marked    valid
      103     4                       Response option 4 marked    valid
      104     6                            missing not reached     miss
      105     7                              missing by design     miss
      106     8                       missing invalid response     miss
      107     9                           missing by intention     miss
      117     1                       Response option 1 marked    valid
      118     2                       Response option 2 marked    valid
      119     3                       Response option 3 marked    valid
      120     4                       Response option 4 marked    valid
      121     6                            missing not reached     miss
      122     7                              missing by design     miss
      123     8                       missing invalid response     miss
      124     9                           missing by intention     miss
      221    NA                                           <NA>     <NA>
      222    NA                                           <NA>     <NA>
      
      attr(,"class")
      [1] "GADSdat" "list"   

# checks for normal output and missing meta data info when raw [ansi]

    Code
      prep2GADS(dat = preparedData2, inputList = inputList[1:3], trafoType = "raw",
      verbose = TRUE)
    Message
      
      -- [1m[1mCheck:[1m[22m Variables without info 
      [36mi[39m The following 1 variable is not in inputList ([32m$subunits$subunit[39m or
      [32m$units$unit[39m) but in dataset, its meta data will be set to NA: `hisei`
    Output
      $dat
               ID hisei I01 I05 I06 I07 I08 I12a I12b I12c I13 I15
      1 person100    49   1   0   0   2   0   NA   NA   NA  NA  NA
      2 person101    NA   9   0   9   2   1   NA   NA   NA  NA  NA
      3 person200    69  NA  NA  NA  NA   0    1    1    4   4  NA
      4 person201    76  NA  NA  NA  NA   0    0    0    3   2  NA
      5 person300    49   2   0   9   8  NA   NA   NA   NA  NA   3
      6 person301    NA   3   1   1   2  NA   NA   NA   NA  NA   9
      
      $labels
          varName                               varLabel format display_width labeled
      1       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      2       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      3       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      4       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      5       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      6       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      7       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      30      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      31      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      32      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      33      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      34      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      35      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      36      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      37      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      38      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      39      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      40      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      41      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      42      I07                          Pizza: Choice   <NA>          <NA>     yes
      43      I07                          Pizza: Choice   <NA>          <NA>     yes
      44      I07                          Pizza: Choice   <NA>          <NA>     yes
      45      I07                          Pizza: Choice   <NA>          <NA>     yes
      46      I07                          Pizza: Choice   <NA>          <NA>     yes
      47      I07                          Pizza: Choice   <NA>          <NA>     yes
      48      I07                          Pizza: Choice   <NA>          <NA>     yes
      49      I07                          Pizza: Choice   <NA>          <NA>     yes
      50      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      51      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      52      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      53      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      54      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      55      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      80     I12a                  Shapes: Biggest shape   <NA>          <NA>     yes
      81     I12a                  Shapes: Biggest shape   <NA>          <NA>     yes
      82     I12a                  Shapes: Biggest shape   <NA>          <NA>     yes
      83     I12a                  Shapes: Biggest shape   <NA>          <NA>     yes
      84     I12a                  Shapes: Biggest shape   <NA>          <NA>     yes
      85     I12a                  Shapes: Biggest shape   <NA>          <NA>     yes
      86     I12b                  Shapes: Circumference   <NA>          <NA>     yes
      87     I12b                  Shapes: Circumference   <NA>          <NA>     yes
      88     I12b                  Shapes: Circumference   <NA>          <NA>     yes
      89     I12b                  Shapes: Circumference   <NA>          <NA>     yes
      90     I12b                  Shapes: Circumference   <NA>          <NA>     yes
      91     I12b                  Shapes: Circumference   <NA>          <NA>     yes
      92     I12c               Shapes: Size calculation   <NA>          <NA>     yes
      93     I12c               Shapes: Size calculation   <NA>          <NA>     yes
      94     I12c               Shapes: Size calculation   <NA>          <NA>     yes
      95     I12c               Shapes: Size calculation   <NA>          <NA>     yes
      96     I12c               Shapes: Size calculation   <NA>          <NA>     yes
      97     I12c               Shapes: Size calculation   <NA>          <NA>     yes
      98     I12c               Shapes: Size calculation   <NA>          <NA>     yes
      99     I12c               Shapes: Size calculation   <NA>          <NA>     yes
      100     I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      101     I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      102     I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      103     I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      104     I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      105     I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      106     I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      107     I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      117     I15                Shopping: Number prices   <NA>          <NA>     yes
      118     I15                Shopping: Number prices   <NA>          <NA>     yes
      119     I15                Shopping: Number prices   <NA>          <NA>     yes
      120     I15                Shopping: Number prices   <NA>          <NA>     yes
      121     I15                Shopping: Number prices   <NA>          <NA>     yes
      122     I15                Shopping: Number prices   <NA>          <NA>     yes
      123     I15                Shopping: Number prices   <NA>          <NA>     yes
      124     I15                Shopping: Number prices   <NA>          <NA>     yes
      221      ID                             Student ID   <NA>          <NA>     yes
      222   hisei                                   <NA>   <NA>          <NA>      no
          value                                       valLabel missings
      1       1                       Response option 1 marked    valid
      2       2                       Response option 2 marked    valid
      3       3                       Response option 3 marked    valid
      4       6                            missing not reached     miss
      5       7                              missing by design     miss
      6       8                       missing invalid response     miss
      7       9                           missing by intention     miss
      30      0                                          other    valid
      31      1                     14 mm (units not required)    valid
      32      6                            missing not reached     miss
      33      7                              missing by design     miss
      34      8                       missing invalid response     miss
      35      9                           missing by intention     miss
      36      0                                          other    valid
      37      1                                             39    valid
      38      6                            missing not reached     miss
      39      7                              missing by design     miss
      40      8                       missing invalid response     miss
      41      9                           missing by intention     miss
      42      1                       Response option 1 marked    valid
      43      2                       Response option 2 marked    valid
      44      3                       Response option 3 marked    valid
      45      4                       Response option 4 marked    valid
      46      6                            missing not reached     miss
      47      7                              missing by design     miss
      48      8                       missing invalid response     miss
      49      9                           missing by intention     miss
      50      0                                          other    valid
      51      1 Surface area increases more rapidly than price    valid
      52      6                            missing not reached     miss
      53      7                              missing by design     miss
      54      8                       missing invalid response     miss
      55      9                           missing by intention     miss
      80      0                                          other    valid
      81      1   Shape B, supported with plausible reasoning.    valid
      82      6                            missing not reached     miss
      83      7                              missing by design     miss
      84      8                       missing invalid response     miss
      85      9                           missing by intention     miss
      86      0                                          other    valid
      87      1               22.9 metres (units not required)    valid
      88      6                            missing not reached     miss
      89      7                              missing by design     miss
      90      8                       missing invalid response     miss
      91      9                           missing by intention     miss
      92      1                       Response option 1 marked    valid
      93      2                       Response option 2 marked    valid
      94      3                       Response option 3 marked    valid
      95      4                       Response option 4 marked    valid
      96      6                            missing not reached     miss
      97      7                              missing by design     miss
      98      8                       missing invalid response     miss
      99      9                           missing by intention     miss
      100     1                       Response option 1 marked    valid
      101     2                       Response option 2 marked    valid
      102     3                       Response option 3 marked    valid
      103     4                       Response option 4 marked    valid
      104     6                            missing not reached     miss
      105     7                              missing by design     miss
      106     8                       missing invalid response     miss
      107     9                           missing by intention     miss
      117     1                       Response option 1 marked    valid
      118     2                       Response option 2 marked    valid
      119     3                       Response option 3 marked    valid
      120     4                       Response option 4 marked    valid
      121     6                            missing not reached     miss
      122     7                              missing by design     miss
      123     8                       missing invalid response     miss
      124     9                           missing by intention     miss
      221    NA                                           <NA>     <NA>
      222    NA                                           <NA>     <NA>
      
      attr(,"class")
      [1] "GADSdat" "list"   

# checks for normal output and missing meta data info when raw [unicode]

    Code
      prep2GADS(dat = preparedData2, inputList = inputList[1:3], trafoType = "raw",
      verbose = TRUE)
    Message
      
      ── Check: Variables without info 
      ℹ The following 1 variable is not in inputList ($subunits$subunit or
      $units$unit) but in dataset, its meta data will be set to NA: `hisei`
    Output
      $dat
               ID hisei I01 I05 I06 I07 I08 I12a I12b I12c I13 I15
      1 person100    49   1   0   0   2   0   NA   NA   NA  NA  NA
      2 person101    NA   9   0   9   2   1   NA   NA   NA  NA  NA
      3 person200    69  NA  NA  NA  NA   0    1    1    4   4  NA
      4 person201    76  NA  NA  NA  NA   0    0    0    3   2  NA
      5 person300    49   2   0   9   8  NA   NA   NA   NA  NA   3
      6 person301    NA   3   1   1   2  NA   NA   NA   NA  NA   9
      
      $labels
          varName                               varLabel format display_width labeled
      1       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      2       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      3       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      4       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      5       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      6       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      7       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      30      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      31      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      32      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      33      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      34      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      35      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      36      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      37      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      38      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      39      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      40      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      41      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      42      I07                          Pizza: Choice   <NA>          <NA>     yes
      43      I07                          Pizza: Choice   <NA>          <NA>     yes
      44      I07                          Pizza: Choice   <NA>          <NA>     yes
      45      I07                          Pizza: Choice   <NA>          <NA>     yes
      46      I07                          Pizza: Choice   <NA>          <NA>     yes
      47      I07                          Pizza: Choice   <NA>          <NA>     yes
      48      I07                          Pizza: Choice   <NA>          <NA>     yes
      49      I07                          Pizza: Choice   <NA>          <NA>     yes
      50      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      51      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      52      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      53      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      54      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      55      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      80     I12a                  Shapes: Biggest shape   <NA>          <NA>     yes
      81     I12a                  Shapes: Biggest shape   <NA>          <NA>     yes
      82     I12a                  Shapes: Biggest shape   <NA>          <NA>     yes
      83     I12a                  Shapes: Biggest shape   <NA>          <NA>     yes
      84     I12a                  Shapes: Biggest shape   <NA>          <NA>     yes
      85     I12a                  Shapes: Biggest shape   <NA>          <NA>     yes
      86     I12b                  Shapes: Circumference   <NA>          <NA>     yes
      87     I12b                  Shapes: Circumference   <NA>          <NA>     yes
      88     I12b                  Shapes: Circumference   <NA>          <NA>     yes
      89     I12b                  Shapes: Circumference   <NA>          <NA>     yes
      90     I12b                  Shapes: Circumference   <NA>          <NA>     yes
      91     I12b                  Shapes: Circumference   <NA>          <NA>     yes
      92     I12c               Shapes: Size calculation   <NA>          <NA>     yes
      93     I12c               Shapes: Size calculation   <NA>          <NA>     yes
      94     I12c               Shapes: Size calculation   <NA>          <NA>     yes
      95     I12c               Shapes: Size calculation   <NA>          <NA>     yes
      96     I12c               Shapes: Size calculation   <NA>          <NA>     yes
      97     I12c               Shapes: Size calculation   <NA>          <NA>     yes
      98     I12c               Shapes: Size calculation   <NA>          <NA>     yes
      99     I12c               Shapes: Size calculation   <NA>          <NA>     yes
      100     I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      101     I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      102     I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      103     I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      104     I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      105     I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      106     I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      107     I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      117     I15                Shopping: Number prices   <NA>          <NA>     yes
      118     I15                Shopping: Number prices   <NA>          <NA>     yes
      119     I15                Shopping: Number prices   <NA>          <NA>     yes
      120     I15                Shopping: Number prices   <NA>          <NA>     yes
      121     I15                Shopping: Number prices   <NA>          <NA>     yes
      122     I15                Shopping: Number prices   <NA>          <NA>     yes
      123     I15                Shopping: Number prices   <NA>          <NA>     yes
      124     I15                Shopping: Number prices   <NA>          <NA>     yes
      221      ID                             Student ID   <NA>          <NA>     yes
      222   hisei                                   <NA>   <NA>          <NA>      no
          value                                       valLabel missings
      1       1                       Response option 1 marked    valid
      2       2                       Response option 2 marked    valid
      3       3                       Response option 3 marked    valid
      4       6                            missing not reached     miss
      5       7                              missing by design     miss
      6       8                       missing invalid response     miss
      7       9                           missing by intention     miss
      30      0                                          other    valid
      31      1                     14 mm (units not required)    valid
      32      6                            missing not reached     miss
      33      7                              missing by design     miss
      34      8                       missing invalid response     miss
      35      9                           missing by intention     miss
      36      0                                          other    valid
      37      1                                             39    valid
      38      6                            missing not reached     miss
      39      7                              missing by design     miss
      40      8                       missing invalid response     miss
      41      9                           missing by intention     miss
      42      1                       Response option 1 marked    valid
      43      2                       Response option 2 marked    valid
      44      3                       Response option 3 marked    valid
      45      4                       Response option 4 marked    valid
      46      6                            missing not reached     miss
      47      7                              missing by design     miss
      48      8                       missing invalid response     miss
      49      9                           missing by intention     miss
      50      0                                          other    valid
      51      1 Surface area increases more rapidly than price    valid
      52      6                            missing not reached     miss
      53      7                              missing by design     miss
      54      8                       missing invalid response     miss
      55      9                           missing by intention     miss
      80      0                                          other    valid
      81      1   Shape B, supported with plausible reasoning.    valid
      82      6                            missing not reached     miss
      83      7                              missing by design     miss
      84      8                       missing invalid response     miss
      85      9                           missing by intention     miss
      86      0                                          other    valid
      87      1               22.9 metres (units not required)    valid
      88      6                            missing not reached     miss
      89      7                              missing by design     miss
      90      8                       missing invalid response     miss
      91      9                           missing by intention     miss
      92      1                       Response option 1 marked    valid
      93      2                       Response option 2 marked    valid
      94      3                       Response option 3 marked    valid
      95      4                       Response option 4 marked    valid
      96      6                            missing not reached     miss
      97      7                              missing by design     miss
      98      8                       missing invalid response     miss
      99      9                           missing by intention     miss
      100     1                       Response option 1 marked    valid
      101     2                       Response option 2 marked    valid
      102     3                       Response option 3 marked    valid
      103     4                       Response option 4 marked    valid
      104     6                            missing not reached     miss
      105     7                              missing by design     miss
      106     8                       missing invalid response     miss
      107     9                           missing by intention     miss
      117     1                       Response option 1 marked    valid
      118     2                       Response option 2 marked    valid
      119     3                       Response option 3 marked    valid
      120     4                       Response option 4 marked    valid
      121     6                            missing not reached     miss
      122     7                              missing by design     miss
      123     8                       missing invalid response     miss
      124     9                           missing by intention     miss
      221    NA                                           <NA>     <NA>
      222    NA                                           <NA>     <NA>
      
      attr(,"class")
      [1] "GADSdat" "list"   

# checks for normal output and missing meta data info when raw [fancy]

    Code
      prep2GADS(dat = preparedData2, inputList = inputList[1:3], trafoType = "raw",
      verbose = TRUE)
    Message
      
      ── [1m[1mCheck:[1m[22m Variables without info 
      [36mℹ[39m The following 1 variable is not in inputList ([32m$subunits$subunit[39m or
      [32m$units$unit[39m) but in dataset, its meta data will be set to NA: `hisei`
    Output
      $dat
               ID hisei I01 I05 I06 I07 I08 I12a I12b I12c I13 I15
      1 person100    49   1   0   0   2   0   NA   NA   NA  NA  NA
      2 person101    NA   9   0   9   2   1   NA   NA   NA  NA  NA
      3 person200    69  NA  NA  NA  NA   0    1    1    4   4  NA
      4 person201    76  NA  NA  NA  NA   0    0    0    3   2  NA
      5 person300    49   2   0   9   8  NA   NA   NA   NA  NA   3
      6 person301    NA   3   1   1   2  NA   NA   NA   NA  NA   9
      
      $labels
          varName                               varLabel format display_width labeled
      1       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      2       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      3       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      4       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      5       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      6       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      7       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      30      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      31      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      32      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      33      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      34      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      35      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      36      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      37      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      38      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      39      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      40      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      41      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      42      I07                          Pizza: Choice   <NA>          <NA>     yes
      43      I07                          Pizza: Choice   <NA>          <NA>     yes
      44      I07                          Pizza: Choice   <NA>          <NA>     yes
      45      I07                          Pizza: Choice   <NA>          <NA>     yes
      46      I07                          Pizza: Choice   <NA>          <NA>     yes
      47      I07                          Pizza: Choice   <NA>          <NA>     yes
      48      I07                          Pizza: Choice   <NA>          <NA>     yes
      49      I07                          Pizza: Choice   <NA>          <NA>     yes
      50      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      51      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      52      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      53      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      54      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      55      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      80     I12a                  Shapes: Biggest shape   <NA>          <NA>     yes
      81     I12a                  Shapes: Biggest shape   <NA>          <NA>     yes
      82     I12a                  Shapes: Biggest shape   <NA>          <NA>     yes
      83     I12a                  Shapes: Biggest shape   <NA>          <NA>     yes
      84     I12a                  Shapes: Biggest shape   <NA>          <NA>     yes
      85     I12a                  Shapes: Biggest shape   <NA>          <NA>     yes
      86     I12b                  Shapes: Circumference   <NA>          <NA>     yes
      87     I12b                  Shapes: Circumference   <NA>          <NA>     yes
      88     I12b                  Shapes: Circumference   <NA>          <NA>     yes
      89     I12b                  Shapes: Circumference   <NA>          <NA>     yes
      90     I12b                  Shapes: Circumference   <NA>          <NA>     yes
      91     I12b                  Shapes: Circumference   <NA>          <NA>     yes
      92     I12c               Shapes: Size calculation   <NA>          <NA>     yes
      93     I12c               Shapes: Size calculation   <NA>          <NA>     yes
      94     I12c               Shapes: Size calculation   <NA>          <NA>     yes
      95     I12c               Shapes: Size calculation   <NA>          <NA>     yes
      96     I12c               Shapes: Size calculation   <NA>          <NA>     yes
      97     I12c               Shapes: Size calculation   <NA>          <NA>     yes
      98     I12c               Shapes: Size calculation   <NA>          <NA>     yes
      99     I12c               Shapes: Size calculation   <NA>          <NA>     yes
      100     I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      101     I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      102     I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      103     I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      104     I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      105     I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      106     I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      107     I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      117     I15                Shopping: Number prices   <NA>          <NA>     yes
      118     I15                Shopping: Number prices   <NA>          <NA>     yes
      119     I15                Shopping: Number prices   <NA>          <NA>     yes
      120     I15                Shopping: Number prices   <NA>          <NA>     yes
      121     I15                Shopping: Number prices   <NA>          <NA>     yes
      122     I15                Shopping: Number prices   <NA>          <NA>     yes
      123     I15                Shopping: Number prices   <NA>          <NA>     yes
      124     I15                Shopping: Number prices   <NA>          <NA>     yes
      221      ID                             Student ID   <NA>          <NA>     yes
      222   hisei                                   <NA>   <NA>          <NA>      no
          value                                       valLabel missings
      1       1                       Response option 1 marked    valid
      2       2                       Response option 2 marked    valid
      3       3                       Response option 3 marked    valid
      4       6                            missing not reached     miss
      5       7                              missing by design     miss
      6       8                       missing invalid response     miss
      7       9                           missing by intention     miss
      30      0                                          other    valid
      31      1                     14 mm (units not required)    valid
      32      6                            missing not reached     miss
      33      7                              missing by design     miss
      34      8                       missing invalid response     miss
      35      9                           missing by intention     miss
      36      0                                          other    valid
      37      1                                             39    valid
      38      6                            missing not reached     miss
      39      7                              missing by design     miss
      40      8                       missing invalid response     miss
      41      9                           missing by intention     miss
      42      1                       Response option 1 marked    valid
      43      2                       Response option 2 marked    valid
      44      3                       Response option 3 marked    valid
      45      4                       Response option 4 marked    valid
      46      6                            missing not reached     miss
      47      7                              missing by design     miss
      48      8                       missing invalid response     miss
      49      9                           missing by intention     miss
      50      0                                          other    valid
      51      1 Surface area increases more rapidly than price    valid
      52      6                            missing not reached     miss
      53      7                              missing by design     miss
      54      8                       missing invalid response     miss
      55      9                           missing by intention     miss
      80      0                                          other    valid
      81      1   Shape B, supported with plausible reasoning.    valid
      82      6                            missing not reached     miss
      83      7                              missing by design     miss
      84      8                       missing invalid response     miss
      85      9                           missing by intention     miss
      86      0                                          other    valid
      87      1               22.9 metres (units not required)    valid
      88      6                            missing not reached     miss
      89      7                              missing by design     miss
      90      8                       missing invalid response     miss
      91      9                           missing by intention     miss
      92      1                       Response option 1 marked    valid
      93      2                       Response option 2 marked    valid
      94      3                       Response option 3 marked    valid
      95      4                       Response option 4 marked    valid
      96      6                            missing not reached     miss
      97      7                              missing by design     miss
      98      8                       missing invalid response     miss
      99      9                           missing by intention     miss
      100     1                       Response option 1 marked    valid
      101     2                       Response option 2 marked    valid
      102     3                       Response option 3 marked    valid
      103     4                       Response option 4 marked    valid
      104     6                            missing not reached     miss
      105     7                              missing by design     miss
      106     8                       missing invalid response     miss
      107     9                           missing by intention     miss
      117     1                       Response option 1 marked    valid
      118     2                       Response option 2 marked    valid
      119     3                       Response option 3 marked    valid
      120     4                       Response option 4 marked    valid
      121     6                            missing not reached     miss
      122     7                              missing by design     miss
      123     8                       missing invalid response     miss
      124     9                           missing by intention     miss
      221    NA                                           <NA>     <NA>
      222    NA                                           <NA>     <NA>
      
      attr(,"class")
      [1] "GADSdat" "list"   

# check whether mbd-specification via misTypes works (when no info in in values-sheet) [plain]

    Code
      prep2GADS(dat = preparedData2, inputList = inputList1[1:3], trafoType = "raw",
      verbose = TRUE)
    Message
      
      -- Check: Variables without info 
      i The following 1 variable is not in inputList ($subunits$subunit or
      $units$unit) but in dataset, its meta data will be set to NA: `hisei`
    Output
      $dat
               ID hisei I01 I05 I06 I07 I08 I12a I12b I12c I13 I15
      1 person100    49   1   0   0   2   0   NA   NA   NA  NA  NA
      2 person101    NA   9   0   9   2   1   NA   NA   NA  NA  NA
      3 person200    69  NA  NA  NA  NA   0    1    1    4   4  NA
      4 person201    76  NA  NA  NA  NA   0    0    0    3   2  NA
      5 person300    49   2   0   9   8  NA   NA   NA   NA  NA   3
      6 person301    NA   3   1   1   2  NA   NA   NA   NA  NA   9
      
      $labels
          varName                               varLabel format display_width labeled
      1       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      2       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      3       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      4       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      5       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      6       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      26      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      27      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      28      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      29      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      30      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      31      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      32      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      33      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      34      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      35      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      36      I07                          Pizza: Choice   <NA>          <NA>     yes
      37      I07                          Pizza: Choice   <NA>          <NA>     yes
      38      I07                          Pizza: Choice   <NA>          <NA>     yes
      39      I07                          Pizza: Choice   <NA>          <NA>     yes
      40      I07                          Pizza: Choice   <NA>          <NA>     yes
      41      I07                          Pizza: Choice   <NA>          <NA>     yes
      42      I07                          Pizza: Choice   <NA>          <NA>     yes
      43      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      44      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      45      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      46      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      47      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      69     I12a                  Shapes: Biggest shape   <NA>          <NA>     yes
      70     I12a                  Shapes: Biggest shape   <NA>          <NA>     yes
      71     I12a                  Shapes: Biggest shape   <NA>          <NA>     yes
      72     I12a                  Shapes: Biggest shape   <NA>          <NA>     yes
      73     I12a                  Shapes: Biggest shape   <NA>          <NA>     yes
      74     I12b                  Shapes: Circumference   <NA>          <NA>     yes
      75     I12b                  Shapes: Circumference   <NA>          <NA>     yes
      76     I12b                  Shapes: Circumference   <NA>          <NA>     yes
      77     I12b                  Shapes: Circumference   <NA>          <NA>     yes
      78     I12b                  Shapes: Circumference   <NA>          <NA>     yes
      79     I12c               Shapes: Size calculation   <NA>          <NA>     yes
      80     I12c               Shapes: Size calculation   <NA>          <NA>     yes
      81     I12c               Shapes: Size calculation   <NA>          <NA>     yes
      82     I12c               Shapes: Size calculation   <NA>          <NA>     yes
      83     I12c               Shapes: Size calculation   <NA>          <NA>     yes
      84     I12c               Shapes: Size calculation   <NA>          <NA>     yes
      85     I12c               Shapes: Size calculation   <NA>          <NA>     yes
      86      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      87      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      88      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      89      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      90      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      91      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      92      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      102     I15                Shopping: Number prices   <NA>          <NA>     yes
      103     I15                Shopping: Number prices   <NA>          <NA>     yes
      104     I15                Shopping: Number prices   <NA>          <NA>     yes
      105     I15                Shopping: Number prices   <NA>          <NA>     yes
      106     I15                Shopping: Number prices   <NA>          <NA>     yes
      107     I15                Shopping: Number prices   <NA>          <NA>     yes
      108     I15                Shopping: Number prices   <NA>          <NA>     yes
      192      ID                             Student ID   <NA>          <NA>     yes
      193   hisei                                   <NA>   <NA>          <NA>      no
          value                                       valLabel missings
      1       1                       Response option 1 marked    valid
      2       2                       Response option 2 marked    valid
      3       3                       Response option 3 marked    valid
      4       6                            missing not reached     miss
      5       8                       missing invalid response     miss
      6       9                           missing by intention     miss
      26      0                                          other    valid
      27      1                     14 mm (units not required)    valid
      28      6                            missing not reached     miss
      29      8                       missing invalid response     miss
      30      9                           missing by intention     miss
      31      0                                          other    valid
      32      1                                             39    valid
      33      6                            missing not reached     miss
      34      8                       missing invalid response     miss
      35      9                           missing by intention     miss
      36      1                       Response option 1 marked    valid
      37      2                       Response option 2 marked    valid
      38      3                       Response option 3 marked    valid
      39      4                       Response option 4 marked    valid
      40      6                            missing not reached     miss
      41      8                       missing invalid response     miss
      42      9                           missing by intention     miss
      43      0                                          other    valid
      44      1 Surface area increases more rapidly than price    valid
      45      6                            missing not reached     miss
      46      8                       missing invalid response     miss
      47      9                           missing by intention     miss
      69      0                                          other    valid
      70      1   Shape B, supported with plausible reasoning.    valid
      71      6                            missing not reached     miss
      72      8                       missing invalid response     miss
      73      9                           missing by intention     miss
      74      0                                          other    valid
      75      1               22.9 metres (units not required)    valid
      76      6                            missing not reached     miss
      77      8                       missing invalid response     miss
      78      9                           missing by intention     miss
      79      1                       Response option 1 marked    valid
      80      2                       Response option 2 marked    valid
      81      3                       Response option 3 marked    valid
      82      4                       Response option 4 marked    valid
      83      6                            missing not reached     miss
      84      8                       missing invalid response     miss
      85      9                           missing by intention     miss
      86      1                       Response option 1 marked    valid
      87      2                       Response option 2 marked    valid
      88      3                       Response option 3 marked    valid
      89      4                       Response option 4 marked    valid
      90      6                            missing not reached     miss
      91      8                       missing invalid response     miss
      92      9                           missing by intention     miss
      102     1                       Response option 1 marked    valid
      103     2                       Response option 2 marked    valid
      104     3                       Response option 3 marked    valid
      105     4                       Response option 4 marked    valid
      106     6                            missing not reached     miss
      107     8                       missing invalid response     miss
      108     9                           missing by intention     miss
      192    NA                                           <NA>     <NA>
      193    NA                                           <NA>     <NA>
      
      attr(,"class")
      [1] "GADSdat" "list"   

# check whether mbd-specification via misTypes works (when no info in in values-sheet) [ansi]

    Code
      prep2GADS(dat = preparedData2, inputList = inputList1[1:3], trafoType = "raw",
      verbose = TRUE)
    Message
      
      -- [1m[1mCheck:[1m[22m Variables without info 
      [36mi[39m The following 1 variable is not in inputList ([32m$subunits$subunit[39m or
      [32m$units$unit[39m) but in dataset, its meta data will be set to NA: `hisei`
    Output
      $dat
               ID hisei I01 I05 I06 I07 I08 I12a I12b I12c I13 I15
      1 person100    49   1   0   0   2   0   NA   NA   NA  NA  NA
      2 person101    NA   9   0   9   2   1   NA   NA   NA  NA  NA
      3 person200    69  NA  NA  NA  NA   0    1    1    4   4  NA
      4 person201    76  NA  NA  NA  NA   0    0    0    3   2  NA
      5 person300    49   2   0   9   8  NA   NA   NA   NA  NA   3
      6 person301    NA   3   1   1   2  NA   NA   NA   NA  NA   9
      
      $labels
          varName                               varLabel format display_width labeled
      1       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      2       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      3       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      4       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      5       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      6       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      26      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      27      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      28      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      29      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      30      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      31      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      32      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      33      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      34      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      35      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      36      I07                          Pizza: Choice   <NA>          <NA>     yes
      37      I07                          Pizza: Choice   <NA>          <NA>     yes
      38      I07                          Pizza: Choice   <NA>          <NA>     yes
      39      I07                          Pizza: Choice   <NA>          <NA>     yes
      40      I07                          Pizza: Choice   <NA>          <NA>     yes
      41      I07                          Pizza: Choice   <NA>          <NA>     yes
      42      I07                          Pizza: Choice   <NA>          <NA>     yes
      43      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      44      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      45      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      46      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      47      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      69     I12a                  Shapes: Biggest shape   <NA>          <NA>     yes
      70     I12a                  Shapes: Biggest shape   <NA>          <NA>     yes
      71     I12a                  Shapes: Biggest shape   <NA>          <NA>     yes
      72     I12a                  Shapes: Biggest shape   <NA>          <NA>     yes
      73     I12a                  Shapes: Biggest shape   <NA>          <NA>     yes
      74     I12b                  Shapes: Circumference   <NA>          <NA>     yes
      75     I12b                  Shapes: Circumference   <NA>          <NA>     yes
      76     I12b                  Shapes: Circumference   <NA>          <NA>     yes
      77     I12b                  Shapes: Circumference   <NA>          <NA>     yes
      78     I12b                  Shapes: Circumference   <NA>          <NA>     yes
      79     I12c               Shapes: Size calculation   <NA>          <NA>     yes
      80     I12c               Shapes: Size calculation   <NA>          <NA>     yes
      81     I12c               Shapes: Size calculation   <NA>          <NA>     yes
      82     I12c               Shapes: Size calculation   <NA>          <NA>     yes
      83     I12c               Shapes: Size calculation   <NA>          <NA>     yes
      84     I12c               Shapes: Size calculation   <NA>          <NA>     yes
      85     I12c               Shapes: Size calculation   <NA>          <NA>     yes
      86      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      87      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      88      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      89      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      90      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      91      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      92      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      102     I15                Shopping: Number prices   <NA>          <NA>     yes
      103     I15                Shopping: Number prices   <NA>          <NA>     yes
      104     I15                Shopping: Number prices   <NA>          <NA>     yes
      105     I15                Shopping: Number prices   <NA>          <NA>     yes
      106     I15                Shopping: Number prices   <NA>          <NA>     yes
      107     I15                Shopping: Number prices   <NA>          <NA>     yes
      108     I15                Shopping: Number prices   <NA>          <NA>     yes
      192      ID                             Student ID   <NA>          <NA>     yes
      193   hisei                                   <NA>   <NA>          <NA>      no
          value                                       valLabel missings
      1       1                       Response option 1 marked    valid
      2       2                       Response option 2 marked    valid
      3       3                       Response option 3 marked    valid
      4       6                            missing not reached     miss
      5       8                       missing invalid response     miss
      6       9                           missing by intention     miss
      26      0                                          other    valid
      27      1                     14 mm (units not required)    valid
      28      6                            missing not reached     miss
      29      8                       missing invalid response     miss
      30      9                           missing by intention     miss
      31      0                                          other    valid
      32      1                                             39    valid
      33      6                            missing not reached     miss
      34      8                       missing invalid response     miss
      35      9                           missing by intention     miss
      36      1                       Response option 1 marked    valid
      37      2                       Response option 2 marked    valid
      38      3                       Response option 3 marked    valid
      39      4                       Response option 4 marked    valid
      40      6                            missing not reached     miss
      41      8                       missing invalid response     miss
      42      9                           missing by intention     miss
      43      0                                          other    valid
      44      1 Surface area increases more rapidly than price    valid
      45      6                            missing not reached     miss
      46      8                       missing invalid response     miss
      47      9                           missing by intention     miss
      69      0                                          other    valid
      70      1   Shape B, supported with plausible reasoning.    valid
      71      6                            missing not reached     miss
      72      8                       missing invalid response     miss
      73      9                           missing by intention     miss
      74      0                                          other    valid
      75      1               22.9 metres (units not required)    valid
      76      6                            missing not reached     miss
      77      8                       missing invalid response     miss
      78      9                           missing by intention     miss
      79      1                       Response option 1 marked    valid
      80      2                       Response option 2 marked    valid
      81      3                       Response option 3 marked    valid
      82      4                       Response option 4 marked    valid
      83      6                            missing not reached     miss
      84      8                       missing invalid response     miss
      85      9                           missing by intention     miss
      86      1                       Response option 1 marked    valid
      87      2                       Response option 2 marked    valid
      88      3                       Response option 3 marked    valid
      89      4                       Response option 4 marked    valid
      90      6                            missing not reached     miss
      91      8                       missing invalid response     miss
      92      9                           missing by intention     miss
      102     1                       Response option 1 marked    valid
      103     2                       Response option 2 marked    valid
      104     3                       Response option 3 marked    valid
      105     4                       Response option 4 marked    valid
      106     6                            missing not reached     miss
      107     8                       missing invalid response     miss
      108     9                           missing by intention     miss
      192    NA                                           <NA>     <NA>
      193    NA                                           <NA>     <NA>
      
      attr(,"class")
      [1] "GADSdat" "list"   

# check whether mbd-specification via misTypes works (when no info in in values-sheet) [unicode]

    Code
      prep2GADS(dat = preparedData2, inputList = inputList1[1:3], trafoType = "raw",
      verbose = TRUE)
    Message
      
      ── Check: Variables without info 
      ℹ The following 1 variable is not in inputList ($subunits$subunit or
      $units$unit) but in dataset, its meta data will be set to NA: `hisei`
    Output
      $dat
               ID hisei I01 I05 I06 I07 I08 I12a I12b I12c I13 I15
      1 person100    49   1   0   0   2   0   NA   NA   NA  NA  NA
      2 person101    NA   9   0   9   2   1   NA   NA   NA  NA  NA
      3 person200    69  NA  NA  NA  NA   0    1    1    4   4  NA
      4 person201    76  NA  NA  NA  NA   0    0    0    3   2  NA
      5 person300    49   2   0   9   8  NA   NA   NA   NA  NA   3
      6 person301    NA   3   1   1   2  NA   NA   NA   NA  NA   9
      
      $labels
          varName                               varLabel format display_width labeled
      1       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      2       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      3       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      4       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      5       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      6       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      26      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      27      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      28      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      29      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      30      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      31      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      32      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      33      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      34      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      35      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      36      I07                          Pizza: Choice   <NA>          <NA>     yes
      37      I07                          Pizza: Choice   <NA>          <NA>     yes
      38      I07                          Pizza: Choice   <NA>          <NA>     yes
      39      I07                          Pizza: Choice   <NA>          <NA>     yes
      40      I07                          Pizza: Choice   <NA>          <NA>     yes
      41      I07                          Pizza: Choice   <NA>          <NA>     yes
      42      I07                          Pizza: Choice   <NA>          <NA>     yes
      43      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      44      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      45      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      46      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      47      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      69     I12a                  Shapes: Biggest shape   <NA>          <NA>     yes
      70     I12a                  Shapes: Biggest shape   <NA>          <NA>     yes
      71     I12a                  Shapes: Biggest shape   <NA>          <NA>     yes
      72     I12a                  Shapes: Biggest shape   <NA>          <NA>     yes
      73     I12a                  Shapes: Biggest shape   <NA>          <NA>     yes
      74     I12b                  Shapes: Circumference   <NA>          <NA>     yes
      75     I12b                  Shapes: Circumference   <NA>          <NA>     yes
      76     I12b                  Shapes: Circumference   <NA>          <NA>     yes
      77     I12b                  Shapes: Circumference   <NA>          <NA>     yes
      78     I12b                  Shapes: Circumference   <NA>          <NA>     yes
      79     I12c               Shapes: Size calculation   <NA>          <NA>     yes
      80     I12c               Shapes: Size calculation   <NA>          <NA>     yes
      81     I12c               Shapes: Size calculation   <NA>          <NA>     yes
      82     I12c               Shapes: Size calculation   <NA>          <NA>     yes
      83     I12c               Shapes: Size calculation   <NA>          <NA>     yes
      84     I12c               Shapes: Size calculation   <NA>          <NA>     yes
      85     I12c               Shapes: Size calculation   <NA>          <NA>     yes
      86      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      87      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      88      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      89      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      90      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      91      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      92      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      102     I15                Shopping: Number prices   <NA>          <NA>     yes
      103     I15                Shopping: Number prices   <NA>          <NA>     yes
      104     I15                Shopping: Number prices   <NA>          <NA>     yes
      105     I15                Shopping: Number prices   <NA>          <NA>     yes
      106     I15                Shopping: Number prices   <NA>          <NA>     yes
      107     I15                Shopping: Number prices   <NA>          <NA>     yes
      108     I15                Shopping: Number prices   <NA>          <NA>     yes
      192      ID                             Student ID   <NA>          <NA>     yes
      193   hisei                                   <NA>   <NA>          <NA>      no
          value                                       valLabel missings
      1       1                       Response option 1 marked    valid
      2       2                       Response option 2 marked    valid
      3       3                       Response option 3 marked    valid
      4       6                            missing not reached     miss
      5       8                       missing invalid response     miss
      6       9                           missing by intention     miss
      26      0                                          other    valid
      27      1                     14 mm (units not required)    valid
      28      6                            missing not reached     miss
      29      8                       missing invalid response     miss
      30      9                           missing by intention     miss
      31      0                                          other    valid
      32      1                                             39    valid
      33      6                            missing not reached     miss
      34      8                       missing invalid response     miss
      35      9                           missing by intention     miss
      36      1                       Response option 1 marked    valid
      37      2                       Response option 2 marked    valid
      38      3                       Response option 3 marked    valid
      39      4                       Response option 4 marked    valid
      40      6                            missing not reached     miss
      41      8                       missing invalid response     miss
      42      9                           missing by intention     miss
      43      0                                          other    valid
      44      1 Surface area increases more rapidly than price    valid
      45      6                            missing not reached     miss
      46      8                       missing invalid response     miss
      47      9                           missing by intention     miss
      69      0                                          other    valid
      70      1   Shape B, supported with plausible reasoning.    valid
      71      6                            missing not reached     miss
      72      8                       missing invalid response     miss
      73      9                           missing by intention     miss
      74      0                                          other    valid
      75      1               22.9 metres (units not required)    valid
      76      6                            missing not reached     miss
      77      8                       missing invalid response     miss
      78      9                           missing by intention     miss
      79      1                       Response option 1 marked    valid
      80      2                       Response option 2 marked    valid
      81      3                       Response option 3 marked    valid
      82      4                       Response option 4 marked    valid
      83      6                            missing not reached     miss
      84      8                       missing invalid response     miss
      85      9                           missing by intention     miss
      86      1                       Response option 1 marked    valid
      87      2                       Response option 2 marked    valid
      88      3                       Response option 3 marked    valid
      89      4                       Response option 4 marked    valid
      90      6                            missing not reached     miss
      91      8                       missing invalid response     miss
      92      9                           missing by intention     miss
      102     1                       Response option 1 marked    valid
      103     2                       Response option 2 marked    valid
      104     3                       Response option 3 marked    valid
      105     4                       Response option 4 marked    valid
      106     6                            missing not reached     miss
      107     8                       missing invalid response     miss
      108     9                           missing by intention     miss
      192    NA                                           <NA>     <NA>
      193    NA                                           <NA>     <NA>
      
      attr(,"class")
      [1] "GADSdat" "list"   

# check whether mbd-specification via misTypes works (when no info in in values-sheet) [fancy]

    Code
      prep2GADS(dat = preparedData2, inputList = inputList1[1:3], trafoType = "raw",
      verbose = TRUE)
    Message
      
      ── [1m[1mCheck:[1m[22m Variables without info 
      [36mℹ[39m The following 1 variable is not in inputList ([32m$subunits$subunit[39m or
      [32m$units$unit[39m) but in dataset, its meta data will be set to NA: `hisei`
    Output
      $dat
               ID hisei I01 I05 I06 I07 I08 I12a I12b I12c I13 I15
      1 person100    49   1   0   0   2   0   NA   NA   NA  NA  NA
      2 person101    NA   9   0   9   2   1   NA   NA   NA  NA  NA
      3 person200    69  NA  NA  NA  NA   0    1    1    4   4  NA
      4 person201    76  NA  NA  NA  NA   0    0    0    3   2  NA
      5 person300    49   2   0   9   8  NA   NA   NA   NA  NA   3
      6 person301    NA   3   1   1   2  NA   NA   NA   NA  NA   9
      
      $labels
          varName                               varLabel format display_width labeled
      1       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      2       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      3       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      4       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      5       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      6       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      26      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      27      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      28      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      29      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      30      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      31      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      32      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      33      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      34      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      35      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      36      I07                          Pizza: Choice   <NA>          <NA>     yes
      37      I07                          Pizza: Choice   <NA>          <NA>     yes
      38      I07                          Pizza: Choice   <NA>          <NA>     yes
      39      I07                          Pizza: Choice   <NA>          <NA>     yes
      40      I07                          Pizza: Choice   <NA>          <NA>     yes
      41      I07                          Pizza: Choice   <NA>          <NA>     yes
      42      I07                          Pizza: Choice   <NA>          <NA>     yes
      43      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      44      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      45      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      46      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      47      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      69     I12a                  Shapes: Biggest shape   <NA>          <NA>     yes
      70     I12a                  Shapes: Biggest shape   <NA>          <NA>     yes
      71     I12a                  Shapes: Biggest shape   <NA>          <NA>     yes
      72     I12a                  Shapes: Biggest shape   <NA>          <NA>     yes
      73     I12a                  Shapes: Biggest shape   <NA>          <NA>     yes
      74     I12b                  Shapes: Circumference   <NA>          <NA>     yes
      75     I12b                  Shapes: Circumference   <NA>          <NA>     yes
      76     I12b                  Shapes: Circumference   <NA>          <NA>     yes
      77     I12b                  Shapes: Circumference   <NA>          <NA>     yes
      78     I12b                  Shapes: Circumference   <NA>          <NA>     yes
      79     I12c               Shapes: Size calculation   <NA>          <NA>     yes
      80     I12c               Shapes: Size calculation   <NA>          <NA>     yes
      81     I12c               Shapes: Size calculation   <NA>          <NA>     yes
      82     I12c               Shapes: Size calculation   <NA>          <NA>     yes
      83     I12c               Shapes: Size calculation   <NA>          <NA>     yes
      84     I12c               Shapes: Size calculation   <NA>          <NA>     yes
      85     I12c               Shapes: Size calculation   <NA>          <NA>     yes
      86      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      87      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      88      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      89      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      90      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      91      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      92      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      102     I15                Shopping: Number prices   <NA>          <NA>     yes
      103     I15                Shopping: Number prices   <NA>          <NA>     yes
      104     I15                Shopping: Number prices   <NA>          <NA>     yes
      105     I15                Shopping: Number prices   <NA>          <NA>     yes
      106     I15                Shopping: Number prices   <NA>          <NA>     yes
      107     I15                Shopping: Number prices   <NA>          <NA>     yes
      108     I15                Shopping: Number prices   <NA>          <NA>     yes
      192      ID                             Student ID   <NA>          <NA>     yes
      193   hisei                                   <NA>   <NA>          <NA>      no
          value                                       valLabel missings
      1       1                       Response option 1 marked    valid
      2       2                       Response option 2 marked    valid
      3       3                       Response option 3 marked    valid
      4       6                            missing not reached     miss
      5       8                       missing invalid response     miss
      6       9                           missing by intention     miss
      26      0                                          other    valid
      27      1                     14 mm (units not required)    valid
      28      6                            missing not reached     miss
      29      8                       missing invalid response     miss
      30      9                           missing by intention     miss
      31      0                                          other    valid
      32      1                                             39    valid
      33      6                            missing not reached     miss
      34      8                       missing invalid response     miss
      35      9                           missing by intention     miss
      36      1                       Response option 1 marked    valid
      37      2                       Response option 2 marked    valid
      38      3                       Response option 3 marked    valid
      39      4                       Response option 4 marked    valid
      40      6                            missing not reached     miss
      41      8                       missing invalid response     miss
      42      9                           missing by intention     miss
      43      0                                          other    valid
      44      1 Surface area increases more rapidly than price    valid
      45      6                            missing not reached     miss
      46      8                       missing invalid response     miss
      47      9                           missing by intention     miss
      69      0                                          other    valid
      70      1   Shape B, supported with plausible reasoning.    valid
      71      6                            missing not reached     miss
      72      8                       missing invalid response     miss
      73      9                           missing by intention     miss
      74      0                                          other    valid
      75      1               22.9 metres (units not required)    valid
      76      6                            missing not reached     miss
      77      8                       missing invalid response     miss
      78      9                           missing by intention     miss
      79      1                       Response option 1 marked    valid
      80      2                       Response option 2 marked    valid
      81      3                       Response option 3 marked    valid
      82      4                       Response option 4 marked    valid
      83      6                            missing not reached     miss
      84      8                       missing invalid response     miss
      85      9                           missing by intention     miss
      86      1                       Response option 1 marked    valid
      87      2                       Response option 2 marked    valid
      88      3                       Response option 3 marked    valid
      89      4                       Response option 4 marked    valid
      90      6                            missing not reached     miss
      91      8                       missing invalid response     miss
      92      9                           missing by intention     miss
      102     1                       Response option 1 marked    valid
      103     2                       Response option 2 marked    valid
      104     3                       Response option 3 marked    valid
      105     4                       Response option 4 marked    valid
      106     6                            missing not reached     miss
      107     8                       missing invalid response     miss
      108     9                           missing by intention     miss
      192    NA                                           <NA>     <NA>
      193    NA                                           <NA>     <NA>
      
      attr(,"class")
      [1] "GADSdat" "list"   

# check whether no mbd-specification gives message [plain]

    Code
      prep2GADS(dat = preparedData, inputList = inputList1[1:3], trafoType = "raw",
      misTypes = list(mci = -97), verbose = TRUE)
    Message
      i Data contains 'mbd' but no clear backtransformation raw value could be identified (please specify via misTypes). Thus 'mbd' will be kept as string.
      
      -- Check: Variables without info 
      i The following 2 variables are not in inputList ($subunits$subunit or
      $units$unit) but in dataset, their meta data will be set to NA: `booklet` and
      `hisei`
    Output
      $dat
               ID  booklet hisei I01 I05 I06 I07 I08 I13 I15 I12
      1 person100 booklet1    49   0   0   0   0   0 mbd mbd mbd
      2 person101 booklet1    NA mbi   0 mbi   0   1 mbd mbd mbd
      3 person200 booklet2    69 mbd mbd mbd mbd   0   0 mbd   1
      4 person201 booklet2    76 mbd mbd mbd mbd   0   1 mbd   0
      5 person300 booklet3    49   0   0 mbi mir mbd mbd   0 mbd
      6 person301 booklet3    NA   1   1   1   0 mbd mbd mbi mbd
      
      $labels
          varName                               varLabel format display_width labeled
      1       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      2       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      3       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      4       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      5       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      6       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      26      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      27      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      28      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      29      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      30      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      31      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      32      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      33      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      34      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      35      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      36      I07                          Pizza: Choice   <NA>          <NA>     yes
      37      I07                          Pizza: Choice   <NA>          <NA>     yes
      38      I07                          Pizza: Choice   <NA>          <NA>     yes
      39      I07                          Pizza: Choice   <NA>          <NA>     yes
      40      I07                          Pizza: Choice   <NA>          <NA>     yes
      41      I07                          Pizza: Choice   <NA>          <NA>     yes
      42      I07                          Pizza: Choice   <NA>          <NA>     yes
      43      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      44      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      45      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      46      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      47      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      86      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      87      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      88      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      89      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      90      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      91      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      92      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      102     I15                Shopping: Number prices   <NA>          <NA>     yes
      103     I15                Shopping: Number prices   <NA>          <NA>     yes
      104     I15                Shopping: Number prices   <NA>          <NA>     yes
      105     I15                Shopping: Number prices   <NA>          <NA>     yes
      106     I15                Shopping: Number prices   <NA>          <NA>     yes
      107     I15                Shopping: Number prices   <NA>          <NA>     yes
      108     I15                Shopping: Number prices   <NA>          <NA>     yes
      192      ID                             Student ID   <NA>          <NA>     yes
      193 booklet                                   <NA>   <NA>          <NA>      no
      194   hisei                                   <NA>   <NA>          <NA>      no
      195     I12                                 Shapes   <NA>          <NA>     yes
          value                                       valLabel missings
      1       1                       Response option 1 marked    valid
      2       2                       Response option 2 marked    valid
      3       3                       Response option 3 marked    valid
      4       6                            missing not reached     miss
      5       8                       missing invalid response     miss
      6       9                           missing by intention     miss
      26      0                                          other    valid
      27      1                     14 mm (units not required)    valid
      28      6                            missing not reached     miss
      29      8                       missing invalid response     miss
      30      9                           missing by intention     miss
      31      0                                          other    valid
      32      1                                             39    valid
      33      6                            missing not reached     miss
      34      8                       missing invalid response     miss
      35      9                           missing by intention     miss
      36      1                       Response option 1 marked    valid
      37      2                       Response option 2 marked    valid
      38      3                       Response option 3 marked    valid
      39      4                       Response option 4 marked    valid
      40      6                            missing not reached     miss
      41      8                       missing invalid response     miss
      42      9                           missing by intention     miss
      43      0                                          other    valid
      44      1 Surface area increases more rapidly than price    valid
      45      6                            missing not reached     miss
      46      8                       missing invalid response     miss
      47      9                           missing by intention     miss
      86      1                       Response option 1 marked    valid
      87      2                       Response option 2 marked    valid
      88      3                       Response option 3 marked    valid
      89      4                       Response option 4 marked    valid
      90      6                            missing not reached     miss
      91      8                       missing invalid response     miss
      92      9                           missing by intention     miss
      102     1                       Response option 1 marked    valid
      103     2                       Response option 2 marked    valid
      104     3                       Response option 3 marked    valid
      105     4                       Response option 4 marked    valid
      106     6                            missing not reached     miss
      107     8                       missing invalid response     miss
      108     9                           missing by intention     miss
      192    NA                                           <NA>     <NA>
      193    NA                                           <NA>     <NA>
      194    NA                                           <NA>     <NA>
      195    NA                                           <NA>     <NA>
      
      attr(,"class")
      [1] "GADSdat" "list"   

# check whether no mbd-specification gives message [ansi]

    Code
      prep2GADS(dat = preparedData, inputList = inputList1[1:3], trafoType = "raw",
      misTypes = list(mci = -97), verbose = TRUE)
    Message
      [36mi[39m Data contains 'mbd' but no clear backtransformation raw value could be identified (please specify via misTypes). Thus 'mbd' will be kept as string.
      
      -- [1m[1mCheck:[1m[22m Variables without info 
      [36mi[39m The following 2 variables are not in inputList ([32m$subunits$subunit[39m or
      [32m$units$unit[39m) but in dataset, their meta data will be set to NA: `booklet` and
      `hisei`
    Output
      $dat
               ID  booklet hisei I01 I05 I06 I07 I08 I13 I15 I12
      1 person100 booklet1    49   0   0   0   0   0 mbd mbd mbd
      2 person101 booklet1    NA mbi   0 mbi   0   1 mbd mbd mbd
      3 person200 booklet2    69 mbd mbd mbd mbd   0   0 mbd   1
      4 person201 booklet2    76 mbd mbd mbd mbd   0   1 mbd   0
      5 person300 booklet3    49   0   0 mbi mir mbd mbd   0 mbd
      6 person301 booklet3    NA   1   1   1   0 mbd mbd mbi mbd
      
      $labels
          varName                               varLabel format display_width labeled
      1       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      2       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      3       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      4       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      5       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      6       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      26      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      27      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      28      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      29      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      30      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      31      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      32      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      33      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      34      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      35      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      36      I07                          Pizza: Choice   <NA>          <NA>     yes
      37      I07                          Pizza: Choice   <NA>          <NA>     yes
      38      I07                          Pizza: Choice   <NA>          <NA>     yes
      39      I07                          Pizza: Choice   <NA>          <NA>     yes
      40      I07                          Pizza: Choice   <NA>          <NA>     yes
      41      I07                          Pizza: Choice   <NA>          <NA>     yes
      42      I07                          Pizza: Choice   <NA>          <NA>     yes
      43      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      44      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      45      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      46      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      47      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      86      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      87      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      88      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      89      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      90      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      91      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      92      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      102     I15                Shopping: Number prices   <NA>          <NA>     yes
      103     I15                Shopping: Number prices   <NA>          <NA>     yes
      104     I15                Shopping: Number prices   <NA>          <NA>     yes
      105     I15                Shopping: Number prices   <NA>          <NA>     yes
      106     I15                Shopping: Number prices   <NA>          <NA>     yes
      107     I15                Shopping: Number prices   <NA>          <NA>     yes
      108     I15                Shopping: Number prices   <NA>          <NA>     yes
      192      ID                             Student ID   <NA>          <NA>     yes
      193 booklet                                   <NA>   <NA>          <NA>      no
      194   hisei                                   <NA>   <NA>          <NA>      no
      195     I12                                 Shapes   <NA>          <NA>     yes
          value                                       valLabel missings
      1       1                       Response option 1 marked    valid
      2       2                       Response option 2 marked    valid
      3       3                       Response option 3 marked    valid
      4       6                            missing not reached     miss
      5       8                       missing invalid response     miss
      6       9                           missing by intention     miss
      26      0                                          other    valid
      27      1                     14 mm (units not required)    valid
      28      6                            missing not reached     miss
      29      8                       missing invalid response     miss
      30      9                           missing by intention     miss
      31      0                                          other    valid
      32      1                                             39    valid
      33      6                            missing not reached     miss
      34      8                       missing invalid response     miss
      35      9                           missing by intention     miss
      36      1                       Response option 1 marked    valid
      37      2                       Response option 2 marked    valid
      38      3                       Response option 3 marked    valid
      39      4                       Response option 4 marked    valid
      40      6                            missing not reached     miss
      41      8                       missing invalid response     miss
      42      9                           missing by intention     miss
      43      0                                          other    valid
      44      1 Surface area increases more rapidly than price    valid
      45      6                            missing not reached     miss
      46      8                       missing invalid response     miss
      47      9                           missing by intention     miss
      86      1                       Response option 1 marked    valid
      87      2                       Response option 2 marked    valid
      88      3                       Response option 3 marked    valid
      89      4                       Response option 4 marked    valid
      90      6                            missing not reached     miss
      91      8                       missing invalid response     miss
      92      9                           missing by intention     miss
      102     1                       Response option 1 marked    valid
      103     2                       Response option 2 marked    valid
      104     3                       Response option 3 marked    valid
      105     4                       Response option 4 marked    valid
      106     6                            missing not reached     miss
      107     8                       missing invalid response     miss
      108     9                           missing by intention     miss
      192    NA                                           <NA>     <NA>
      193    NA                                           <NA>     <NA>
      194    NA                                           <NA>     <NA>
      195    NA                                           <NA>     <NA>
      
      attr(,"class")
      [1] "GADSdat" "list"   

# check whether no mbd-specification gives message [unicode]

    Code
      prep2GADS(dat = preparedData, inputList = inputList1[1:3], trafoType = "raw",
      misTypes = list(mci = -97), verbose = TRUE)
    Message
      ℹ Data contains 'mbd' but no clear backtransformation raw value could be identified (please specify via misTypes). Thus 'mbd' will be kept as string.
      
      ── Check: Variables without info 
      ℹ The following 2 variables are not in inputList ($subunits$subunit or
      $units$unit) but in dataset, their meta data will be set to NA: `booklet` and
      `hisei`
    Output
      $dat
               ID  booklet hisei I01 I05 I06 I07 I08 I13 I15 I12
      1 person100 booklet1    49   0   0   0   0   0 mbd mbd mbd
      2 person101 booklet1    NA mbi   0 mbi   0   1 mbd mbd mbd
      3 person200 booklet2    69 mbd mbd mbd mbd   0   0 mbd   1
      4 person201 booklet2    76 mbd mbd mbd mbd   0   1 mbd   0
      5 person300 booklet3    49   0   0 mbi mir mbd mbd   0 mbd
      6 person301 booklet3    NA   1   1   1   0 mbd mbd mbi mbd
      
      $labels
          varName                               varLabel format display_width labeled
      1       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      2       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      3       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      4       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      5       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      6       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      26      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      27      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      28      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      29      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      30      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      31      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      32      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      33      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      34      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      35      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      36      I07                          Pizza: Choice   <NA>          <NA>     yes
      37      I07                          Pizza: Choice   <NA>          <NA>     yes
      38      I07                          Pizza: Choice   <NA>          <NA>     yes
      39      I07                          Pizza: Choice   <NA>          <NA>     yes
      40      I07                          Pizza: Choice   <NA>          <NA>     yes
      41      I07                          Pizza: Choice   <NA>          <NA>     yes
      42      I07                          Pizza: Choice   <NA>          <NA>     yes
      43      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      44      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      45      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      46      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      47      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      86      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      87      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      88      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      89      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      90      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      91      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      92      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      102     I15                Shopping: Number prices   <NA>          <NA>     yes
      103     I15                Shopping: Number prices   <NA>          <NA>     yes
      104     I15                Shopping: Number prices   <NA>          <NA>     yes
      105     I15                Shopping: Number prices   <NA>          <NA>     yes
      106     I15                Shopping: Number prices   <NA>          <NA>     yes
      107     I15                Shopping: Number prices   <NA>          <NA>     yes
      108     I15                Shopping: Number prices   <NA>          <NA>     yes
      192      ID                             Student ID   <NA>          <NA>     yes
      193 booklet                                   <NA>   <NA>          <NA>      no
      194   hisei                                   <NA>   <NA>          <NA>      no
      195     I12                                 Shapes   <NA>          <NA>     yes
          value                                       valLabel missings
      1       1                       Response option 1 marked    valid
      2       2                       Response option 2 marked    valid
      3       3                       Response option 3 marked    valid
      4       6                            missing not reached     miss
      5       8                       missing invalid response     miss
      6       9                           missing by intention     miss
      26      0                                          other    valid
      27      1                     14 mm (units not required)    valid
      28      6                            missing not reached     miss
      29      8                       missing invalid response     miss
      30      9                           missing by intention     miss
      31      0                                          other    valid
      32      1                                             39    valid
      33      6                            missing not reached     miss
      34      8                       missing invalid response     miss
      35      9                           missing by intention     miss
      36      1                       Response option 1 marked    valid
      37      2                       Response option 2 marked    valid
      38      3                       Response option 3 marked    valid
      39      4                       Response option 4 marked    valid
      40      6                            missing not reached     miss
      41      8                       missing invalid response     miss
      42      9                           missing by intention     miss
      43      0                                          other    valid
      44      1 Surface area increases more rapidly than price    valid
      45      6                            missing not reached     miss
      46      8                       missing invalid response     miss
      47      9                           missing by intention     miss
      86      1                       Response option 1 marked    valid
      87      2                       Response option 2 marked    valid
      88      3                       Response option 3 marked    valid
      89      4                       Response option 4 marked    valid
      90      6                            missing not reached     miss
      91      8                       missing invalid response     miss
      92      9                           missing by intention     miss
      102     1                       Response option 1 marked    valid
      103     2                       Response option 2 marked    valid
      104     3                       Response option 3 marked    valid
      105     4                       Response option 4 marked    valid
      106     6                            missing not reached     miss
      107     8                       missing invalid response     miss
      108     9                           missing by intention     miss
      192    NA                                           <NA>     <NA>
      193    NA                                           <NA>     <NA>
      194    NA                                           <NA>     <NA>
      195    NA                                           <NA>     <NA>
      
      attr(,"class")
      [1] "GADSdat" "list"   

# check whether no mbd-specification gives message [fancy]

    Code
      prep2GADS(dat = preparedData, inputList = inputList1[1:3], trafoType = "raw",
      misTypes = list(mci = -97), verbose = TRUE)
    Message
      [36mℹ[39m Data contains 'mbd' but no clear backtransformation raw value could be identified (please specify via misTypes). Thus 'mbd' will be kept as string.
      
      ── [1m[1mCheck:[1m[22m Variables without info 
      [36mℹ[39m The following 2 variables are not in inputList ([32m$subunits$subunit[39m or
      [32m$units$unit[39m) but in dataset, their meta data will be set to NA: `booklet` and
      `hisei`
    Output
      $dat
               ID  booklet hisei I01 I05 I06 I07 I08 I13 I15 I12
      1 person100 booklet1    49   0   0   0   0   0 mbd mbd mbd
      2 person101 booklet1    NA mbi   0 mbi   0   1 mbd mbd mbd
      3 person200 booklet2    69 mbd mbd mbd mbd   0   0 mbd   1
      4 person201 booklet2    76 mbd mbd mbd mbd   0   1 mbd   0
      5 person300 booklet3    49   0   0 mbi mir mbd mbd   0 mbd
      6 person301 booklet3    NA   1   1   1   0 mbd mbd mbi mbd
      
      $labels
          varName                               varLabel format display_width labeled
      1       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      2       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      3       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      4       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      5       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      6       I01              Animals: Weight of a duck   <NA>          <NA>     yes
      26      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      27      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      28      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      29      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      30      I05                    Conversion: 0.14 cm   <NA>          <NA>     yes
      31      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      32      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      33      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      34      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      35      I06        MissingNumber: 13 - 26 - x - 52   <NA>          <NA>     yes
      36      I07                          Pizza: Choice   <NA>          <NA>     yes
      37      I07                          Pizza: Choice   <NA>          <NA>     yes
      38      I07                          Pizza: Choice   <NA>          <NA>     yes
      39      I07                          Pizza: Choice   <NA>          <NA>     yes
      40      I07                          Pizza: Choice   <NA>          <NA>     yes
      41      I07                          Pizza: Choice   <NA>          <NA>     yes
      42      I07                          Pizza: Choice   <NA>          <NA>     yes
      43      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      44      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      45      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      46      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      47      I08            Pizza: Reasoning for choice   <NA>          <NA>     yes
      86      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      87      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      88      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      89      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      90      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      91      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      92      I13 Sweets: How many possibilities to hide   <NA>          <NA>     yes
      102     I15                Shopping: Number prices   <NA>          <NA>     yes
      103     I15                Shopping: Number prices   <NA>          <NA>     yes
      104     I15                Shopping: Number prices   <NA>          <NA>     yes
      105     I15                Shopping: Number prices   <NA>          <NA>     yes
      106     I15                Shopping: Number prices   <NA>          <NA>     yes
      107     I15                Shopping: Number prices   <NA>          <NA>     yes
      108     I15                Shopping: Number prices   <NA>          <NA>     yes
      192      ID                             Student ID   <NA>          <NA>     yes
      193 booklet                                   <NA>   <NA>          <NA>      no
      194   hisei                                   <NA>   <NA>          <NA>      no
      195     I12                                 Shapes   <NA>          <NA>     yes
          value                                       valLabel missings
      1       1                       Response option 1 marked    valid
      2       2                       Response option 2 marked    valid
      3       3                       Response option 3 marked    valid
      4       6                            missing not reached     miss
      5       8                       missing invalid response     miss
      6       9                           missing by intention     miss
      26      0                                          other    valid
      27      1                     14 mm (units not required)    valid
      28      6                            missing not reached     miss
      29      8                       missing invalid response     miss
      30      9                           missing by intention     miss
      31      0                                          other    valid
      32      1                                             39    valid
      33      6                            missing not reached     miss
      34      8                       missing invalid response     miss
      35      9                           missing by intention     miss
      36      1                       Response option 1 marked    valid
      37      2                       Response option 2 marked    valid
      38      3                       Response option 3 marked    valid
      39      4                       Response option 4 marked    valid
      40      6                            missing not reached     miss
      41      8                       missing invalid response     miss
      42      9                           missing by intention     miss
      43      0                                          other    valid
      44      1 Surface area increases more rapidly than price    valid
      45      6                            missing not reached     miss
      46      8                       missing invalid response     miss
      47      9                           missing by intention     miss
      86      1                       Response option 1 marked    valid
      87      2                       Response option 2 marked    valid
      88      3                       Response option 3 marked    valid
      89      4                       Response option 4 marked    valid
      90      6                            missing not reached     miss
      91      8                       missing invalid response     miss
      92      9                           missing by intention     miss
      102     1                       Response option 1 marked    valid
      103     2                       Response option 2 marked    valid
      104     3                       Response option 3 marked    valid
      105     4                       Response option 4 marked    valid
      106     6                            missing not reached     miss
      107     8                       missing invalid response     miss
      108     9                           missing by intention     miss
      192    NA                                           <NA>     <NA>
      193    NA                                           <NA>     <NA>
      194    NA                                           <NA>     <NA>
      195    NA                                           <NA>     <NA>
      
      attr(,"class")
      [1] "GADSdat" "list"   

