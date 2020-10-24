## Testing within-chain multi-threading in Stan
##
## Barum Park
## Date: 10/24/2020

# Functions --------------------------------------------------------------------

# inv-logit
inv_logit = function(x) 1 / (1 + exp(-x))

# print
print_df = function(x) {
    
    message(
        paste0(
            capture.output(x),
            collapse = "\n"
        )
    )
    
}


# Set up and Data --------------------------------------------------------------

set.seed(5645436)

# libraries
library(here)
library(tictoc)
library(cmdstanr)

# rebuild cmdstan
rebuild_cmdstan(
    dir = cmdstan_path(),
    cores = 6L,
    quiet = TRUE
)

# create data
n = 10000
beta_true = c(-.5, .2)
x = rnorm(n)
xb = cbind(1, x) %*% beta_true
p = inv_logit(xb)
y = sapply(p, function(w) sample.int(2, 1, prob = c(1 - w, w)) - 1L)

# stan data list
dat = list(
    N = n,
    x = x,
    y = y
)

# Single threaded (2 parallel chains) ------------------------------------------

# compile model (single-treaded)
tic()
mod_single = cmdstan_model(
    here("stan", "logit_single.stan")
)
toc()


# check code
mod_single$print()

# sample
fit_single = mod_single$sample(
    data = dat,
    seed = 321,
    chains = 2, 
    parallel_chains = 2,
    iter_warmup = 1000,
    iter_sampling = 5000,
    refresh = 500
)

# check summary statistics
print_df(fit_single$summary())


# Multi-threaded (2 parallel chains, 3 threads each) ---------------------------

# compile model (multi-threaded)
tic()
mod_multi = cmdstan_model(
    here("stan", "logit_multi.stan"), 
    cpp_options = list(stan_threads = TRUE) # notice this here!
)
toc()


# check
mod_multi$print()

# let Stan automatically choose chunk size
dat$grainsize = 1

# sample
fit_multi = mod_multi$sample(
    data = dat,
    seed = 321,
    chains = 2, 
    parallel_chains = 2,
    threads_per_chain = 3,
    iter_warmup = 1000,
    iter_sampling = 5000,
    refresh = 500
)


# check summaries
print_df(fit_single$summary())


### END OF CODE ###
