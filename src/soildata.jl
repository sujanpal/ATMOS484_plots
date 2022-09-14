"""
    soildata()

Generates a DataFrame containing ATMOS484 soil temperature and moisture data 
"""
function soildata()
  path = joinpath("input", "TEROS")
  input = readdir(path)
  permute!(input,[3,4,5,6,7,8,9,10,11,1,2]) # need to reorder from 1 to 11
  n = length(input) # this is the number of input files, useful later
  data = DataFrame[]
  [push!(data, CSV.read(joinpath(path, input[i]), DataFrame, dateformat="yyyy-mm-dd HH:MM:SS+00:00")) for i in 1:n]
  x = [0,0,0,1,1,1,2,2,2,3,3,3,4,4,4,5,5,5,6,6,6,7,7,7,0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,0,0,0,1,1,1,2,2,2,3,3,3,4,4,4,5,5,5,6,6,6,7,7,7] 
  y = [0,1,2,2,1,0,0,1,2,2,1,0,0,1,2,2,1,0,0,1,2,2,1,0,3,4,4,3,4,3,3,4,4,3,3,4,4,3,4,3,5,6,7,7,6,5,5,6,7,7,6,5,5,6,7,7,6,5,5,6,7,7,6,5] 

  Dtime = collect(Dates.DateTime(DateTime(2019, 11, 23, 00, 00, 00)):Dates.Minute(30):now())

  # Rearrange SWC and Tsoil
  SWC = DataFrame[]
  for i = 1:11 # 11 datalogger
    for j = 1:6 # 6 sensors per datalogger
      push!(SWC, filter([:port, :units] => (port, units) -> port == j && units == " m³/m³", data[i]))
    end
  end
  Tsoil = DataFrame[]
  for i = 1:11 # 11 datalogger
    for j = 1:6 # 6 sensors per datalogger
      push!(Tsoil, filter([:port, :units] => (port, units) -> port == j && units == " °C", data[i]))
    end
  end
  deleteat!(SWC, [35, 36])
  deleteat!(Tsoil, [35, 36])

  # naming SWC columns by x y locations
  SWC_names = []
  Tsoil_names = []
  [push!(SWC_names, string("SWC_", string(x[i]), string(y[i]))) for i = 1:64]
  [push!(Tsoil_names, string("Tsoil_", string(x[i]), string(y[i]))) for i = 1:64]

  df = DataFrame(datetime = Dtime)
  for i = 1:64
    df = leftjoin(df, SWC[i][:, [:datetime, :value]], on = :datetime)
    sort!(df, :datetime)
    rename!(df, :value => SWC_names[i])
  end
  for i = 1:64
    df = leftjoin(df, Tsoil[i][:, [:datetime, :value]], on = :datetime)
    sort!(df, :datetime)
    rename!(df, :value => Tsoil_names[i])
  end
  return df
end

