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
![image](https://user-images.githubusercontent.com/22160257/190423120-39f6ed5e-5e0c-4bdc-a33b-e5dd5f8fed7d.png)
