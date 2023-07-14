Downloads Soil Data
Sujan Pal and Jack Colwell
Data from: loggers located at ATMOS and data collected from Zentra website
Imports
from zentra.api import *
import os 
import pandas as pd
import time
Downloads Data from the Loggers at the Zentra Website
os.chdir(r'C:\Users\colwe\OneDrive\Desktop\Argonne\ATMOS484\ATMOS484-master\input\TEROS')
​
#This token allows one to login to the Zentra website
token = ZentraToken(username=os.getenv("zentra_un"),password=os.getenv("zentra_pw"))
​
#This creates a list of the device serial numbers to be accessed
Device_SN = ["z6-19423","z6-04621","z6-04618","z6-04625","z6-04619","z6-04629","z6-04641","z6-04638","z6-04624","z6-04627","z6-04620"]
​
#This starts a counter for the devices serial numbers, starting at 0
i = 0
​
#This starts a loop while i is less than or equal to 10
while i <= 10:
    
    #This prints the current iteration of i after each pass through the loop
    print(i)
    
    #This block of code initiates a try-except block. It attempts to retrieve readings from a Zentra device specified by the serial number Device_SN[i]. It uses the ZentraReadings function or class to retrieve the readings and passes the necessary parameters, such as the serial number, token, start time, and end time.
    #The .datetime and end_time grab the desired dataset. 
    try:
        readings = ZentraReadings(sn=Device_SN[i],token=token,start_time=int(datetime.datetime(year=2022,month=6,day=1).timestamp()),end_time=int(datetime.datetime(year=2023,month=6,day=1).timestamp())) 
        
        #This prints here to show that it is downloading correctly
        print('here')
        
        #This retrieves the data values
        data = readings.timeseries[0].values
        
        #This line writes the data to a csv file
        data.to_csv(path_or_buf=str(i+1)+"_"+Device_SN[i]+".csv")
        
        #This iterates over the loop by 1 each time
        i += 1
        
    #This adds 30 seconds of wait time if the above code does not work
    except:
        time.sleep(30) # The loop will crash if we don't wait a bit. METER configuration. 
        pass

