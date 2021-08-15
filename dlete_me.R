# Simulation Parameters
initial_capital = 100000
days_in_simulation = 20
simulation_count = 100



# all_ending_wealths = rep(0,simulation_count) # matrix to store ending wealths

# Create 3 matrices to store the daily wealths of each portfolio
# These will be 10,000 X 20 dim matrices
equal_weight_wealths = data.frame(matrix(rep(0,days_in_simulation* simulation_count),nrow=simulation_count,ncol=days_in_simulation))
bondy_heavy_wealths = data.frame(matrix(rep(0,days_in_simulation* simulation_count),nrow=simulation_count,ncol=days_in_simulation))
foreign_heavy_wealths = data.frame(matrix(rep(0,days_in_simulation* simulation_count),nrow=simulation_count,ncol=days_in_simulation))


for (simulation_num in 1:simulation_count) {
  
  # 3 Vectors containing the dollar value holding of each ETF 
  equal_weight_port = portfolio_weights$allocation_equal * initial_capital
  bond_heavy_port = portfolio_weights$allocation_bond_heavy * initial_capital
  foreign_heavy_port = portfolio_weights$allocation_foreign * initial_capital  
  
  
  for (day_num in 1:days_in_simulation) {
    returns = resample(all_returns,1) # Sample returns
    
    # Calculate ending wealths after each day
    equal_weight_port = equal_weight_port + equal_weight_port * returns
    bond_heavy_port = bond_heavy_port + bond_heavy_port * returns
    foreign_heavy_port = foreign_heavy_port + foreign_heavy_port * returns
    
    # Record the wealths for each portfolio at that point in time
    equal_weight_wealths[simulation_num,day_num] = sum(equal_weight_port)
    bondy_heavy_wealths[simulation_num,day_num] = sum(bond_heavy_port)
    foreign_heavy_wealths[simulation_num,day_num] = sum(foreign_heavy_port)
    
    # Re balance each portfolio
    equal_weight_port = sum(equal_weight_port) * portfolio_weights$allocation_equal
    bond_heavy_port = sum(bond_heavy_port) * portfolio_weights$allocation_bond_heavy
    foreign_heavy_port = sum(foreign_heavy_port) * portfolio_weights$allocation_foreign
    
    # verifify = equal_weight_port/(sum(equal_weight_port)) == portfolio_weights$allocation_equal
    # print(verifify)
    
    
  }
  
}