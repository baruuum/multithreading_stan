data {
  
  int<lower=0> N;
  vector[N] x;
  int<lower = 0, upper = 1> y[N];
  
}

parameters {
  
  vector[2] beta;
  
}

model {
  
  beta ~ normal(0, 3);
  y ~ bernoulli_logit(beta[1] + beta[2] * x);
  
}

