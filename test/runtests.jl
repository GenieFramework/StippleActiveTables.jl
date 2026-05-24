using Test
using StippleActiveTables
using DataFrames
using Stipple

@testset "StippleActiveTables.jl" begin

    @testset "ActiveTable Construction" begin
        # Test basic construction
        df = DataFrame(a = [1, 2, 3], b = ["x", "y", "z"])
        at = ActiveTable(df)

        @test at isa ActiveTable
        @test at.data isa DataFrame
        @test size(at.data) == (3, 2)
        @test names(at.data) == ["a", "b"]
        @test at.data.a == [1, 2, 3]
        @test at.data.b == ["x", "y", "z"]
    end

    @testset "Stipple.render" begin
        # Test rendering to correct format
        df = DataFrame(team1 = ["Team A", "Team B"], team2 = ["Team C", "Team D"], score1 = [85, 90], score2 = [80, 95])
        at = ActiveTable(df)

        rendered = Stipple.render(at)

        @test rendered isa Vector
        @test length(rendered) == 3  # header + 2 rows
        @test rendered[1] == ["team1", "team2", "score1", "score2"]
        @test rendered[2] == ["Team A", "Team C", 85, 80]
        @test rendered[3] == ["Team B", "Team D", 90, 95]
    end

    @testset "Stipple.stipple_parse" begin
        # Test parsing from browser format back to ActiveTable
        # Format: [column_names, row1, row2, ...]
        input = [
            ["name", "age", "city"],
            ["Alice", 30, "NYC"],
            ["Bob", 25, "LA"]
        ]

        at = Stipple.stipple_parse(ActiveTable, input)

        @test at isa ActiveTable
        @test size(at.data) == (2, 3)  # 2 rows, 3 columns
        @test names(at.data) == ["name", "age", "city"]

        # Test empty vector
        empty_at = Stipple.stipple_parse(ActiveTable, [])
        @test empty_at == DataFrame
    end

    @testset "Round-trip conversion" begin
        # Test that render -> parse -> render produces the same result
        df = DataFrame(x = [1.5, 2.5, 3.5], y = [10, 20, 30], z = ["a", "b", "c"])
        at1 = ActiveTable(df)

        rendered = Stipple.render(at1)
        at2 = Stipple.stipple_parse(ActiveTable, rendered)
        rendered2 = Stipple.render(at2)

        @test rendered == rendered2
        @test at1.data == at2.data
    end

    @testset "deps function" begin
        # Test that deps() returns a vector of script tags
        deps_result = StippleActiveTables.deps()

        @test deps_result isa Vector{String}
        @test length(deps_result) == 1
        @test occursin("activetable.bundle", lowercase(deps_result[1]))
        @test occursin("script", deps_result[1])
    end

    @testset "activetable function" begin
        # Test that activetable function can be called with a symbol
        # We can't fully test the HTML output without a running Stipple app,
        # but we can test that the function exists and has the right signature
        @test hasmethod(activetable, (Symbol,))
    end

    @testset "Edge cases" begin
        # Test with empty DataFrame
        df_empty = DataFrame()
        at_empty = ActiveTable(df_empty)
        @test at_empty isa ActiveTable
        @test nrow(at_empty.data) == 0

        rendered_empty = Stipple.render(at_empty)
        @test rendered_empty isa Vector
        @test length(rendered_empty) == 1  # Just the header (empty array)

        # Test with single row
        df_single = DataFrame(col1 = [42], col2 = ["test"])
        at_single = ActiveTable(df_single)
        rendered_single = Stipple.render(at_single)
        @test length(rendered_single) == 2  # header + 1 row
        @test rendered_single[1] == ["col1", "col2"]
        @test rendered_single[2] == [42, "test"]

        # Test with single column
        df_single_col = DataFrame(only_col = [1, 2, 3, 4])
        at_single_col = ActiveTable(df_single_col)
        rendered_single_col = Stipple.render(at_single_col)
        @test length(rendered_single_col) == 5  # header + 4 rows
        @test rendered_single_col[1] == ["only_col"]
    end

    @testset "Data types" begin
        # Test with various Julia data types
        df_mixed = DataFrame(
            ints = [1, 2, 3],
            floats = [1.1, 2.2, 3.3],
            strings = ["a", "b", "c"],
            bools = [true, false, true]
        )
        at_mixed = ActiveTable(df_mixed)
        rendered_mixed = Stipple.render(at_mixed)

        @test rendered_mixed[1] == ["ints", "floats", "strings", "bools"]
        @test rendered_mixed[2] == [1, 1.1, "a", true]
        @test rendered_mixed[3] == [2, 2.2, "b", false]
        @test rendered_mixed[4] == [3, 3.3, "c", true]
    end

    @testset "Module exports" begin
        # Test that expected symbols are exported
        @test :ActiveTable in names(StippleActiveTables)
        @test :activetable in names(StippleActiveTables)
    end
end
