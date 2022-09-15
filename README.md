# Generate ATMOS484 data file

## Installation

Activate the julia environment (contains dependencies such as DataFrame package)

```jl
julia> ] # type ] to go into pkg mode
(@v1.8) pkg> activate . # activate local project environment
(ATMOS484) pkg> instantiate # first time only, to install dependencies
(ATMOS484) pkg> # type Backspace button to go back to julia mode
julia> using ATMOS484 # use the ATMOS484 package
```

## Usage

The function `main` will download the latest data and write a file called 
"ATMOS484.csv" in the output folder. Just type:

```jl
julia> main()
```
![image](https://user-images.githubusercontent.com/22160257/190423442-3f08f9e3-b6e4-4264-b089-dc5e0606967a.png)

## Input

### metdata

`metdata()` downloads data from https://www.atmos.anl.gov/ANLMET/, up to may 2022. <br /> 
TO DO: script should download up to latest available month. <br />

### fluxtowerdata

`fluxtowerdata()` generates a dataframe from the smartflux output (1 file per half-hour). <br />
The smartflux data is manually put on a google drive repo, then manually put in the input folder of ATMOS484. <br />
TO DO 1: script could directly download the data from the google drive repo.<br />
TO DO 2: a raspberry pi could automatically send the data to the remote google drive repo. <br />

### soildata

`soildata()` generates a dataframe from 11 datasets (1 per datalogger), each containing 6 sensor data. <br />
The data is downloaded using [this python script](https://github.com/Land-atmosphere-interface-heterogeneity/GIF-TEROS11-Julia/blob/master/DownloadZentradata.py), 
which download the complete datasets (re-download each time), and takes 10 hours to run... Then, the data is manually put in the input folder of ATMOS484. <br />
TO DO: adapt the download python script to only download recent data (that is not yet downloaded), and call that script from `soildata()`<br />

### respdata

`respdata()` process input data collected in 2020 and 2021, there is no more data being collected in the field. <br />
TO DO: that input data could be hosted somewhere and downloaded from `respdata()`<br />
