# StippleActiveTables

StippleActiveTables is a plugin for [Stipple](https://github.com/GenieFramework/Stipple.jl) that provides reactive integration with [Active-Table](https://activetable.io/), a powerful interactive table component for displaying and editing tabular data.

Active-Table is a modern, fully-featured data table component with built-in support for:
- Interactive editing
- Column sorting and filtering
- Data validation
- Formula support
- Import/Export functionality
- And many more features

## Installation

```julia
using Pkg
Pkg.add("StippleActiveTables")
```

## Features

- Seamless integration between Julia DataFrames and Active-Table
- Reactive two-way data binding with Stipple
- Automatic synchronization of edits back to Julia
- Simple API with minimal boilerplate

## Usage

### Basic Example

```julia
using Stipple, Stipple.ReactiveTools, StippleUI
using StippleActiveTables
using DataFrames

# Create a sample DataFrame
df = DataFrame(
    team1 = ["Team A", "Team B"],
    team2 = ["Team C", "Team D"],
    score1 = [85, 90],
    score2 = [80, 95]
)

@app MyApp begin
    @in activetable = ActiveTable(df)
end

@deps MyApp StippleActiveTables

ui() = htmldiv([
    h3(style = "margin-bottom: 1em", "StippleActiveTables Demo")
    activetable(:activetable)
])

@page("/", ui, model = MyApp)

up()
```

## API

### Types

**`ActiveTable`**
```julia
ActiveTable(df::DataFrame)
```
Wraps a DataFrame to make it compatible with the Active-Table component. The data is automatically synchronized between Julia and the browser.

### Functions

**`activetable(data::Symbol, args...; kwargs...)`**

Renders an Active-Table component bound to a reactive `ActiveTable` variable.

**Arguments:**
- `data::Symbol`: Symbol referring to an `ActiveTable` reactive variable in your model

**Example:**
```julia
@app MyApp begin
    @in my_table = ActiveTable(DataFrame(a=[1,2,3], b=[4,5,6]))
end

ui() = activetable(:my_table)
```

## How It Works

StippleActiveTables automatically handles the conversion between Julia's DataFrames and Active-Table's expected format:
- DataFrames are serialized as a vector of rows, with column names as the first element
- Changes made in the browser are parsed back into a DataFrame
- The reactive binding keeps everything synchronized in real-time

## Dependencies

- [Stipple.jl](https://github.com/GenieFramework/Stipple.jl) - Reactive UI framework
- [DataFrames.jl](https://github.com/JuliaData/DataFrames.jl) - Tabular data structures
- [Active-Table](https://activetable.io/) v1.1.8 - Interactive table component (bundled)

## License

See [LICENSE](LICENSE) file for details.

## Author

Helmut Hänsel
