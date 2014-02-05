# Author: Steven Hu
# Test for PA2

require_relative "movie_data"
require_relative "movie_test"

puts "Running Test for PA2"

test = MovieData.new("u1.base", "u1.test")

# 1 Prediction
puts "Time for run_test to run for a factor of 1"
start = Time.now
awesome = test.run_test(1)
stop = Time.now
puts "Time to run: #{stop-start} seconds."

# 10 Predictions
puts "Time for run_test to run for a factor of 10"
start = Time.now
awesome = test.run_test(10)
stop = Time.now
puts "Time to run: #{stop-start} seconds."
puts "Printing results from run_test with 10 predictions:"
print awesome.to_a
puts ""
puts "Average of prediction errors: "
print awesome.mean
puts ""
puts "Standard Deviation of prediction errors: "
print awesome.stddev
puts ""
puts "Root Mean Square of prediction errors: "
print awesome.rms
puts ""

# 100 Predictions
puts "Time for run_test to run for a factor of 100"
start = Time.now
awesome = test.run_test(100)
stop = Time.now
puts "Time to run: #{stop-start} seconds."
puts "Printing results from run_test with 100 predictions:"
print awesome.to_a
puts ""
puts "Average of prediction errors: "
print awesome.mean
puts ""
puts "Standard Deviation of prediction errors: "
print awesome.stddev
puts ""
puts "Root Mean Square of prediction errors: "
print awesome.rms
puts ""