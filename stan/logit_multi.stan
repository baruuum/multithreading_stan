functions {
  
  real partial_sum(
    int[] y_slice,
    int start,
    int end,
    vector beta,
    vector x
  ){
    
    return bernoulli_logit_lpmf(y_slice | beta[1] + beta[2] * x[start:end]);
    
  }
  
}

data {
  
  int<lower = 0> N;
  vector[N] x;
  int<lower = 0, upper = 1> y[N];
  int<lower = 1> grainsize;
  
}

parameters {
  
  vector[2] beta;
  
}

model {
  
  beta ~ normal(0, 3);
  target += reduce_sum(partial_sum, y, grainsize, beta, x);

}

