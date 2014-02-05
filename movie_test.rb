# Author: Steven Hu

class MovieTest

	def initialize(results)
		@results_list = results
	end

	##
	# average of the prediction errors (actual rating - prediction)
	def mean
		sum = 0.0
		@results_list.each do |u, m, r, p|
			sum += (r - p).abs
		end
		return sum / @results_list.length
	end

	##
	# standard deviation of the prediction errors
	def stddev
		average = mean
		sum = 0.0
		@results_list.each do |u, m, r, p|
			sum += ((r - p).abs - average)**2
		end
		return Math.sqrt(sum / @results_list.length)
	end

	##
	# root mean square of prediction errors
	def rms
		sum = 0.0
		@results_list.each do |u, m, r, p|
			sum += (r - p)**2
		end
		return Math.sqrt(sum / @results_list.length)
	end

	##
	# return a list of arrays containing results (u, m, r, p)
	def to_a
		return @results_list
	end
end