# Load data

using DataFrames, CSV

path = joinpath("Input","eddypro_ATMOS_full_output_2021-11-10T100129_exp.csv")

data = DataFrame(CSV.File(path,
			  header = 2,
			  missingstring = ["-9999"],
			  skipto = 4)) # data starts at row 4

# Add a datetime column combining date and time

using GLMakie

scatter(-data.co2_flux)


