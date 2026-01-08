# Read xlsx-Files Produced by ZKDaemon

This function is primarily intended for internal use at the Institute
for Educational Quality Improvement (IQB). The xlsx-files for this
function are produced by the software ZKDaemon using information stored
in the IQB-Databases (DB2/DB3/DB4).

## Usage

``` r
readDaemonXlsx(filename)
```

## Arguments

- filename:

  A character string containing path, name and extension of .xlsx
  produced by ZKDaemon.

## Details

The xlsx-file produced by 'ZKDaemon' is expected to have the following
sheets: “units”, “subunits”, “values”, “unitrecoding”, “sav-files”,
“params”, “aggregate-missings”, “itemproperties”, “propertylabels”,
“booklets”, and “blocks”. `readDaemonXlsx` will produce a warning if any
sheets are missing or wrongly specified.

## Value

A list of data frames containing information that is required by the
data preparation functions in `eatPrep`.
[`inputList`](https://sachseka.github.io/eatPrep/reference/inputList.md)
shows an example of this list.

## Author

Karoline Sachse

## Examples

``` r
readDaemonXlsx(system.file("extdata", "inputList.xlsx", package = "eatPrep"))
#> Reading sheet 'units'.
#> Reading sheet 'subunits'.
#> Reading sheet 'values'.
#> Reading sheet 'unitrecoding'.
#> Reading sheet 'sav-files'.
#> Reading sheet 'params'.
#> Reading sheet 'aggregate-missings'.
#> Reading sheet 'booklets'.
#> Reading sheet 'blocks'.
#> $units
#>    unit                              unitLabel unitDescription unitType
#> 1   I01              Animals: Weight of a duck            <NA>       TI
#> 2   I02             Animals: Weight of a horse            <NA>       TI
#> 3   I03             Animals: Weight of a mouse            <NA>       TI
#> 4   I04               Animals: Weight of a cat            <NA>       TI
#> 5   I05                    Conversion: 0.14 cm            <NA>       TI
#> 6   I06        MissingNumber: 13 - 26 - x - 52            <NA>       TI
#> 7   I07                          Pizza: Choice            <NA>       TI
#> 8   I08            Pizza: Reasoning for choice            <NA>       TI
#> 9   I09    Birds: Which bird has lightest eggs            <NA>       TI
#> 10  I10       Birds: Which bird has least eggs            <NA>       TI
#> 11  I11  Birds: Which bird has heaviest clutch            <NA>       TI
#> 12  I12                                 Shapes            <NA>       TI
#> 13  I13 Sweets: How many possibilities to hide            <NA>       TI
#> 14  I14          Shopping: Number combinations            <NA>       TI
#> 15  I15                Shopping: Number prices            <NA>       TI
#> 16  I16              Breakfast: Amount of nuts            <NA>       TI
#> 17  I17              Breakfast: Amount of milk            <NA>       TI
#> 18  I18              Breakfast: Amount of oats            <NA>       TI
#> 19  I19   Birthdays: Month with most birthdays            <NA>       TI
#> 20  I20  Birthdays: Which statement is correct            <NA>       TI
#> 21  I21   Birthdays: Number birthdays in April            <NA>       TI
#> 22  I22       Dice: Which result is impossible            <NA>       TI
#> 23  I23      Dice: Which result is most likely            <NA>       TI
#> 24  I24         Football: Team with most goals            <NA>       TI
#> 25  I25                Football: Correct graph            <NA>       TI
#> 26  I26                          Braking: Time            <NA>       TI
#> 27  I27                           Braking: Way            <NA>       TI
#> 28  I28                         Braking: Speed            <NA>       TI
#> 29   ID                             Student ID            <NA>       ID
#>    unitAggregateRule unitScoreRule
#> 1               <NA>          <NA>
#> 2               <NA>          <NA>
#> 3               <NA>          <NA>
#> 4               <NA>          <NA>
#> 5               <NA>          <NA>
#> 6               <NA>          <NA>
#> 7               <NA>          <NA>
#> 8               <NA>          <NA>
#> 9               <NA>          <NA>
#> 10              <NA>          <NA>
#> 11              <NA>          <NA>
#> 12               SUM          <NA>
#> 13              <NA>          <NA>
#> 14              <NA>          <NA>
#> 15              <NA>          <NA>
#> 16              <NA>          <NA>
#> 17              <NA>          <NA>
#> 18              <NA>          <NA>
#> 19              <NA>          <NA>
#> 20              <NA>          <NA>
#> 21              <NA>          <NA>
#> 22              <NA>          <NA>
#> 23              <NA>          <NA>
#> 24              <NA>          <NA>
#> 25              <NA>          <NA>
#> 26              <NA>          <NA>
#> 27              <NA>          <NA>
#> 28              <NA>          <NA>
#> 29              <NA>          <NA>
#> 
#> $subunits
#>    unit subunit subunitType                           subunitLabel
#> 1   I01     I01           1              Animals: Weight of a duck
#> 2   I02     I02           1             Animals: Weight of a horse
#> 3   I03     I03           1             Animals: Weight of a mouse
#> 4   I04     I04           1               Animals: Weight of a cat
#> 5   I05     I05           3                    Conversion: 0.14 cm
#> 6   I06     I06           3        MissingNumber: 13 - 26 - x - 52
#> 7   I07     I07           1                          Pizza: Choice
#> 8   I08     I08           3            Pizza: Reasoning for choice
#> 9   I09     I09           1    Birds: Which bird has lightest eggs
#> 10  I10     I10           1       Birds: Which bird has least eggs
#> 11  I11     I11           1  Birds: Which bird has heaviest clutch
#> 12  I12    I12a           3                  Shapes: Biggest shape
#> 13  I12    I12b           3                  Shapes: Circumference
#> 14  I12    I12c           1               Shapes: Size calculation
#> 15  I13     I13           1 Sweets: How many possibilities to hide
#> 16  I14     I14           1          Shopping: Number combinations
#> 17  I15     I15           1                Shopping: Number prices
#> 18  I16     I16           1              Breakfast: Amount of nuts
#> 19  I17     I17           1              Breakfast: Amount of milk
#> 20  I18     I18           1              Breakfast: Amount of oats
#> 21  I19     I19           1   Birthdays: Month with most birthdays
#> 22  I20     I20           1  Birthdays: Which statement is correct
#> 23  I21     I21           1   Birthdays: Number birthdays in April
#> 24  I22     I22           1       Dice: Which result is impossible
#> 25  I23     I23           1      Dice: Which result is most likely
#> 26  I24     I24           1         Football: Team with most goals
#> 27  I25     I25           3                Football: Correct graph
#> 28  I26     I26           3                          Braking: Time
#> 29  I27     I27           3                           Braking: Way
#> 30  I28     I28           3                         Braking: Speed
#>    subunitDescription subunitPosition subunitTransniveau subunitRecoded
#> 1                <NA>              a)               <NA>           I01R
#> 2                <NA>              b)               <NA>           I02R
#> 3                <NA>              c)               <NA>           I03R
#> 4                <NA>              d)               <NA>           I04R
#> 5                <NA>            <NA>               <NA>           I05R
#> 6                <NA>            <NA>               <NA>           I06R
#> 7                <NA>            <NA>               <NA>           I07R
#> 8                <NA>            <NA>               <NA>           I08R
#> 9                <NA>            <NA>               <NA>           I09R
#> 10               <NA>            <NA>               <NA>           I10R
#> 11               <NA>            <NA>               <NA>           I11R
#> 12               <NA>            <NA>               <NA>          I12aR
#> 13               <NA>            <NA>               <NA>          I12bR
#> 14               <NA>            <NA>               <NA>          I12cR
#> 15               <NA>            <NA>               <NA>           I13R
#> 16               <NA>            <NA>               <NA>           I14R
#> 17               <NA>            <NA>               <NA>           I15R
#> 18               <NA>            <NA>               <NA>           I16R
#> 19               <NA>            <NA>               <NA>           I17R
#> 20               <NA>            <NA>               <NA>           I18R
#> 21               <NA>            <NA>               <NA>           I19R
#> 22               <NA>            <NA>               <NA>           I20R
#> 23               <NA>            <NA>               <NA>           I21R
#> 24               <NA>            <NA>               <NA>           I22R
#> 25               <NA>            <NA>               <NA>           I23R
#> 26               <NA>            <NA>               <NA>           I24R
#> 27               <NA>            <NA>               <NA>           I25R
#> 28               <NA>            <NA>               <NA>           I26R
#> 29               <NA>            <NA>               <NA>           I27R
#> 30               <NA>            <NA>               <NA>           I28R
#>                               subunitLabelRecoded
#> 1               Recoded Animals: Weight of a duck
#> 2              Recoded Animals: Weight of a horse
#> 3              Recoded Animals: Weight of a mouse
#> 4                Recoded Animals: Weight of a cat
#> 5                     Recoded Conversion: 0.14 cm
#> 6         Recoded MissingNumber: 13 - 26 - x - 52
#> 7                           Recoded Pizza: Choice
#> 8             Recoded Pizza: Reasoning for choice
#> 9     Recoded Birds: Which bird has lightest eggs
#> 10       Recoded Birds: Which bird has least eggs
#> 11  Recoded Birds: Which bird has heaviest clutch
#> 12                  Recoded Shapes: Biggest shape
#> 13                  Recoded Shapes: Circumference
#> 14               Recoded Shapes: Size calculation
#> 15 Recoded Sweets: How many possibilities to hide
#> 16          Recoded Shopping: Number combinations
#> 17                Recoded Shopping: Number prices
#> 18              Recoded Breakfast: Amount of nuts
#> 19              Recoded Breakfast: Amount of milk
#> 20              Recoded Breakfast: Amount of oats
#> 21   Recoded Birthdays: Month with most birthdays
#> 22  Recoded Birthdays: Which statement is correct
#> 23   Recoded Birthdays: Number birthdays in April
#> 24       Recoded Dice: Which result is impossible
#> 25      Recoded Dice: Which result is most likely
#> 26         Recoded Football: Team with most goals
#> 27                Recoded Football: Correct graph
#> 28                          Recoded Braking: Time
#> 29                           Recoded Braking: Way
#> 30                         Recoded Braking: Speed
#> 
#> $values
#>     subunit value valueRecode valueType
#> 1       I01     1           0        vc
#> 2       I01     2           0        vc
#> 3       I01     3           1        vc
#> 4       I01     6         mnr       mnr
#> 5       I01     7         mbd       mbd
#> 6       I01     8         mir       mir
#> 7       I01     9         mbi       mbi
#> 8       I02     1           1        vc
#> 9       I02     2           0        vc
#> 10      I02     3           0        vc
#> 11      I02     4           0        vc
#> 12      I02     6         mnr       mnr
#> 13      I02     7         mbd       mbd
#> 14      I02     8         mir       mir
#> 15      I02     9         mbi       mbi
#> 16      I03     1           0        vc
#> 17      I03     2           1        vc
#> 18      I03     3           0        vc
#> 19      I03     6         mnr       mnr
#> 20      I03     7         mbd       mbd
#> 21      I03     8         mir       mir
#> 22      I03     9         mbi       mbi
#> 23      I04     1           0        vc
#> 24      I04     2           1        vc
#> 25      I04     3           0        vc
#> 26      I04     6         mnr       mnr
#> 27      I04     7         mbd       mbd
#> 28      I04     8         mir       mir
#> 29      I04     9         mbi       mbi
#> 30      I05     0           0        vc
#> 31      I05     1           1        vc
#> 32      I05     6         mnr       mnr
#> 33      I05     7         mbd       mbd
#> 34      I05     8         mir       mir
#> 35      I05     9         mbi       mbi
#> 36      I06     0           0        vc
#> 37      I06     1           1        vc
#> 38      I06     6         mnr       mnr
#> 39      I06     7         mbd       mbd
#> 40      I06     8         mir       mir
#> 41      I06     9         mbi       mbi
#> 42      I07     1           1        vc
#> 43      I07     2           0        vc
#> 44      I07     3           0        vc
#> 45      I07     4           0        vc
#> 46      I07     6         mnr       mnr
#> 47      I07     7         mbd       mbd
#> 48      I07     8         mir       mir
#> 49      I07     9         mbi       mbi
#> 50      I08     0           0        vc
#> 51      I08     1           1        vc
#> 52      I08     6         mnr       mnr
#> 53      I08     7         mbd       mbd
#> 54      I08     8         mir       mir
#> 55      I08     9         mbi       mbi
#> 56      I09     1           0        vc
#> 57      I09     2           0        vc
#> 58      I09     3           0        vc
#> 59      I09     4           1        vc
#> 60      I09     6         mnr       mnr
#> 61      I09     7         mbd       mbd
#> 62      I09     8         mir       mir
#> 63      I09     9         mbi       mbi
#> 64      I10     1           0        vc
#> 65      I10     2           1        vc
#> 66      I10     3           0        vc
#> 67      I10     4           0        vc
#> 68      I10     6         mnr       mnr
#> 69      I10     7         mbd       mbd
#> 70      I10     8         mir       mir
#> 71      I10     9         mbi       mbi
#> 72      I11     1           0        vc
#> 73      I11     2           0        vc
#> 74      I11     3           1        vc
#> 75      I11     4           0        vc
#> 76      I11     6         mnr       mnr
#> 77      I11     7         mbd       mbd
#> 78      I11     8         mir       mir
#> 79      I11     9         mbi       mbi
#> 80     I12a     0           0        vc
#> 81     I12a     1           1        vc
#> 82     I12a     6         mnr       mnr
#> 83     I12a     7         mbd       mbd
#> 84     I12a     8         mir       mir
#> 85     I12a     9         mbi       mbi
#> 86     I12b     0           0        vc
#> 87     I12b     1           1        vc
#> 88     I12b     6         mnr       mnr
#> 89     I12b     7         mbd       mbd
#> 90     I12b     8         mir       mir
#> 91     I12b     9         mbi       mbi
#> 92     I12c     1           0        vc
#> 93     I12c     2           0        vc
#> 94     I12c     3           0        vc
#> 95     I12c     4           1        vc
#> 96     I12c     6         mnr       mnr
#> 97     I12c     7         mbd       mbd
#> 98     I12c     8         mir       mir
#> 99     I12c     9         mbi       mbi
#> 100     I13     1           0        vc
#> 101     I13     2           1        vc
#> 102     I13     3           0        vc
#> 103     I13     4           0        vc
#> 104     I13     6         mnr       mnr
#> 105     I13     7         mbd       mbd
#> 106     I13     8         mir       mir
#> 107     I13     9         mbi       mbi
#> 108     I14     1           0        vc
#> 109     I14     2           0        vc
#> 110     I14     3           0        vc
#> 111     I14     4           0        vc
#> 112     I14     5           0        vc
#> 113     I14     6           1        vc
#> 114     I14     7           0        vc
#> 115     I14     8         mir       mir
#> 116     I14     9         mbi       mbi
#> 117     I15     1           1        vc
#> 118     I15     2           0        vc
#> 119     I15     3           0        vc
#> 120     I15     4           0        vc
#> 121     I15     6         mnr       mnr
#> 122     I15     7         mbd       mbd
#> 123     I15     8         mir       mir
#> 124     I15     9         mbi       mbi
#> 125     I16     1           0        vc
#> 126     I16     2           0        vc
#> 127     I16     3           0        vc
#> 128     I16     4           1        vc
#> 129     I16     6         mnr       mnr
#> 130     I16     7         mbd       mbd
#> 131     I16     8         mir       mir
#> 132     I16     9         mbi       mbi
#> 133     I17     1           0        vc
#> 134     I17     2           1        vc
#> 135     I17     3           0        vc
#> 136     I17     4           0        vc
#> 137     I17     6         mnr       mnr
#> 138     I17     7         mbd       mbd
#> 139     I17     8         mir       mir
#> 140     I17     9         mbi       mbi
#> 141     I18     1           1        vc
#> 142     I18     2           0        vc
#> 143     I18     3           0        vc
#> 144     I18     4           0        vc
#> 145     I18     6         mnr       mnr
#> 146     I18     7         mbd       mbd
#> 147     I18     8         mir       mir
#> 148     I18     9         mbi       mbi
#> 149     I19     1           0        vc
#> 150     I19     2           0        vc
#> 151     I19     3           0        vc
#> 152     I19     4           1        vc
#> 153     I19     6         mnr       mnr
#> 154     I19     7         mbd       mbd
#> 155     I19     8         mir       mir
#> 156     I19     9         mbi       mbi
#> 157     I20     1           0        vc
#> 158     I20     2           1        vc
#> 159     I20     3           0        vc
#> 160     I20     4           0        vc
#> 161     I20     6         mnr       mnr
#> 162     I20     7         mbd       mbd
#> 163     I20     8         mir       mir
#> 164     I20     9         mbi       mbi
#> 165     I21     1           0        vc
#> 166     I21     2           0        vc
#> 167     I21     3           1        vc
#> 168     I21     4           0        vc
#> 169     I21     6         mnr       mnr
#> 170     I21     7         mbd       mbd
#> 171     I21     8         mir       mir
#> 172     I21     9         mbi       mbi
#> 173     I22     1           1        vc
#> 174     I22     2           0        vc
#> 175     I22     3           0        vc
#> 176     I22     4           0        vc
#> 177     I22     6         mnr       mnr
#> 178     I22     7         mbd       mbd
#> 179     I22     8         mir       mir
#> 180     I22     9         mbi       mbi
#> 181     I23     1           1        vc
#> 182     I23     2           0        vc
#> 183     I23     3           0        vc
#> 184     I23     4           0        vc
#> 185     I23     6         mnr       mnr
#> 186     I23     7         mbd       mbd
#> 187     I23     8         mir       mir
#> 188     I23     9         mbi       mbi
#> 189     I24     1           0        vc
#> 190     I24     2           1        vc
#> 191     I24     3           0        vc
#> 192     I24     4           0        vc
#> 193     I24     6         mnr       mnr
#> 194     I24     7         mbd       mbd
#> 195     I24     8         mir       mir
#> 196     I24     9         mbi       mbi
#> 197     I25     0           0        vc
#> 198     I25     1           1        vc
#> 199     I25     6         mnr       mnr
#> 200     I25     7         mbd       mbd
#> 201     I25     8         mir       mir
#> 202     I25     9         mbi       mbi
#> 203     I26     0           0        vc
#> 204     I26     1           1        vc
#> 205     I26     6         mnr       mnr
#> 206     I26     7         mbd       mbd
#> 207     I26     8         mir       mir
#> 208     I26     9         mbi       mbi
#> 209     I27     0           0        vc
#> 210     I27     1           1        vc
#> 211     I27     6         mnr       mnr
#> 212     I27     7         mbd       mbd
#> 213     I27     8         mir       mir
#> 214     I27     9         mbi       mbi
#> 215     I28     0           0        vc
#> 216     I28     1           1        vc
#> 217     I28     6         mnr       mnr
#> 218     I28     7         mbd       mbd
#> 219     I28     8         mir       mir
#> 220     I28     9         mbi       mbi
#>                                         valueLabel
#> 1                         Response option 1 marked
#> 2                         Response option 2 marked
#> 3                         Response option 3 marked
#> 4                              missing not reached
#> 5                                missing by design
#> 6                         missing invalid response
#> 7                             missing by intention
#> 8                         Response option 1 marked
#> 9                         Response option 2 marked
#> 10                        Response option 3 marked
#> 11                        Response option 4 marked
#> 12                             missing not reached
#> 13                               missing by design
#> 14                        missing invalid response
#> 15                            missing by intention
#> 16                        Response option 1 marked
#> 17                        Response option 2 marked
#> 18                        Response option 3 marked
#> 19                             missing not reached
#> 20                               missing by design
#> 21                        missing invalid response
#> 22                            missing by intention
#> 23                        Response option 1 marked
#> 24                        Response option 2 marked
#> 25                        Response option 3 marked
#> 26                             missing not reached
#> 27                               missing by design
#> 28                        missing invalid response
#> 29                            missing by intention
#> 30                                           other
#> 31                      14 mm (units not required)
#> 32                             missing not reached
#> 33                               missing by design
#> 34                        missing invalid response
#> 35                            missing by intention
#> 36                                           other
#> 37                                              39
#> 38                             missing not reached
#> 39                               missing by design
#> 40                        missing invalid response
#> 41                            missing by intention
#> 42                        Response option 1 marked
#> 43                        Response option 2 marked
#> 44                        Response option 3 marked
#> 45                        Response option 4 marked
#> 46                             missing not reached
#> 47                               missing by design
#> 48                        missing invalid response
#> 49                            missing by intention
#> 50                                           other
#> 51  Surface area increases more rapidly than price
#> 52                             missing not reached
#> 53                               missing by design
#> 54                        missing invalid response
#> 55                            missing by intention
#> 56                        Response option 1 marked
#> 57                        Response option 2 marked
#> 58                        Response option 3 marked
#> 59                        Response option 4 marked
#> 60                             missing not reached
#> 61                               missing by design
#> 62                        missing invalid response
#> 63                            missing by intention
#> 64                        Response option 1 marked
#> 65                        Response option 2 marked
#> 66                        Response option 3 marked
#> 67                        Response option 4 marked
#> 68                             missing not reached
#> 69                               missing by design
#> 70                        missing invalid response
#> 71                            missing by intention
#> 72                        Response option 1 marked
#> 73                        Response option 2 marked
#> 74                        Response option 3 marked
#> 75                        Response option 4 marked
#> 76                             missing not reached
#> 77                               missing by design
#> 78                        missing invalid response
#> 79                            missing by intention
#> 80                                           other
#> 81    Shape B, supported with plausible reasoning.
#> 82                             missing not reached
#> 83                               missing by design
#> 84                        missing invalid response
#> 85                            missing by intention
#> 86                                           other
#> 87                22.9 metres (units not required)
#> 88                             missing not reached
#> 89                               missing by design
#> 90                        missing invalid response
#> 91                            missing by intention
#> 92                        Response option 1 marked
#> 93                        Response option 2 marked
#> 94                        Response option 3 marked
#> 95                        Response option 4 marked
#> 96                             missing not reached
#> 97                               missing by design
#> 98                        missing invalid response
#> 99                            missing by intention
#> 100                       Response option 1 marked
#> 101                       Response option 2 marked
#> 102                       Response option 3 marked
#> 103                       Response option 4 marked
#> 104                            missing not reached
#> 105                              missing by design
#> 106                       missing invalid response
#> 107                           missing by intention
#> 108                       Response option 1 marked
#> 109                       Response option 2 marked
#> 110                       Response option 3 marked
#> 111                       Response option 4 marked
#> 112                       Response option 5 marked
#> 113                       Response option 6 marked
#> 114                       Response option 7 marked
#> 115                       missing invalid response
#> 116                           missing by intention
#> 117                       Response option 1 marked
#> 118                       Response option 2 marked
#> 119                       Response option 3 marked
#> 120                       Response option 4 marked
#> 121                            missing not reached
#> 122                              missing by design
#> 123                       missing invalid response
#> 124                           missing by intention
#> 125                       Response option 1 marked
#> 126                       Response option 2 marked
#> 127                       Response option 3 marked
#> 128                       Response option 4 marked
#> 129                            missing not reached
#> 130                              missing by design
#> 131                       missing invalid response
#> 132                           missing by intention
#> 133                       Response option 1 marked
#> 134                       Response option 2 marked
#> 135                       Response option 3 marked
#> 136                       Response option 4 marked
#> 137                            missing not reached
#> 138                              missing by design
#> 139                       missing invalid response
#> 140                           missing by intention
#> 141                       Response option 1 marked
#> 142                       Response option 2 marked
#> 143                       Response option 3 marked
#> 144                       Response option 4 marked
#> 145                            missing not reached
#> 146                              missing by design
#> 147                       missing invalid response
#> 148                           missing by intention
#> 149                       Response option 1 marked
#> 150                       Response option 2 marked
#> 151                       Response option 3 marked
#> 152                       Response option 4 marked
#> 153                            missing not reached
#> 154                              missing by design
#> 155                       missing invalid response
#> 156                           missing by intention
#> 157                       Response option 1 marked
#> 158                       Response option 2 marked
#> 159                       Response option 3 marked
#> 160                       Response option 4 marked
#> 161                            missing not reached
#> 162                              missing by design
#> 163                       missing invalid response
#> 164                           missing by intention
#> 165                       Response option 1 marked
#> 166                       Response option 2 marked
#> 167                       Response option 3 marked
#> 168                       Response option 4 marked
#> 169                            missing not reached
#> 170                              missing by design
#> 171                       missing invalid response
#> 172                           missing by intention
#> 173                       Response option 1 marked
#> 174                       Response option 2 marked
#> 175                       Response option 3 marked
#> 176                       Response option 4 marked
#> 177                            missing not reached
#> 178                              missing by design
#> 179                       missing invalid response
#> 180                           missing by intention
#> 181                       Response option 1 marked
#> 182                       Response option 2 marked
#> 183                       Response option 3 marked
#> 184                       Response option 4 marked
#> 185                            missing not reached
#> 186                              missing by design
#> 187                       missing invalid response
#> 188                           missing by intention
#> 189                       Response option 1 marked
#> 190                       Response option 2 marked
#> 191                       Response option 3 marked
#> 192                       Response option 4 marked
#> 193                            missing not reached
#> 194                              missing by design
#> 195                       missing invalid response
#> 196                           missing by intention
#> 197                                          other
#> 198                101 metres (units not required)
#> 199                            missing not reached
#> 200                              missing by design
#> 201                       missing invalid response
#> 202                           missing by intention
#> 203                                          other
#> 204              5.84 seconds (units not required)
#> 205                            missing not reached
#> 206                              missing by design
#> 207                       missing invalid response
#> 208                           missing by intention
#> 209                                          other
#> 210               78.1 meters (units not required)
#> 211                            missing not reached
#> 212                              missing by design
#> 213                       missing invalid response
#> 214                           missing by intention
#> 215                                          other
#> 216                    90 kph (units not required)
#> 217                            missing not reached
#> 218                              missing by design
#> 219                       missing invalid response
#> 220                           missing by intention
#>                                                                                                                                            valueDescription
#> 1                                                                                                                                  Response option 1 marked
#> 2                                                                                                                                  Response option 2 marked
#> 3                                                                                                                                  Response option 3 marked
#> 4                                                                                                                                       missing not reached
#> 5                                                                                                                                         missing by design
#> 6                                                                                                                                  missing invalid response
#> 7                                                                                                                                      missing by intention
#> 8                                                                                                                                  Response option 1 marked
#> 9                                                                                                                                  Response option 2 marked
#> 10                                                                                                                                 Response option 3 marked
#> 11                                                                                                                                 Response option 4 marked
#> 12                                                                                                                                      missing not reached
#> 13                                                                                                                                        missing by design
#> 14                                                                                                                                 missing invalid response
#> 15                                                                                                                                     missing by intention
#> 16                                                                                                                                 Response option 1 marked
#> 17                                                                                                                                 Response option 2 marked
#> 18                                                                                                                                 Response option 3 marked
#> 19                                                                                                                                      missing not reached
#> 20                                                                                                                                        missing by design
#> 21                                                                                                                                 missing invalid response
#> 22                                                                                                                                     missing by intention
#> 23                                                                                                                                 Response option 1 marked
#> 24                                                                                                                                 Response option 2 marked
#> 25                                                                                                                                 Response option 3 marked
#> 26                                                                                                                                      missing not reached
#> 27                                                                                                                                        missing by design
#> 28                                                                                                                                 missing invalid response
#> 29                                                                                                                                     missing by intention
#> 30                                                                                                                                                    other
#> 31                                                                                                                               14 mm (units not required)
#> 32                                                                                                                                      missing not reached
#> 33                                                                                                                                        missing by design
#> 34                                                                                                                                 missing invalid response
#> 35                                                                                                                                     missing by intention
#> 36                                                                                                                                                    other
#> 37                                                                                                                                                       39
#> 38                                                                                                                                      missing not reached
#> 39                                                                                                                                        missing by design
#> 40                                                                                                                                 missing invalid response
#> 41                                                                                                                                     missing by intention
#> 42                                                                                                                                 Response option 1 marked
#> 43                                                                                                                                 Response option 2 marked
#> 44                                                                                                                                 Response option 3 marked
#> 45                                                                                                                                 Response option 4 marked
#> 46                                                                                                                                      missing not reached
#> 47                                                                                                                                        missing by design
#> 48                                                                                                                                 missing invalid response
#> 49                                                                                                                                     missing by intention
#> 50                                                                                                                                                    other
#> 51  Gives general reasoning that the surface area of pizza increases more rapidly than the price of pizza to conclude that the larger pizza is better value
#> 52                                                                                                                                      missing not reached
#> 53                                                                                                                                        missing by design
#> 54                                                                                                                                 missing invalid response
#> 55                                                                                                                                     missing by intention
#> 56                                                                                                                                 Response option 1 marked
#> 57                                                                                                                                 Response option 2 marked
#> 58                                                                                                                                 Response option 3 marked
#> 59                                                                                                                                 Response option 4 marked
#> 60                                                                                                                                      missing not reached
#> 61                                                                                                                                        missing by design
#> 62                                                                                                                                 missing invalid response
#> 63                                                                                                                                     missing by intention
#> 64                                                                                                                                 Response option 1 marked
#> 65                                                                                                                                 Response option 2 marked
#> 66                                                                                                                                 Response option 3 marked
#> 67                                                                                                                                 Response option 4 marked
#> 68                                                                                                                                      missing not reached
#> 69                                                                                                                                        missing by design
#> 70                                                                                                                                 missing invalid response
#> 71                                                                                                                                     missing by intention
#> 72                                                                                                                                 Response option 1 marked
#> 73                                                                                                                                 Response option 2 marked
#> 74                                                                                                                                 Response option 3 marked
#> 75                                                                                                                                 Response option 4 marked
#> 76                                                                                                                                      missing not reached
#> 77                                                                                                                                        missing by design
#> 78                                                                                                                                 missing invalid response
#> 79                                                                                                                                     missing by intention
#> 80                                                                                                                                                    other
#> 81                                                                                                             Shape B, supported with plausible reasoning.
#> 82                                                                                                                                      missing not reached
#> 83                                                                                                                                        missing by design
#> 84                                                                                                                                 missing invalid response
#> 85                                                                                                                                     missing by intention
#> 86                                                                                                                                                    other
#> 87                                                                                                                         22.9 metres (units not required)
#> 88                                                                                                                                      missing not reached
#> 89                                                                                                                                        missing by design
#> 90                                                                                                                                 missing invalid response
#> 91                                                                                                                                     missing by intention
#> 92                                                                                                                                 Response option 1 marked
#> 93                                                                                                                                 Response option 2 marked
#> 94                                                                                                                                 Response option 3 marked
#> 95                                                                                                                                 Response option 4 marked
#> 96                                                                                                                                      missing not reached
#> 97                                                                                                                                        missing by design
#> 98                                                                                                                                 missing invalid response
#> 99                                                                                                                                     missing by intention
#> 100                                                                                                                                Response option 1 marked
#> 101                                                                                                                                Response option 2 marked
#> 102                                                                                                                                Response option 3 marked
#> 103                                                                                                                                Response option 4 marked
#> 104                                                                                                                                     missing not reached
#> 105                                                                                                                                       missing by design
#> 106                                                                                                                                missing invalid response
#> 107                                                                                                                                    missing by intention
#> 108                                                                                                                                Response option 1 marked
#> 109                                                                                                                                Response option 2 marked
#> 110                                                                                                                                Response option 3 marked
#> 111                                                                                                                                Response option 4 marked
#> 112                                                                                                                                Response option 5 marked
#> 113                                                                                                                                Response option 6 marked
#> 114                                                                                                                                Response option 7 marked
#> 115                                                                                                                                missing invalid response
#> 116                                                                                                                                    missing by intention
#> 117                                                                                                                                Response option 1 marked
#> 118                                                                                                                                Response option 2 marked
#> 119                                                                                                                                Response option 3 marked
#> 120                                                                                                                                Response option 4 marked
#> 121                                                                                                                                     missing not reached
#> 122                                                                                                                                       missing by design
#> 123                                                                                                                                missing invalid response
#> 124                                                                                                                                    missing by intention
#> 125                                                                                                                                Response option 1 marked
#> 126                                                                                                                                Response option 2 marked
#> 127                                                                                                                                Response option 3 marked
#> 128                                                                                                                                Response option 4 marked
#> 129                                                                                                                                     missing not reached
#> 130                                                                                                                                       missing by design
#> 131                                                                                                                                missing invalid response
#> 132                                                                                                                                    missing by intention
#> 133                                                                                                                                Response option 1 marked
#> 134                                                                                                                                Response option 2 marked
#> 135                                                                                                                                Response option 3 marked
#> 136                                                                                                                                Response option 4 marked
#> 137                                                                                                                                     missing not reached
#> 138                                                                                                                                       missing by design
#> 139                                                                                                                                missing invalid response
#> 140                                                                                                                                    missing by intention
#> 141                                                                                                                                Response option 1 marked
#> 142                                                                                                                                Response option 2 marked
#> 143                                                                                                                                Response option 3 marked
#> 144                                                                                                                                Response option 4 marked
#> 145                                                                                                                                     missing not reached
#> 146                                                                                                                                       missing by design
#> 147                                                                                                                                missing invalid response
#> 148                                                                                                                                    missing by intention
#> 149                                                                                                                                Response option 1 marked
#> 150                                                                                                                                Response option 2 marked
#> 151                                                                                                                                Response option 3 marked
#> 152                                                                                                                                Response option 4 marked
#> 153                                                                                                                                     missing not reached
#> 154                                                                                                                                       missing by design
#> 155                                                                                                                                missing invalid response
#> 156                                                                                                                                    missing by intention
#> 157                                                                                                                                Response option 1 marked
#> 158                                                                                                                                Response option 2 marked
#> 159                                                                                                                                Response option 3 marked
#> 160                                                                                                                                Response option 4 marked
#> 161                                                                                                                                     missing not reached
#> 162                                                                                                                                       missing by design
#> 163                                                                                                                                missing invalid response
#> 164                                                                                                                                    missing by intention
#> 165                                                                                                                                Response option 1 marked
#> 166                                                                                                                                Response option 2 marked
#> 167                                                                                                                                Response option 3 marked
#> 168                                                                                                                                Response option 4 marked
#> 169                                                                                                                                     missing not reached
#> 170                                                                                                                                       missing by design
#> 171                                                                                                                                missing invalid response
#> 172                                                                                                                                    missing by intention
#> 173                                                                                                                                Response option 1 marked
#> 174                                                                                                                                Response option 2 marked
#> 175                                                                                                                                Response option 3 marked
#> 176                                                                                                                                Response option 4 marked
#> 177                                                                                                                                     missing not reached
#> 178                                                                                                                                       missing by design
#> 179                                                                                                                                missing invalid response
#> 180                                                                                                                                    missing by intention
#> 181                                                                                                                                Response option 1 marked
#> 182                                                                                                                                Response option 2 marked
#> 183                                                                                                                                Response option 3 marked
#> 184                                                                                                                                Response option 4 marked
#> 185                                                                                                                                     missing not reached
#> 186                                                                                                                                       missing by design
#> 187                                                                                                                                missing invalid response
#> 188                                                                                                                                    missing by intention
#> 189                                                                                                                                Response option 1 marked
#> 190                                                                                                                                Response option 2 marked
#> 191                                                                                                                                Response option 3 marked
#> 192                                                                                                                                Response option 4 marked
#> 193                                                                                                                                     missing not reached
#> 194                                                                                                                                       missing by design
#> 195                                                                                                                                missing invalid response
#> 196                                                                                                                                    missing by intention
#> 197                                                                                                                                                   other
#> 198                                                                                                                         101 metres (units not required)
#> 199                                                                                                                                     missing not reached
#> 200                                                                                                                                       missing by design
#> 201                                                                                                                                missing invalid response
#> 202                                                                                                                                    missing by intention
#> 203                                                                                                                                                   other
#> 204                                                                                                                       5.84 seconds (units not required)
#> 205                                                                                                                                     missing not reached
#> 206                                                                                                                                       missing by design
#> 207                                                                                                                                missing invalid response
#> 208                                                                                                                                    missing by intention
#> 209                                                                                                                                                   other
#> 210                                                                                                                        78.1 meters (units not required)
#> 211                                                                                                                                     missing not reached
#> 212                                                                                                                                       missing by design
#> 213                                                                                                                                missing invalid response
#> 214                                                                                                                                    missing by intention
#> 215                                                                                                                                                   other
#> 216                                                                                                                             90 kph (units not required)
#> 217                                                                                                                                     missing not reached
#> 218                                                                                                                                       missing by design
#> 219                                                                                                                                missing invalid response
#> 220                                                                                                                                    missing by intention
#>     valueLabelRecoded valueDescriptionRecoded
#> 1                   0                    <NA>
#> 2                   0                    <NA>
#> 3                   1                    <NA>
#> 4                 mnr                    <NA>
#> 5                 mbd                    <NA>
#> 6                 mir                    <NA>
#> 7                 mbi                    <NA>
#> 8                   1                    <NA>
#> 9                   0                    <NA>
#> 10                  0                    <NA>
#> 11                  0                    <NA>
#> 12                mnr                    <NA>
#> 13                mbd                    <NA>
#> 14                mir                    <NA>
#> 15                mbi                    <NA>
#> 16                  0                    <NA>
#> 17                  1                    <NA>
#> 18                  0                    <NA>
#> 19                mnr                    <NA>
#> 20                mbd                    <NA>
#> 21                mir                    <NA>
#> 22                mbi                    <NA>
#> 23                  0                    <NA>
#> 24                  1                    <NA>
#> 25                  0                    <NA>
#> 26                mnr                    <NA>
#> 27                mbd                    <NA>
#> 28                mir                    <NA>
#> 29                mbi                    <NA>
#> 30                  0                    <NA>
#> 31                  1                    <NA>
#> 32                mnr                    <NA>
#> 33                mbd                    <NA>
#> 34                mir                    <NA>
#> 35                mbi                    <NA>
#> 36                  0                    <NA>
#> 37                  1                    <NA>
#> 38                mnr                    <NA>
#> 39                mbd                    <NA>
#> 40                mir                    <NA>
#> 41                mbi                    <NA>
#> 42                  1                    <NA>
#> 43                  0                    <NA>
#> 44                  0                    <NA>
#> 45                  0                    <NA>
#> 46                mnr                    <NA>
#> 47                mbd                    <NA>
#> 48                mir                    <NA>
#> 49                mbi                    <NA>
#> 50                  0                    <NA>
#> 51                  1                    <NA>
#> 52                mnr                    <NA>
#> 53                mbd                    <NA>
#> 54                mir                    <NA>
#> 55                mbi                    <NA>
#> 56                  0                    <NA>
#> 57                  0                    <NA>
#> 58                  0                    <NA>
#> 59                  1                    <NA>
#> 60                mnr                    <NA>
#> 61                mbd                    <NA>
#> 62                mir                    <NA>
#> 63                mbi                    <NA>
#> 64                  0                    <NA>
#> 65                  1                    <NA>
#> 66                  0                    <NA>
#> 67                  0                    <NA>
#> 68                mnr                    <NA>
#> 69                mbd                    <NA>
#> 70                mir                    <NA>
#> 71                mbi                    <NA>
#> 72                  0                    <NA>
#> 73                  0                    <NA>
#> 74                  1                    <NA>
#> 75                  0                    <NA>
#> 76                mnr                    <NA>
#> 77                mbd                    <NA>
#> 78                mir                    <NA>
#> 79                mbi                    <NA>
#> 80                  0                    <NA>
#> 81                  1                    <NA>
#> 82                mnr                    <NA>
#> 83                mbd                    <NA>
#> 84                mir                    <NA>
#> 85                mbi                    <NA>
#> 86                  0                    <NA>
#> 87                  1                    <NA>
#> 88                mnr                    <NA>
#> 89                mbd                    <NA>
#> 90                mir                    <NA>
#> 91                mbi                    <NA>
#> 92                  0                    <NA>
#> 93                  0                    <NA>
#> 94                  0                    <NA>
#> 95                  1                    <NA>
#> 96                mnr                    <NA>
#> 97                mbd                    <NA>
#> 98                mir                    <NA>
#> 99                mbi                    <NA>
#> 100                 0                    <NA>
#> 101                 1                    <NA>
#> 102                 0                    <NA>
#> 103                 0                    <NA>
#> 104               mnr                    <NA>
#> 105               mbd                    <NA>
#> 106               mir                    <NA>
#> 107               mbi                    <NA>
#> 108                 0                    <NA>
#> 109                 0                    <NA>
#> 110                 0                    <NA>
#> 111                 0                    <NA>
#> 112                 0                    <NA>
#> 113                 1                    <NA>
#> 114                 0                    <NA>
#> 115               mir                    <NA>
#> 116               mbi                    <NA>
#> 117                 1                    <NA>
#> 118                 0                    <NA>
#> 119                 0                    <NA>
#> 120                 0                    <NA>
#> 121               mnr                    <NA>
#> 122               mbd                    <NA>
#> 123               mir                    <NA>
#> 124               mbi                    <NA>
#> 125                 0                    <NA>
#> 126                 0                    <NA>
#> 127                 0                    <NA>
#> 128                 1                    <NA>
#> 129               mnr                    <NA>
#> 130               mbd                    <NA>
#> 131               mir                    <NA>
#> 132               mbi                    <NA>
#> 133                 0                    <NA>
#> 134                 1                    <NA>
#> 135                 0                    <NA>
#> 136                 0                    <NA>
#> 137               mnr                    <NA>
#> 138               mbd                    <NA>
#> 139               mir                    <NA>
#> 140               mbi                    <NA>
#> 141                 1                    <NA>
#> 142                 0                    <NA>
#> 143                 0                    <NA>
#> 144                 0                    <NA>
#> 145               mnr                    <NA>
#> 146               mbd                    <NA>
#> 147               mir                    <NA>
#> 148               mbi                    <NA>
#> 149                 0                    <NA>
#> 150                 0                    <NA>
#> 151                 0                    <NA>
#> 152                 1                    <NA>
#> 153               mnr                    <NA>
#> 154               mbd                    <NA>
#> 155               mir                    <NA>
#> 156               mbi                    <NA>
#> 157                 0                    <NA>
#> 158                 1                    <NA>
#> 159                 0                    <NA>
#> 160                 0                    <NA>
#> 161               mnr                    <NA>
#> 162               mbd                    <NA>
#> 163               mir                    <NA>
#> 164               mbi                    <NA>
#> 165                 0                    <NA>
#> 166                 0                    <NA>
#> 167                 1                    <NA>
#> 168                 0                    <NA>
#> 169               mnr                    <NA>
#> 170               mbd                    <NA>
#> 171               mir                    <NA>
#> 172               mbi                    <NA>
#> 173                 1                    <NA>
#> 174                 0                    <NA>
#> 175                 0                    <NA>
#> 176                 0                    <NA>
#> 177               mnr                    <NA>
#> 178               mbd                    <NA>
#> 179               mir                    <NA>
#> 180               mbi                    <NA>
#> 181                 1                    <NA>
#> 182                 0                    <NA>
#> 183                 0                    <NA>
#> 184                 0                    <NA>
#> 185               mnr                    <NA>
#> 186               mbd                    <NA>
#> 187               mir                    <NA>
#> 188               mbi                    <NA>
#> 189                 0                    <NA>
#> 190                 1                    <NA>
#> 191                 0                    <NA>
#> 192                 0                    <NA>
#> 193               mnr                    <NA>
#> 194               mbd                    <NA>
#> 195               mir                    <NA>
#> 196               mbi                    <NA>
#> 197                 0                    <NA>
#> 198                 1                    <NA>
#> 199               mnr                    <NA>
#> 200               mbd                    <NA>
#> 201               mir                    <NA>
#> 202               mbi                    <NA>
#> 203                 0                    <NA>
#> 204                 1                    <NA>
#> 205               mnr                    <NA>
#> 206               mbd                    <NA>
#> 207               mir                    <NA>
#> 208               mbi                    <NA>
#> 209                 0                    <NA>
#> 210                 1                    <NA>
#> 211               mnr                    <NA>
#> 212               mbd                    <NA>
#> 213               mir                    <NA>
#> 214               mbi                    <NA>
#> 215                 0                    <NA>
#> 216                 1                    <NA>
#> 217               mnr                    <NA>
#> 218               mbd                    <NA>
#> 219               mir                    <NA>
#> 220               mbi                    <NA>
#> 
#> $unitRecodings
#>   unit value valueRecode valueType valueLabel valueDescription
#> 1  I12     0           0        vc       <NA>             <NA>
#> 2  I12     1           0        vc       <NA>             <NA>
#> 3  I12     2           0        vc       <NA>             <NA>
#> 4  I12     3           1        vc       <NA>             <NA>
#> 5  I12   mbd         mbd       mbd       <NA>             <NA>
#> 6  I12   mir         mir       mir       <NA>             <NA>
#> 7  I12   mbi         mbi       mbi       <NA>             <NA>
#>   valueLabelRecoded
#> 1              <NA>
#> 2              <NA>
#> 3              <NA>
#> 4              <NA>
#> 5              <NA>
#> 6              <NA>
#> 7              <NA>
#> 
#> $savFiles
#>       filename case.id fullname
#> 1 booklet1.sav      ID     <NA>
#> 2 booklet2.sav      ID     <NA>
#> 3 booklet3.sav      ID     <NA>
#> 
#> $newID
#>         key value
#> 1 master-id    ID
#> 
#> $aggrMiss
#>   nam  vc mvi mnr mci mbd mir mbi
#> 1  vc  vc mvi  vc mci err  vc  vc
#> 2 mvi mvi mvi err mci err err err
#> 3 mnr  vc err mnr mci err mir mnr
#> 4 mci mci mci mci mci err mci mci
#> 5 mbd err err err err mbd err err
#> 6 mir  vc err mir mci err mir mir
#> 7 mbi  vc err mnr mci err mir mbi
#> 
#> $booklets
#>    booklet block1 block2 block3
#> 1 booklet1    bl1    bl2    bl3
#> 2 booklet2    bl4    bl3    bl2
#> 3 booklet3    bl3    bl1    bl4
#> 
#> $blocks
#>    subunit block subunitBlockPosition
#> 1      I01   bl1                    1
#> 2      I02   bl1                    2
#> 3      I03   bl1                    3
#> 4      I04   bl1                    4
#> 5      I05   bl1                    5
#> 6      I06   bl1                    6
#> 7      I07   bl1                    7
#> 8      I08   bl2                    1
#> 9      I09   bl2                    2
#> 10     I10   bl2                    3
#> 11     I11   bl2                    4
#> 12    I12a   bl2                    5
#> 13    I12b   bl2                    6
#> 14    I12c   bl2                    7
#> 15     I13   bl2                    8
#> 16     I14   bl2                    9
#> 17     I15   bl3                    1
#> 18     I16   bl3                    2
#> 19     I17   bl3                    3
#> 20     I18   bl3                    4
#> 21     I19   bl3                    5
#> 22     I20   bl3                    6
#> 23     I21   bl3                    7
#> 24     I22   bl4                    1
#> 25     I23   bl4                    2
#> 26     I24   bl4                    3
#> 27     I25   bl4                    4
#> 28     I26   bl4                    5
#> 29     I27   bl4                    6
#> 30     I28   bl4                    7
#> 
```
