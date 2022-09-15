function respdata()
# MANUAL Rsoil
  path = joinpath("input","resp","SFP output","Manual")
  inputs = readdir(path)
  n = length(inputs)
  dataRSM = DataFrame[]
  [push!(dataRSM, CSV.read(joinpath(path, inputs[i]), DataFrame, dateformat="yyyy-mm-dd HH:MM:SS", missingstring = "missing", silencewarnings = true)) for i in 1:n]
  [rename!(dataRSM[i], string.("RSM_", names(dataRSM[i]))) for i = 1:13]
  dt_RSM = Dict(1:13 .=> [[] for i = 1:13])
  [push!(dt_RSM[i], floor.(dataRSM[i].RSM_Date_IV, Dates.Minute(30))) for i = 1:13]
  df_RSM = Dict(1:13 .=> [[] for i = 1:13])
  [push!(df_RSM[i], insertcols!(dataRSM[i], 1, :datetime => dt_RSM[i][1])) for i = 1:13]
  coord = DataFrame(CSV.File(joinpath("input", "resp", "surveyorder.txt")))
  RSM_Coords = [] 
  [push!(RSM_Coords, Symbol.(string("RSM_", string(coord.x[i]), string(coord.y[i])))) for i = 1:64]
  RSM_df = Dict(RSM_Coords .=> [[] for i = 1:64])
  [push!(RSM_df[RSM_Coords[j]], dataRSM[i][j, 1:5]) for j = 1:64, i = 1:13]  
# need to convert from DataFrameRow to DataFrame
  RSM_vec = [DataFrame(RSM_df[i]) for i in RSM_Coords]
  RSM_df = Dict(RSM_Coords .=> [[] for i = 1:64])
  [push!(RSM_df[RSM_Coords[j]], RSM_vec[j]) for j in 1:64]
# now, need to append _coord to each column name except datetime
  i = 1
  for D in RSM_Coords
    rename!(RSM_df[D][1], string.(names(RSM_df[D][1]), "_", string(coord.x[i]), string(coord.y[i])))
    i += 1
    rename!(RSM_df[D][1], names(RSM_df[D][1])[1] => :datetime)
  end
  Dtime = collect(Dates.DateTime(DateTime(2019, 11, 23, 00, 00, 00)):Dates.Minute(30):now())
  df = DataFrame(datetime = Dtime)
# leftjoin for each of the 64 RSM_df
  for D in RSM_Coords
    df = leftjoin(df, RSM_df[D][1], on = :datetime) 
  end
  sort!(df, :datetime)

# AUTO Rsoil
  path = joinpath("input","resp","SFP output","Auto")
  inputs = readdir(path)
  dataRSA = DataFrame(CSV.File(joinpath(path, inputs[1]), dateformat="yyyy-mm-dd HH:MM:SS"))
  select!(dataRSA, Not(:Column9)) # delete last column of missing 
  dataRSA = dropmissing(dataRSA) # delete rows that are messed up due to instrument errors
# create one dataframe per port#
  df_RSA1 = filter(:"Port#" => x -> x == 1, dataRSA)
  df_RSA2 = filter(:"Port#" => x -> x == 2, dataRSA)
  df_RSA3 = filter(:"Port#" => x -> x == 3, dataRSA)
  df_RSA4 = filter(:"Port#" => x -> x == 4, dataRSA)
  dt_RSA1 = floor.(df_RSA1.Date_IV, Dates.Minute(30))
  dt_RSA2 = floor.(df_RSA2.Date_IV, Dates.Minute(30))
  dt_RSA3 = floor.(df_RSA3.Date_IV, Dates.Minute(30))
  dt_RSA4 = floor.(df_RSA4.Date_IV, Dates.Minute(30))
  rename!(df_RSA1, string.("RSA_", names(df_RSA1), "_1"))
  rename!(df_RSA2, string.("RSA_", names(df_RSA2), "_2"))
  rename!(df_RSA3, string.("RSA_", names(df_RSA3), "_3"))
  rename!(df_RSA4, string.("RSA_", names(df_RSA4), "_4"))
  insertcols!(df_RSA1, 1, :datetime => dt_RSA1)
  insertcols!(df_RSA2, 1, :datetime => dt_RSA2)
  insertcols!(df_RSA3, 1, :datetime => dt_RSA3)
  insertcols!(df_RSA4, 1, :datetime => dt_RSA4)
# delete duplicate times
  unique!(df_RSA1, :datetime)
  unique!(df_RSA2, :datetime)
  unique!(df_RSA3, :datetime)
  unique!(df_RSA4, :datetime)
# now leftjoin
  df = leftjoin(df, df_RSA1, on = :datetime)
  df = leftjoin(df, df_RSA2, on = :datetime)
  df = leftjoin(df, df_RSA3, on = :datetime)
  df = leftjoin(df, df_RSA4, on = :datetime)
  sort!(df, :datetime)
  return df
end

