using CSV
using DataFrames
using Plots
using Statistics

# Load the data from a CSV file
data = CSV.read("./datas/covid.csv", DataFrame)

# Display the first few rows of the data to understand its structure
println("First few rows of the data:")
println(first(data, 5))

# Get basic information about the dataset
println("Data summary:")
println(describe(data))

# Data Cleaning: Convert date column to Date type
data.date = Date.(data.date, "yyyy-mm-dd")

# Handle missing values
# For simplicity, we'll fill missing values with zeros for numeric columns
for col in names(data)
    if eltype(data[!, col]) <: Union{Missing, Float64, Int64}
        data[!, col] = coalesce.(data[!, col], 0)
    end
end

# Descriptive Statistics
println("Descriptive Statistics:")
for col in names(data)
    if eltype(data[!, col]) <: Number
        println("Statistics for $col:")
        println("Mean: ", mean(data[!, col]))
        println("Standard Deviation: ", std(data[!, col]))
        println("Minimum: ", minimum(data[!, col]))
        println("Maximum: ", maximum(data[!, col]))
        println()
    end
end

# Visualize Total Cases Over Time
plot(data.date, data.total_cases, 
     xlabel="Date", ylabel="Total Cases", 
     title="Total Cases Over Time", 
     seriestype=:line, 
     legend=false)

# Visualize New Cases vs. New Deaths
scatter(data.new_cases, data.new_deaths,
        xlabel="New Cases",
        ylabel="New Deaths",
        title="New Cases vs. New Deaths")

# Correlation Analysis
println("Correlation matrix:")
corr_matrix = cor(Matrix(select(data, Not(:date))))
println(corr_matrix)

# Save plots to files
savefig("total_cases_over_time.png")
savefig("new_cases_vs_new_deaths.png")

println("Analysis complete. Plots saved to files.")
