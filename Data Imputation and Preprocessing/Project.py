import pandas as pd
pd.set_option('display.max_columns', None)
# Read Json Files
access_to_rural_df = pd.read_json("elec_rural%_world.json")
access_to_urban_df = pd.read_json("access_to_electricity_urban%_world.json")
access_to_world_df = pd.read_json("Acces_to_electricity.json")
transmission_distribution_losses_df =pd.read_json("electricity_transmissoin_distribution_losses.json")
production_by_nuclear_df = pd.read_json("electricity_production_nuclear_sources.json")
production_by_oil_df= pd.read_json("electricity_production_oil_sources.json")
production_by_renewable_df = pd.read_json("electricity_production_renewable_sources.json")
# All Dataframes
all_dfs = [access_to_rural_df,
access_to_urban_df,
access_to_world_df,
transmission_distribution_losses_df,
production_by_nuclear_df,
production_by_oil_df,
production_by_renewable_df]
num_cols=[]
for i in range(1960,2022):
    num_cols.append(i)
cat_cols=['Country_Name','Country_Code','Indicator_Name','Indicator_Code']
all_cols= cat_cols + num_cols
# Access to world Electricity
all_dfs[2].head()
# Optimze columns and data
for df in all_dfs:
    df.drop(index=0,columns=66,inplace=True)
    df.columns=all_cols
    df.drop(1, axis=0, inplace=True)
    df.reset_index(inplace=True)
    df.drop('index', axis=1,inplace=True)
    for v in num_cols:
        df[v]=pd.to_numeric(df[v], errors='coerce')
# Access to world Electricity
all_dfs[2].head()
# Treating Nulls with '0'
# Assumption: Representing null/NaN values with 0, assuming no access/loss/production
for df in all_dfs:
    df.fillna(0,inplace=True)
df.head()
# Transforming all year columns to one.
# Year column having its respective year.
# Respective values should be followed in another column.
for i in range(7):
    all_dfs[i] = all_dfs[i][cat_cols].merge(all_dfs[i].set_index('Country_Code')[num_cols].stack().reset_index(),on='Country_Code')
    all_dfs[i] = all_dfs[i].rename(columns = {'level_1':'Year',0:'Values'})
# Exporting CSVs
files=['access_to_rural',
'access_to_urban',
'access_to_world',
'transmission_distribution_losses',
'production_by_nuclear',
'production_by_oil',
'production_by_renewable']
for i in range(7):
    all_dfs[i].to_excel(files[i]+'.xlsx',index=False)
all_dfs[0]['Indicator_Name']