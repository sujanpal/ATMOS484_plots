# Generate ATMOS484 data file

## Installation

Activate the julia environment (contains dependencies such as DataFrame package)

```jl
julia> ]
pkg> activate .
pkg> instantiate # first time only, to install the packages
```

## Usage

The function `main` will download the latest data and write a file called 
"ATMOS484.csv" in the output folder. Just type:

```jl
julia> main()
```
