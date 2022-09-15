function main()
  df1 = fluxtowerdata()
  df2 = metdata()
  df3 = soildata()
  df4 = respdata()
  Dtime = collect(Dates.DateTime(DateTime(2019, 11, 23, 00, 00, 00)):Dates.Minute(30):now())
  df = DataFrame(datetime = Dtime)
  df = leftjoin(df, df1, on = :datetime)
  df = leftjoin(df, df2, on = :datetime, makeunique = true)
  df = leftjoin(df, df3, on = :datetime)
  df = leftjoin(df, df4, on = :datetime)
  sort!(df, :datetime)
  return df
end
