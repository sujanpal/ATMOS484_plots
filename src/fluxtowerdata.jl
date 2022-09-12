"""
    fluxtowerdata()

Generates a DataFrame containing flux data from smartflux input
"""
function fluxtowerdata()
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

