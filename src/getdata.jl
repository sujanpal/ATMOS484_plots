# Load necessary packages
using CSV # working with .csv files
using DataFrames # Julia DataFrames
using Dates # this is included in base Julia

function atmosflux()
  # Get path to input folders
  paths = readdir(joinpath("input","smartflux","2022"), join = true) # joinpath() adjust past for different OS

  # Get names of input folder, each one contains one .csv with one half-hour  
  folders = [readdir(paths[i], join = true) for i = 1:length(paths)] # join = true gives full path
  folders = reduce(vcat, folders)
  n = length(folders) 
  data = [] # initialise an empty array

  # Read each .csv from folders, push data
  # [push!(data, Matrix(DataFrame(CSV.File(joinpath(folders[i], "output", readdir(joinpath(folders[i], "output"))[2]), skipto = 4)))) for i in 1:n]
  for i = 1:n
    try
      #println(i)
      push!(data, Matrix(DataFrame(CSV.File(joinpath(folders[i], "output", readdir(joinpath(folders[i], "output"))[2]), skipto = 4))))
    catch 
      #println("skipped") # just a few half-hour have issues
    end
  end
  data = reduce(vcat, data) # convert Array of Array to Array
  nr = size(data)[2]
  data = data[:, 1:nr-1]

  # Get column names 
  header = names(DataFrame(CSV.File(joinpath(folders[1], "output", readdir(joinpath(folders[1], "output"))[2]), header = 2, skipto = 4)))

  # Generate dataframe from data matrix and header
  df = DataFrame(data, header)
  dt = df.date + df.time # DateTime vector
  df[!, "datetime"] = dt

  # Continous datetime 
  datetime = collect(df.datetime[1]:Minute(30):df.datetime[end]) # continuous half-hourly datetime array
  dfd = DataFrame(datetime = datetime)
  df = leftjoin(dfd, df, on = :datetime)
  sort!(df, :datetime)

  return df
end

df = atmosflux()

# write df dataframe to a file
path = joinpath("output", "atmosflux.csv")
CSV.write(path, df) 

# Download and load met data
function loadmet()
	path = joinpath("output", "met")
        [download("http://www.atmos.anl.gov/ANLMET/numeric/2019/"*i*"19met.data", joinpath(path, i*"19met.data")) for i in ["nov", "dec"]];
        [download("http://www.atmos.anl.gov/ANLMET/numeric/2020/"*i*"20met.data", joinpath(path, i*"20met.data")) for i in ["jan", "feb","mar","apr","may","jun","jul","aug","sep","oct","nov","dec"]];
	[download("http://www.atmos.anl.gov/ANLMET/numeric/2021/"*i*"21met.data", joinpath(path, i*"21met.data")) for i in ["jan", "feb","mar","apr","may","jun","jul","aug","sep","oct","nov","dec"]];
	[download("http://www.atmos.anl.gov/ANLMET/numeric/2022/"*i*"22met.data", joinpath(path, i*"22met.data")) for i in ["jan", "feb","mar","apr","may"]];
	col_name = [:DOM,:Month,:Year,:Time,:PSC,:WD60,:WS60,:WD_STD60,:T60,:WD10,:WS10,:WD_STD10,:T10,:DPT,:RH,:TD100,:Precip,:RS,:RN,:Pressure,:WatVapPress,:TS10,:TS100,:TS10F]
	metdata = DataFrame[]
	[push!(metdata, CSV.read(joinpath(path, i*"19met.data"), DataFrame, delim=' ', header=col_name, ignorerepeated=true, skipto=1, footerskip=2)) for i in ["nov", "dec"]]
	[push!(metdata, CSV.read(joinpath(path, i*"20met.data"), DataFrame, delim=' ', header=col_name, ignorerepeated=true, skipto=1, footerskip=2)) for i in ["jan", "feb","mar","apr","may","jun","jul","aug","sep","oct","nov","dec"]]
	[push!(metdata, CSV.read(joinpath(path, i*"21met.data"), DataFrame, delim=' ', header=col_name, ignorerepeated=true, skipto=1, footerskip=2)) for i in ["jan", "feb","mar","apr","may","jun","jul","aug","sep","oct","nov","dec"]]
	[push!(metdata, CSV.read(joinpath(path, i*"22met.data"), DataFrame, delim=' ', header=col_name, ignorerepeated=true, skipto=1, footerskip=2)) for i in ["jan", "feb","mar","apr","may"]]
	metdata = reduce(vcat, metdata)
	return metdata
end
metdata = loadmet()

function loadDtimemet(metdata::DataFrame)
	met_n = size(metdata, 1) 
	metdata_time_str = Array{String}(undef, met_n)
	for i = 1:met_n
	    if length(string(metdata.Time[i])) == 2 # if only 2 numbers
		metdata_time_str[i] = "00$(metdata.Time[i])"
	    elseif length(string(metdata.Time[i])) == 3 # if only 3 numbers
		metdata_time_str[i] = "0$(metdata.Time[i])"
	    elseif length(string(metdata.Time[i])) == 4 # 4 numbers
		metdata_time_str[i] = string(metdata.Time[i])
	    end
	end
	# Then, we can use day of month, month, year and time
	Dtime_met = Array{DateTime}(undef, met_n)
	for i = 1:met_n
	    Dtime_met[i] = DateTime(metdata.Year[i]+2000,metdata.Month[i],metdata.DOM[i],parse(Int64,metdata_time_str[i][1:2]),parse(Int64,metdata_time_str[i][3:4]))
	end
	return Dtime_met
end
datetime = loadDtimemet(metdata)

metdata[!, "datetime"] = datetime


