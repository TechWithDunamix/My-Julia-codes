using CSV
using DataFrames
using Statistics
using Random
using Plots
using StatsPlots
# using IJulia
# notebook()




pyplot()

df = CSV.read("../datas/students.csv", DataFrame)

println("First few rows of the DataFrame:")
println(first(df, 5))

println("\nSummary statistics:")
describe(df)

avg_score_by_major = combine(groupby(df, :major), :score => mean => :avg_score)
println("\nAverage score by major:")
println(avg_score_by_major)

graduated_df = filter(row -> row.graduated == true, df)
num_grads_by_major = combine(groupby(graduated_df, :major), nrow => :num_grads)
println("\nNumber of graduates by major:")
println(num_grads_by_major)

num_rows = 200 - nrow(df)

additional_rows = DataFrame(
    id = (nrow(df)+1):(200),
    name = ["Name" * string(i) for i in (nrow(df)+1):(200)],
    age = rand(18:25, num_rows),
    gender = rand(["M", "F"], num_rows),
    grade = rand(1:4, num_rows),
    score = rand(60:100, num_rows),
    graduated = rand([true, false], num_rows),
    major = rand(["Computer Science", "Mathematics", "Engineering", "Physics", "Biology"], num_rows),
    email = ["name" * string(i) * "@example.com" for i in (nrow(df)+1):(200)]
)

df_expanded = vcat(df, additional_rows)
println("\nExpanded DataFrame saved to 'students_expanded.csv'.")
CSV.write("../datas/students_expanded.csv", df_expanded)

# Plot 1: Histogram
histogram(df_expanded.score, title="Distribution of Scores", xlabel="Score", ylabel="Frequency", bins=20)

# Plot 2: Bar chart
bar(num_grads_by_major.major, num_grads_by_major.num_grads, title="Number of Graduates by Major", 
    xlabel="Major", ylabel="Number of Graduates", legend=false)

# Plot 3: Scatter plot
scatter(df_expanded.age, df_expanded.score, title="Scores by Age", xlabel="Age", ylabel="Score", 
    label="", color=:blue)

sleep(60)
