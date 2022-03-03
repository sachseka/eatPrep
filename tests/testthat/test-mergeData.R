
dat0 <- data.frame(ID=c(1,2,3,4),
                   v1 = c("0","300","j",NA),
                   v2=c("0","909","1000",NA),
                   v3=c("k","kk9","kkk",NA),
                   v4=NA,
                   v5=c("0","90","100","1"),
                   v11 = c("1","300","e","l"))

dat1 <- data.frame( v1 = c("0","300",NA,"j"),
                    v2=c("0","90","10000",NA),
                    v3=c("k","kk","kkk","kk"),
                    kk=c(1,2,3,4),
                    v4=c("k",NA,"kkk","kk"))

dat2 <- data.frame(ID=c(1,2,3,4),
                  v1 = c("0",NA,"e",NA),
                  v2=c("0","90","10000",NA),
                  v3=c("k","kk","kkk",NA),
                  v4=c(NA,2,3,4),
                  v5=c("0","90","100","1"))


dat3 <- data.frame(v1 = c("0","300","e","l"),
                    tb=c(1,2,3,4),
                   v11 = c("1","300","e","l"))


test_that("default merge works as expected 1", {
  expect_identical(mergeData("ID",list(dat0,dat1,dat2,dat3), c(1,4,1,2), verbose=FALSE),
                   data.frame(ID=c(1,2,3,4),
                              v1 = c("0","300","j","j"),
                              v2=c("0","909","1000",NA),
                              v3=c("k","kk9","kkk","kk"),
                              v4=c("k",2,"kkk","kk"),
                              v5=c("0","90","100","1"),
                              v11=c("1", "300", "e","l")))
})



test_that("default merge works as expected 1", {
  expect_identical(mergeData("ID",list(dat0,dat1,dat2,dat3), c("ID","kk","ID","tb"), verbose=FALSE),
                   data.frame(ID=c(1,2,3,4),
                              v1 = c("0","300","j","j"),
                              v2=c("0","909","1000",NA),
                              v3=c("k","kk9","kkk","kk"),
                              v4=c("k",2,"kkk","kk"),
                              v5=c("0","90","100","1"),
                              v11=c("1", "300", "e","l")))
})



test_that("default merge works as expected 2", {
  expect_identical(mergeData("ID",list(dat0,dat2), verbose=FALSE),
                   data.frame(ID=c(1,2,3,4),
                              v1 = c("0","300","j",NA),
                              v2=c("0","909","1000",NA),
                              v3=c("k","kk9","kkk",NA),
                              v4=c(NA,2,3,4),
                              v5=c("0","90","100","1"),
                              v11=c("1", "300", "e","l")))
})



test_that("no data sets", {
  expect_error(mergeData("ID",list(), verbose=FALSE),
                 "Found no datasets." )
})



test_that("wrong ID", {
  expect_error(mergeData("IDs",list(dat0,dat2), verbose=FALSE),
                 "Did not find ID variable in dataset 1" )
})

test_that("multiple different valid codes", {
  expect_message(mergeData("ID",list(dat0[,1:2],dat2[,1:2]), verbose=TRUE),
               "Multiple different valid codes in variable: v1 in dataset 2: \n The first value has been kept. \n IDs: 3\n Values: j&e")
})

test_that("multiple different valid codes II", {
  expect_message(mergeData("ID",list(dat0,dat3), c("ID", "tb"), verbose=TRUE),
                 "Multiple different valid codes in variable: v1 in dataset 2: \n The first value has been kept. \n IDs: 3\n Values: j&e")
})

test_that("missings in ID", {
  expect_warning(mergeData("v1",list(dat2,dat3), verbose=FALSE),
               "Found missing value in ID variable in dataset 1. Output may not be as desired." )
})

