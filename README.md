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
![image](https://user-images.githubusercontent.com/22160257/190423442-3f08f9e3-b6e4-4264-b089-dc5e0606967a.png)
