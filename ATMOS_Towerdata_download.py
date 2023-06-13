# Python script to download and plot ATMOS 60-m Tower MET data
# Sujan Pal, ANL EVS - 2022

# import modules to download the data
import wget
# import modules to load the downloaded data in pandas
import numpy as np
import pandas as pd
#import modules to plot
import matplotlib.pyplot as plt

# Automated downloading of data
base_url = 'http://www.atmos.anl.gov/ANLMET/numeric/'
months = ["jan", "feb","mar","apr","may","jun","jul","aug","sep","oct","nov","dec"]
for year in range(19,23):
    print(year)
    for month in months:
        print(month)
        to_download = base_url+'20'+str(year)+'/'+month+str(year)+'met.data'
        print(to_download)
        wget.download(to_download,'/home/spal/notebooks/CROCUS/metdata/'+month+str(year)+'met.data')
		

# load data from all the files and combine as a single pandas dataframe 
months = ["jan", "feb","mar","apr","may","jun","jul","aug","sep","oct","nov","dec"]
col_names = ['DOM','Month','Year','Time','PSC','WD60','WS60','WD_STD60','T60','WD10','WS10','WD_STD10','T10','DPT','RH','TD100','Precip','RS','RN','Pressure','WatVapPress','TS10','TS100','TS10F']
metdata = []
for year in range(19,22):
    print(year)
    for month in months:
        filename = '/home/spal/notebooks/CROCUS/metdata/'+month+str(year)+'met.data'
        df = pd.read_csv(filename,sep='\s+',header =None)
        metdata.append(df)
all_data = pd.concat(metdata, axis=0, ignore_index=True)
all_data.columns = col_names
print(all_data.head())

# Process and clean the dataframe for calculations and plotting
# drop all NaN values
all_data = all_data.dropna() 
# Format the columns 
all_data['Month'] = all_data['Month'].astype(int)
all_data['Time'] = all_data['Time'].astype(int)
all_data['DOM'] = all_data['DOM'].astype(int)
# Standardizing year from 2 digit to 4 by appending 20 to the start, e.g 19 -> 2019
all_data['Year'] =  '20' +  all_data['Year'].astype(int).astype(str)
# Standardizing timestamp to 4 digits by filling with leading zeros , e.g 30 -> 0030
all_data['Time'] = all_data['Time'].astype(str).str.zfill(4)
# Temporary column to hold the merged date columns
all_data['RawDate'] = all_data['Month'].astype(str) + '-' + all_data['DOM'].astype(str) +'-' + all_data['Year'].astype(str) + " " + all_data['Time'].astype(str)
# Converting string to date
all_data['Date'] = pd.to_datetime(all_data['RawDate'], format='%m-%d-%Y %H%M', exact=False)
# Remove the spikes in Precip
all_data = all_data[all_data['Precip'] < 1000] 
# Set date time as index of the dataframe
all_data.set_index('Date')

## Plotting
# Plot timeseries
fig,ax1 = plt.subplots(figsize=(10,5))
ax1.plot(all_data['Date'],all_data['Precip'], label="rainfall",color='blue')
ax1.set_ylabel('Rainfall (mm)', fontsize =14)
ax1.set_title("Precipitation at ATMOS",fontweight="bold", fontsize=14)
ax1.legend(fontsize=14)
plt.grid()
plt.savefig('ATMOS_precip.png', dpi=300)

#Plot total monthly rainfall 
fig,ax1 = plt.subplots(figsize=(10,5))
all_data.groupby(pd.PeriodIndex(all_data['Date'], freq="M"))['Precip'].sum().plot(ax=ax1,label='rainfall',color='blue')
ax1.set_ylabel('Total monthly rainfall (mm)', fontsize =14)
ax1.set_title("Precipitation at ATMOS",fontweight="bold", fontsize=14)
ax1.legend(fontsize=14)
plt.grid()
plt.savefig('ATMOS_monthly.png', dpi=300)