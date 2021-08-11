library(tidyverse)
library(dplyr)
library(mosaic)
library(quantmod)
library(foreach)


# Get ETs
my_etfs = c("ARKK", "SDY", "GOVT",'BNO','FXY','XLF','MCHI','HYG')
etf_count = length(my_etfs)

# 5 years of data
getSymbols(my_etfs,from='2016-8-1')


# We want to look at adjusted values only
for(ticker in my_etfs) {
  expr = paste0(ticker, "a = adjustOHLC(", ticker, ")")
  eval(parse(text=expr))
}

my_etfs_adjusted = paste(my_etfs,'a',sep = '')

all_returns = cbind( ClCl(ARKKa),
                     ClCl(SDYa),
                     ClCl(GOVTa),
                     ClCl(BNOa),
                     ClCl(FXYa),
                     ClCl(XLFa),
                     ClCl(MCHIa),
                     ClCl(HYGa))

all_returns = as.matrix(na.omit(all_returns))
head(all_returns)


# Equal weighted /no opinion portfolio
allocation_equal = rep(1/etf_count,etf_count)


# Create bond allocation. 60% in two bond funds. Equal weight placed in the remaining
bond_allocation = .8
non_bond = (1-bond_allocation)/6
allocation_bond_heavy = rep(non_bond,etf_count)
allocation_bond_heavy[c(3,4)] = bond_allocation/2

# Foreign Heavy
foreign_allocation = .8
non_foreign = (1-foreign_allocation)/5
allocation_foreign = rep(non_foreign,etf_count)
allocation_foreign[c(4,5,6)] = foreign_allocation/3



# Compile three portfolios in a matrix
portfolio_weights = as.data.frame(cbind(allocation_equal,allocation_bond_heavy,allocation_foreign))

# Make sure each of the allocations sum to one
colSums(portfolio_weights) == 1


# Simulation Parameters
initial_capital = 100000
days_in_simulation = 20
simulation_count = 1000



all_ending_wealths = rep(0,simulation_count)
equal_weight_wealths = matrix(rep(0,days_in_simulation* simulation_count),nrow=simulation_count,ncol=days_in_simulation)
bondy_heavy_wealths = matrix(rep(0,days_in_simulation* simulation_count),nrow=simulation_count,ncol=days_in_simulation)
foreign_heavy_wealths = matrix(rep(0,days_in_simulation* simulation_count),nrow=simulation_count,ncol=days_in_simulation)


for (simulation_num in 1:simulation_count) {
  
  equal_weight_port = portfolio_weights$allocation_equal * initial_capital
  bond_heavy_port = portfolio_weights$allocation_bond_heavy * initial_capital
  foreign_heavy_port = portfolio_weights$allocation_foreign * initial_capital  
  
  
  for (day_num in 1:days_in_simulation) {
    returns = resample(all_returns,1) # Sample returns
    
    # Calculate ending wealth after each day
    equal_weight_port = equal_weight_port + equal_weight_port * returns
    bond_heavy_port = bond_heavy_port + bond_heavy_port * returns
    foreign_heavy_port = foreign_heavy_port + foreign_heavy_port * returns
    
    # Record the wealths for each portfolio at that point in time
    equal_weight_wealths[simulation_num,day_num] = sum(equal_weight_port)
    bondy_heavy_wealths[simulation_num,day_num] = sum(bond_heavy_port)
    foreign_heavy_wealths[simulation_num,day_num] = sum(foreign_heavy_port)
    
    # Re balance each portfolio
    equal_weight_port = equal_weight_port + portfolio_weights$allocation_equal
    bond_heavy_port = bond_heavy_port + portfolio_weights$allocation_bond_heavy
    foreign_heavy_port = foreign_heavy_port + portfolio_weights$allocation_foreign
    
  }

}


par(mfrow=c(2,2))
hist(equal_weight_wealths[,days_in_simulation],breaks=30)
abline(v=initial_capital,lwd=3,col='blue')

hist(bondy_heavy_wealths[,days_in_simulation],breaks=30)
abline(v=initial_capital,lwd=3,col='blue')

hist(foreign_heavy_wealths[,days_in_simulation],breaks=30)
abline(v=initial_capital,lwd=3,col='blue')




# On do VAR

# 5% value at risk:

quantile(equal_weight_wealths[,days_in_simulation]- initial_capital, prob=0.05)
quantile(bondy_heavy_wealths[,days_in_simulation]- initial_capital, prob=0.05)
quantile(foreign_heavy_wealths[,days_in_simulation]- initial_capital, prob=0.05)




