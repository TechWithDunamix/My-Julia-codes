using DataFrames
using CSV
using Plots
using Dates

function initialize_expense_tracker(filename::String)
    if isfile(filename)
        return CSV.read(filename, DataFrame)
    else
        return DataFrame(date=Date[], amount=Float64[], category=String[])
    end
end

function add_expense!(df::DataFrame, date::Date, amount::Float64, category::String)
    push!(df, (date, amount, category))
end

function edit_expense!(df::DataFrame, id::Int, new_date::Date, new_amount::Float64, new_category::String)
    df[id, :] = (new_date, new_amount, new_category)
end

function delete_expense!(df::DataFrame, id::Int)
    delete!(df, id)
end

function save_expenses(df::DataFrame, filename::String)
    CSV.write(filename, df)
end

function summarize_expenses(df::DataFrame)
    summary = combine(groupby(df, :category), :amount => sum => :total_amount)
    return summary
end

function set_budget(budgets::Dict{String, Float64}, category::String, amount::Float64)
    budgets[category] = amount
end

function track_budget_usage(df::DataFrame, budgets::Dict{String, Float64})
    summary = summarize_expenses(df)
    usage = Dict{String, Float64}()
    for row in eachrow(summary)
        cat = row.category
        usage[cat] = get(usage, cat, 0.0) + row.total_amount
    end
    
    return usage
end

function plot_expenses(df::DataFrame)
    summary = summarize_expenses(df)
    bar(summary.category, summary.total_amount, title="Expenses by Category", xlabel="Category", ylabel="Total Amount", legend=false)
end

function plot_monthly_trends(df::DataFrame)
    df.date = Dates.Date.(df.date)
    df.month = month.(df.date)
    monthly_summary = combine(groupby(df, :month), :amount => sum => :total_amount)
    plot(monthly_summary.month, monthly_summary.total_amount, seriestype=:line, xlabel="Month", ylabel="Total Amount", title="Monthly Expense Trends")
end

filename = "../expenses.csv"
df = initialize_expense_tracker(filename)

add_expense!(df, Date("2024-09-01"), 50.0, "Food")
add_expense!(df, Date("2024-09-02"), 100.0, "Transport")
add_expense!(df, Date("2024-09-03"), 75.0, "Entertainment")

edit_expense!(df, 1, Date("2024-09-01"), 55.0, "Food")

delete_expense!(df, 2)

save_expenses(df, filename)

budgets = Dict("Food" => 200.0, "Transport" => 150.0, "Entertainment" => 100.0)
usage = track_budget_usage(df, budgets)
println("Budget Usage:")
println(usage)

println("Expense Summary:")
println(summarize_expenses(df))

plot_expenses(df)
plot_monthly_trends(df)
