#!/usr/bin/env Rscript
# Names that R chunks define and use, from the parse tree (nothing is evaluated).
#   Rscript rdeps.R IN.json OUT.json
# IN  is a list of {"id": ..., "code": ...}; OUT is a list of {id, defs, uses, libs, py_uses, py_defs, events, error}.
# events lists the random number and seed calls in the order they appear ("rng" or "seed"), for the RNG state check of chunkdeps.py.
# A name inside a formula or a data frame verb (a column) is reported as a use like any other; chunkdeps.py only acts on names that a chunk defines.
suppressMessages(library(jsonlite))

RNG <- c("rnorm", "runif", "rbinom", "rpois", "rexp", "rgamma", "rbeta", "rt", "rchisq", "rmultinom", "rweibull", "rlogis", "rcauchy", "rgeom",
         "rhyper", "rnbinom", "sample", "sample.int", "mvrnorm", "rmvnorm", "rdirichlet", "rWishart", "rlnorm", "rsignrank", "rwilcox", "rinvgamma",
         "rtruncnorm", "rpg", "rpolyagamma", "rmvt", "rwishart", "rbernoulli", "simulate", "jitter", "rnormmix", "rlaplace", "rsn", "rgig", "rskewnorm",
         "createDataPartition", "createFolds", "trainControl", "randomForest", "cv.glmnet", "kmeans", "bsts", "sample_n", "sample_frac", "slice_sample", "initial_split")
SEED <- c("set.seed")
ASSIGN <- c("<-", "=", "<<-")
RASSIGN <- c("->", "->>")

analyze <- function(code) {
  st <- new.env()
  st$defs <- character(); st$uses <- character(); st$libs <- character(); st$loads <- character()
  st$py_uses <- character(); st$py_defs <- character(); st$events <- character()

  use <- function(nm, locals) {
    if (nzchar(nm) && !(nm %in% locals) && !(nm %in% st$defs)) st$uses <- c(st$uses, nm)
  }

  walk_all <- function(lst, locals) {
    for (i in seq_along(lst)) {
      if (identical(lst[[i]], quote(expr = ))) next
      walk(lst[[i]], locals)
    }
  }

  do_assign <- function(lhs, locals) {
    if (is.character(lhs) && length(lhs) == 1) { st$defs <- c(st$defs, lhs); return(invisible()) }
    if (is.symbol(lhs)) { st$defs <- c(st$defs, as.character(lhs)); return(invisible()) }
    if (is.call(lhs)) {
      fn <- if (is.symbol(lhs[[1]])) as.character(lhs[[1]]) else ""
      if (fn == "$" && is.symbol(lhs[[2]]) && as.character(lhs[[2]]) == "py") {
        st$py_defs <- c(st$py_defs, as.character(lhs[[3]])); return(invisible())
      }
      # x[i] <- v, x$a <- v, names(x) <- v: x is used and defined again
      args <- as.list(lhs)[-1]
      if (length(args) > 1) walk_all(args[-1], locals)
      if (length(args) >= 1) {
        tgt <- args[[1]]
        while (is.call(tgt) && length(tgt) >= 2) {
          walk_all(as.list(tgt)[-c(1, 2)], locals)
          tgt <- tgt[[2]]
        }
        if (is.symbol(tgt) && nzchar(as.character(tgt))) {
          nm <- as.character(tgt)
          use(nm, locals)
          st$defs <- c(st$defs, nm)
        }
      }
    }
    invisible()
  }

  walk <- function(e, locals = character()) {
    if (is.symbol(e)) {
      use(as.character(e), locals)
      return(invisible())
    }
    if (!is.call(e)) return(invisible())
    f <- e[[1]]
    fn <- if (is.symbol(f)) as.character(f) else ""
    args <- as.list(e)[-1]
    if (fn %in% ASSIGN) {
      walk(e[[3]], locals); do_assign(e[[2]], locals)
    } else if (fn %in% RASSIGN) {
      walk(e[[2]], locals); do_assign(e[[3]], locals)
    } else if (fn == "function") {
      fa <- names(e[[2]])
      walk_all(as.list(e[[2]]), locals)
      walk(e[[3]], c(locals, fa))
    } else if (fn == "for") {
      walk(e[[3]], locals); st$defs <- c(st$defs, as.character(e[[2]])); walk(e[[4]], locals)
    } else if (fn %in% c("$", "@")) {
      if (is.symbol(e[[2]]) && as.character(e[[2]]) == "py" && fn == "$") {
        st$py_uses <- c(st$py_uses, as.character(e[[3]]))
      } else walk(e[[2]], locals)
    } else if (fn %in% c("::", ":::")) {
      invisible()
    } else if (fn %in% c("quote", "bquote", "expression", "substitute")) {
      invisible()
    } else if (fn %in% c("library", "require", "requireNamespace", "loadNamespace")) {
      if (length(args) >= 1) {
        a <- args[[1]]
        if (is.symbol(a)) st$libs <- c(st$libs, as.character(a)) else if (is.character(a)) st$libs <- c(st$libs, a)
      }
    } else if (fn == "load") {
      st$loads <- c(st$loads, "*")
      walk_all(args, locals)
    } else if (fn %in% c("data", "getSymbols")) {
      lits <- function(a) {
        if (is.character(a)) a
        else if (is.symbol(a) && fn == "data") as.character(a)
        else if (is.call(a) && identical(a[[1]], as.name("c"))) unlist(lapply(as.list(a)[-1], lits))
        else character()
      }
      if (length(args) >= 1 && !identical(args[[1]], quote(expr = )) && is.null(names(args)[1][nzchar(names(args)[1])][1])) st$defs <- c(st$defs, lits(args[[1]]))
      else if (length(args) >= 1 && !identical(args[[1]], quote(expr = ))) st$defs <- c(st$defs, lits(args[[1]]))
      use(fn, locals)
      walk_all(args, locals)
    } else if (fn == "assign") {
      if (length(args) >= 1 && is.character(args[[1]])) st$defs <- c(st$defs, args[[1]])
      walk_all(args[-1], locals)
    } else {
      if (fn %in% RNG) st$events <- c(st$events, "rng")
      if (fn %in% SEED) st$events <- c(st$events, "seed")
      if (is.call(f)) {
        if (is.call(f) && as.character(f[[1]])[1] %in% c("::", ":::")) {
          nm <- as.character(f[[3]]); if (nm %in% RNG) st$events <- c(st$events, "rng")
        } else walk(f, locals)
      } else use(fn, locals)
      walk_all(args, locals)
    }
    invisible()
  }

  res <- tryCatch({
    exprs <- parse(text = code, keep.source = FALSE)
    for (e in as.list(exprs)) walk(e)
    NULL
  }, error = function(err) conditionMessage(err))
  list(defs = unique(st$defs), uses = unique(st$uses), libs = unique(st$libs), loads = unique(st$loads), py_uses = unique(st$py_uses), py_defs = unique(st$py_defs),
       events = st$events, error = if (is.null(res)) "" else res)
}

args <- commandArgs(TRUE)
chunks <- fromJSON(args[1], simplifyVector = FALSE)
out <- lapply(chunks, function(ch) {
  r <- analyze(ch$code)
  c(list(id = ch$id), lapply(r, function(x) if (length(x) == 0) list() else as.list(x)))
})
write(toJSON(out, auto_unbox = TRUE), args[2])
