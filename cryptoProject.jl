using DataFrames
using CSV
using MLJ
using MLJModels
using StatsBase
using Plots
using Dates

df = CSV.read("crypto.csv", DataFrame)

println("First few rows of the dataset:")
println(first(df, 5))

df = coalesce.(df, 0)

df.Date = Dates.dayofyear.(Dates.Date.(df.Date, "Y-m-d"))

df = convert(DataFrame, df)

X = select(df, Not(:Close))
y = df.Close

train_indices = randperm(nrow(df))[1:Int(0.8 * nrow(df))]
test_indices = setdiff(1:nrow(df), train_indices)

X_train = X[train_indices, :]
y_train = y[train_indices]
X_test = X[test_indices, :]
y_test = y[test_indices]

model = @load LinearRegressor pkg=MLJLinearModels

mach = machine(model, X_train, y_train)
fit!(mach)

y_pred = predict(mach, X_test)

mse = mean((y_test .- y_pred).^2)
println("Mean Squared Error: $mse")

scatter(y_test, y_pred, xlabel="Actual Prices", ylabel="Predicted Prices", title="Predicted vs Actual Prices")
