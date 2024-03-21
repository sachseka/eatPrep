# checks for normal output and missing meta data info when scored [plain]

    Code
      prep2gads(dat = preparedData, inputList = inputList[1:3], trafoType = "scored",
      verbose = TRUE)
    Message
      
      -- Check: Variables without info 
      i The following 2 variables are not in inputList ($units$unit) but in dataset,
      their meta data will be set to NA: `booklet` and `hisei`
    Output
      $dat
               ID  booklet hisei I01 I05 I06 I07 I08 I13 I15 I12
      1 person100 booklet1    49   0   0   0   0   0 -94 -94 -94
      2 person101 booklet1   -94 -99   0 -99   0   1 -94 -94 -94
      3 person200 booklet2    69 -94 -94 -94 -94   0   0 -94   1
      4 person201 booklet2    76 -94 -94 -94 -94   0   1 -94   0
      5 person300 booklet3    49   0   0 -99 -98 -94 -94   0 -94
      6 person301 booklet3   -94   1   1   1   0 -94 -94 -99 -94
      
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
      167  <NA>
      168  <NA>
      169  <NA>
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
      

# checks for normal output and missing meta data info when scored [ansi]

    Code
      prep2gads(dat = preparedData, inputList = inputList[1:3], trafoType = "scored",
      verbose = TRUE)
    Message
      
      -- [1m[1mCheck:[1m[22m Variables without info 
      [36mi[39m The following 2 variables are not in inputList ([32m$units$unit[39m) but in dataset,
      their meta data will be set to NA: `booklet` and `hisei`
    Output
      $dat
               ID  booklet hisei I01 I05 I06 I07 I08 I13 I15 I12
      1 person100 booklet1    49   0   0   0   0   0 -94 -94 -94
      2 person101 booklet1   -94 -99   0 -99   0   1 -94 -94 -94
      3 person200 booklet2    69 -94 -94 -94 -94   0   0 -94   1
      4 person201 booklet2    76 -94 -94 -94 -94   0   1 -94   0
      5 person300 booklet3    49   0   0 -99 -98 -94 -94   0 -94
      6 person301 booklet3   -94   1   1   1   0 -94 -94 -99 -94
      
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
      167  <NA>
      168  <NA>
      169  <NA>
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
      

# checks for normal output and missing meta data info when scored [unicode]

    Code
      prep2gads(dat = preparedData, inputList = inputList[1:3], trafoType = "scored",
      verbose = TRUE)
    Message
      
      ── Check: Variables without info 
      ℹ The following 2 variables are not in inputList ($units$unit) but in dataset,
      their meta data will be set to NA: `booklet` and `hisei`
    Output
      $dat
               ID  booklet hisei I01 I05 I06 I07 I08 I13 I15 I12
      1 person100 booklet1    49   0   0   0   0   0 -94 -94 -94
      2 person101 booklet1   -94 -99   0 -99   0   1 -94 -94 -94
      3 person200 booklet2    69 -94 -94 -94 -94   0   0 -94   1
      4 person201 booklet2    76 -94 -94 -94 -94   0   1 -94   0
      5 person300 booklet3    49   0   0 -99 -98 -94 -94   0 -94
      6 person301 booklet3   -94   1   1   1   0 -94 -94 -99 -94
      
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
      167  <NA>
      168  <NA>
      169  <NA>
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
      

# checks for normal output and missing meta data info when scored [fancy]

    Code
      prep2gads(dat = preparedData, inputList = inputList[1:3], trafoType = "scored",
      verbose = TRUE)
    Message
      
      ── [1m[1mCheck:[1m[22m Variables without info 
      [36mℹ[39m The following 2 variables are not in inputList ([32m$units$unit[39m) but in dataset,
      their meta data will be set to NA: `booklet` and `hisei`
    Output
      $dat
               ID  booklet hisei I01 I05 I06 I07 I08 I13 I15 I12
      1 person100 booklet1    49   0   0   0   0   0 -94 -94 -94
      2 person101 booklet1   -94 -99   0 -99   0   1 -94 -94 -94
      3 person200 booklet2    69 -94 -94 -94 -94   0   0 -94   1
      4 person201 booklet2    76 -94 -94 -94 -94   0   1 -94   0
      5 person300 booklet3    49   0   0 -99 -98 -94 -94   0 -94
      6 person301 booklet3   -94   1   1   1   0 -94 -94 -99 -94
      
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
      167  <NA>
      168  <NA>
      169  <NA>
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
      

