# Reviewing Incident Reports

**You can process person-level, class-level, and mixed incident
reports.** Each row describes one incident affecting one person or one
class. **A table can contain reports for many people or classes.** A
class report is reviewed as one incident, even when it affects several
people.

| Report type | `level` | `targetId` contains | Additional input |
|----|----|----|----|
| Person-level | `"person"` | The person ID for that row, e.g. `"P1"` | None for an item report |
| Class-level | `"class"` | The class ID for that row, e.g. `"K1"` | `persons`: the person-to-class mapping |
| Mixed: people and classes | `"person"` or `"class"` per row | The person or class ID for that row | `persons`: the person-to-class mapping |

“Mixed” describes a table containing both kinds of report. Each row
still uses `level = "person"` or `level = "class"`. See [workflow
3](#workflow-3-mixed-reports).

All three input options have the same steps: **describe the incident,
check the selected responses, then review and decide whether to recode
them.**
[`prepareSubsetInfo()`](https://sachseka.github.io/eatPrep/reference/prepareSubsetInfo.md)
selects responses;
[`visualSubsetRecode()`](https://sachseka.github.io/eatPrep/reference/visualSubsetRecode.md)
opens the review.

Every issue table needs the same **five columns**: `issueId`, `level`,
`targetId`, `scope`, and `target`. Each `issueId` must be unique. The
examples also include the optional `comment` column; use `""` when no
comment is needed. [`head()`](https://rdrr.io/r/utils/head.html) shows
the input table in each example.

## Shared example data

Three people answered two items. Use merged response data, before
aggregating subunits into items. In these examples, `"mci"` is the
replacement code for responses invalidated by an incident.

``` r

review_data <- data.frame(
  ID = c("P1", "P2", "P3"),
  I1 = c(1, 0, 1),
  I2 = c(0, 1, 0)
)
review_data
#>   ID I1 I2
#> 1 P1  1  0
#> 2 P2  0  1
#> 3 P3  1  0
```

## Workflow 1: person-level reports

**Example: display errors affected item I2 for P1 and P3.** Enter both
reports in one table, with a separate `issueId` for each. Set
`level = "person"` and put the affected person’s ID in `targetId` on
each row.

``` r

person_issues <- data.frame(
  issueId = c("V1", "V2"), level = "person", targetId = c("P1", "P3"),
  scope = "item", target = "I2", comment = c("Display error", "")
)
head(person_issues)
#>   issueId  level targetId scope target       comment
#> 1      V1 person       P1  item     I2 Display error
#> 2      V2 person       P3  item     I2
```

Resolve the affected responses:

``` r

person_info <- prepareSubsetInfo(review_data, person_issues)
person_info[c("issueId", "ID", "datCols")]
#>   issueId ID datCols
#> 1      V1 P1      I2
#> 2      V2 P3      I2
```

The selection contains **P1/I2 and P3/I2**, reviewed as two separate
incidents. No class or booklet tables are needed. Start the review in an
interactive R session:

``` r

person_result <- visualSubsetRecode(review_data, person_info, toRecodeVal = "mci")
```

Choose **yes, all values** for each report, then **yes** to end the
review. The result is:

``` r

person_result$dat
#>   ID I1  I2
#> 1 P1  1 mci
#> 2 P2  0   1
#> 3 P3  1 mci
```

P1’s and P3’s responses to I2 change. P2’s responses and all responses
to I1 keep their original values.

## Workflow 2: class-level reports

**Example: a display error affected item I2 for everyone in class K1.**
Set `level = "class"` and put the class ID in `targetId`. Supply
`persons` so the function knows who belongs to that class:

``` r

persons <- data.frame(
  ID = c("P1", "P2", "P3"), classId = c("K1", "K1", "K2")
)
class_issue <- data.frame(
  issueId = "V3", level = "class", targetId = "K1",
  scope = "item", target = "I2", comment = ""
)
head(class_issue)
#>   issueId level targetId scope target comment
#> 1      V3 class       K1  item     I2
```

Resolve the affected responses:

``` r

class_info <- prepareSubsetInfo(review_data, class_issue, persons = persons)
class_info[c("issueId", "ID", "datCols")]
#>   issueId ID datCols
#> 1      V3 P1      I2
#> 2      V3 P2      I2
```

The single class report selects **P1/I2 and P2/I2**. Both rows retain
`issueId = "V3"`, so you review them together and make **one decision
for the class report**. P3 belongs to K2 and is outside the selection.

``` r

class_result <- visualSubsetRecode(review_data, class_info, toRecodeVal = "mci")
```

Choose **yes, all values**, then **yes** to end the review:

``` r

class_result$dat
#>   ID I1  I2
#> 1 P1  1 mci
#> 2 P2  0 mci
#> 3 P3  1   0
```

The difference from workflow 1 is the affected people: **the same item
is recoded for everyone in K1**, while P3’s responses stay unchanged.
Class IDs must identify classes uniquely across the data set, including
across schools.

## Workflow 3: mixed reports

**Example: process the two person reports and the class report
together.** Combine them in one table. Each row keeps its own `level`,
`targetId`, and unique `issueId`:

``` r

issues <- rbind(person_issues, class_issue)
head(issues)
#>   issueId  level targetId scope target       comment
#> 1      V1 person       P1  item     I2 Display error
#> 2      V2 person       P3  item     I2              
#> 3      V3  class       K1  item     I2
```

Supply the class membership table `persons`, as in workflow 2:

``` r

subset_info <- prepareSubsetInfo(review_data, issues, persons = persons)
summary(subset_info)
#>   issueId  level targetId persons items cells overlappingCells
#> 1      V1 person       P1       1     1     1                1
#> 2      V2 person       P3       1     1     1                0
#> 3      V3  class       K1       2     1     2                1
```

Start one review for the whole table:

``` r

mixed_result <- visualSubsetRecode(review_data, subset_info, toRecodeVal = "mci")
```

The review presents **V1 (P1), V2 (P3), and V3 (class K1)** separately.
Choose **yes, all values** for each report, then **yes** to end the
review:

``` r

mixed_result$dat
#>   ID I1  I2
#> 1 P1  1 mci
#> 2 P2  0 mci
#> 3 P3  1 mci
```

All three people’s responses to I2 are recoded. P1/I2 occurs in both V1
and V3; resetting one report keeps a recoding still required by the
other. Choose **reset to original values** to withdraw a previous
recoding; **no** leaves it unchanged. All three workflows preserve
existing `NA` responses.

## If the incident affects a block

In all three workflows, `level` answers **who is affected?** and `scope`
answers **which responses are affected?** An item report uses
`scope = "item"`. For an entire block, also supply `booklets`, `blocks`,
and `rotation`.

For example, P1 and P2 are both in K1 but use different block orders:

``` r

booklets <- data.frame(
  booklet = c("X", "Y"), block1 = c("A", "B"), block2 = c("B", "A")
)
blocks <- data.frame(
  subunit = c("I1", "I2"), block = c("A", "B"), subunitBlockPosition = 1
)
rotation <- data.frame(ID = c("P1", "P2", "P3"), booklet = c("X", "Y", "X"))
```

To report a problem with **the first block in class K1**, keep the class
target and change the scope to `"blockPosition"`:

``` r

block_issue <- class_issue
block_issue$scope <- "blockPosition"
block_issue$target <- "1"
head(block_issue)
#>   issueId level targetId         scope target comment
#> 1      V3 class       K1 blockPosition      1
```

``` r

block_info <- prepareSubsetInfo(
  review_data, block_issue, persons = persons,
  booklets = booklets, blocks = blocks, rotation = rotation
)
block_info[c("ID", "datCols", "block", "blockPosition")]
#>   ID datCols block blockPosition
#> 1 P1      I1     A             1
#> 2 P2      I2     B             1
```

This selects **P1/I1 and P2/I2**: the first block is A for P1 and B for
P2. Review `block_info` just like `class_info` above. To select **named
block A** instead, use `scope = "block", target = "A"`; that selects I1
for both people.

## Pause and continue

For a longer review, choose a new checkpoint filename when starting:

``` r

result <- visualSubsetRecode(
  review_data, subset_info, toRecodeVal = "mci", checkpoint = "review.rds"
)
# Choose "pause review (resume later)". In a later R session:
library(eatPrep)
result <- visualSubsetRecode(state = "review.rds")
```

Completed decisions are saved automatically. Resume with `state` to keep
the original values and earlier decisions. Continue your data
preparation with `result$dat`; `result$subsetInfo` contains the decision
history.

For project data, the design tables can come from `inputList`. After
[`recodeData()`](https://sachseka.github.io/eatPrep/reference/recodeData.md),
also pass `subunits = inputList$subunits` to map original item names to
recoded columns. See
[`?prepareSubsetInfo`](https://sachseka.github.io/eatPrep/reference/prepareSubsetInfo.md)
and
[`?visualSubsetRecode`](https://sachseka.github.io/eatPrep/reference/visualSubsetRecode.md)
for input requirements, review options, and checkpoint recovery.
