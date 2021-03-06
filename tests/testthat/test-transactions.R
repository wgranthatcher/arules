library("arules")
library("testthat")

context("transactions")

data <- list(
  c("a","b","c"),
  c("a","b"),
  c("a","b","d"),
  c("b","e"),
  c("a","d"),
  c("d","e"),
  c("d","f"),
  c("a","b","d","e","f","g")
    )
names(data) <- paste("Tr",c(1:8), sep = "")

##################################################
### test transactions

trans <- as(data, "transactions")
#trans
#summary(trans)
#inspect(trans[1:2])

expect_identical(size(trans), unname(sapply(data, length)))
expect_identical(data, as(trans, "list"))
expect_identical(transactionInfo(trans)$transactionID, names(data))
expect_identical(sort(itemInfo(trans)$labels), sort(unique(unique(unlist(data)))))

## combine
expect_equal(c(trans, trans), as(c(data, data),"transactions"))

m <- as(trans, "matrix")
#m
expect_identical(data, as(as(m, "transactions"), "list"))
expect_identical(dim(m), dim(trans))
expect_identical(nrow(m), length(trans))
expect_identical(dimnames(m), dimnames(trans))

expect_equal(c(trans, trans), as(rbind(m, m),"transactions"))

## combine with missing items (needs recoding)
expect_true(all(as(c(trans[,-2], trans[,-3]), "matrix")[1:8,"b"]) == FALSE)
expect_true(all(as(c(trans[,-2], trans[,-3]), "matrix")[9:15,"c"]) == FALSE)

l <- LIST(trans, decode = FALSE)
expect_identical(length(l), nrow(trans))
expect_identical(as(trans, "ngCMatrix")@i+1L, unlist(l))

###########################################################################
### compare transactions with items b, c, d 

t <- as(data, "transactions")[,2:4]
t_comp <- as(m[,2:4], "transactions")

## NOTE: rownames in itemInfo do not agree due to subsetting!
rownames(t@itemInfo) <- NULL
rownames(t_comp@itemInfo) <- NULL
expect_identical(t, t_comp)

expect_identical(as(t, "ngCMatrix"), as(t_comp, "ngCMatrix"))

## addComplement
data("Groceries")

## add a complement-items for "whole milk" and "other vegetables"
g2 <- addComplement(Groceries, c("whole milk", "other vegetables"))
g2 <- addComplement(g2, "coffee", "NO coffee")
expect_equal(nitems(g2), nitems(Groceries)+3L)
expect_identical(as.logical(as(g2[, "!whole milk"], "matrix")), 
  !as.logical(as(g2[, "whole milk"], "matrix")))
expect_identical(g2[,1:nitems(Groceries)], Groceries)

