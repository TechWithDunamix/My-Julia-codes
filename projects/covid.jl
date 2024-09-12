using CSV
using DataFrames
using Statistics
using Dates

# Step 1: Load the CSV data into a DataFrame
df = CSV.read("../datas/covid.csv", DataFrame)

# Step 2: Data Preprocessing
# Convert date to Julia Date format
# df.date = Date.(df.date, "yyyy-mm-dd")

# Select relevant columns
select!(df, :iso_code, :continent, :location, :date, :total_cases, :new_cases, :total_deaths, :new_deaths, :total_vaccinations, :people_vaccinated, :people_fully_vaccinated)

# Fill missing data with zeros where appropriate
df.new_cases = coalesce.(df.new_cases, 0)
df.new_deaths = coalesce.(df.new_deaths, 0)

# Step 4: Country-Specific Analysis
function country_analysis(df::DataFrame, country::String)
    country_data = df[df.location .== country, :]
    
    # Calculate daily change rate
    country_data[!, :daily_change_rate] = [i == 1 ? 0.0 : (country_data.new_cases[i] - country_data.new_cases[i-1]) / country_data.new_cases[i-1] * 100 for i in 1:length(country_data.new_cases)]
    
    # Calculate case doubling time
    function calculate_doubling_time(new_cases::Vector{Float64})
        doubling_times = []
        for i in 2:length(new_cases)
            if new_cases[i] > 0 && new_cases[i-1] > 0
                doubling_time = log(2) / log(new_cases[i] / new_cases[i-1])
                push!(doubling_times, doubling_time)
            else
                push!(doubling_times, NaN)
            end
        end
        return vcat([NaN], doubling_times)
    end
    country_data[!, :doubling_time] = calculate_doubling_time(country_data.new_cases)
    
    # Summary statistics
    summary_stats = describe(country_data[!, :new_cases])
    
    # Peak analysis
    peak_day_index = argmax(country_data.new_cases)
    peak_day = country_data.date[peak_day_index]
    peak_value = country_data.new_cases[peak_day_index]
    
    println("Country: $country")
    println("Peak New Cases Day: $peak_day, Number of Cases: $peak_value")
    println("Summary Statistics for New Cases: ", summary_stats)
    
    # Export to CSV
    CSV.write("analyzed_$country.csv", country_data)
end

# Example: Analyze data for a specific country
country_analysis(df, "United States")

# Step 5: Continent-Wide Analysis
function continent_analysis(df::DataFrame, continent::String)
    continent_data = df[df.continent .== continent, :]
    
    # Aggregate statistics
    aggregate_stats = combine(groupby(continent_data, :date), 
                              :total_cases => sum,
                              :new_cases => sum,
                              :total_deaths => sum,
                              :new_deaths => sum,
                              :total_vaccinations => sum,
                              :people_vaccinated => sum,
                              :people_fully_vaccinated => sum)
    
    # Summary statistics for cases and deaths
    case_stats = describe(continent_data[!, :total_cases])
    death_stats = describe(continent_data[!, :total_deaths])
    
    println("Continent: $continent")
    println("Summary Statistics for Total Cases: ", case_stats)
    println("Summary Statistics for Total Deaths: ", death_stats)
    
    # Export to CSV
    CSV.write("analyzed_$continent.csv", aggregate_stats)
end

# Example: Analyze data for a specific continent
continent_analysis(df, "Asia")

# Step 6: Temporal Analysis for a Country
function temporal_analysis(df::DataFrame, country::String)
    country_data = df[df.location .== country, :]
    
    # Calculate trends over time
    trends = combine(groupby(country_data, :date), 
                     :new_cases => sum,
                     :new_deaths => sum,
                     :total_vaccinations => sum,
                     :people_vaccinated => sum,
                     :people_fully_vaccinated => sum)
    
    # Export to CSV
    CSV.write("temporal_analysis_$country.csv", trends)
end

# Example: Temporal analysis for a specific country
temporal_analysis(df, "United States")
