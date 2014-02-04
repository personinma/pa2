# Author: Steven Hu

require_relative 'movie_test'

class MovieData

	attr_reader :movie_list, :user_list
	def initialize(file, test = nil)
		@master_list = Array.new # will be used as the training list
		@test_list = Array.new
		@popular_list = Hash.new(0) # from PA1
		@movie_list = Hash.new([])
		@user_list = Hash.new([])
		load_data(file, test)
	end

	def load_data(file, test)
		if test.nil? == true
			load_data_helper(file, 100000, "training")
		else
			load_data_helper(file, 80000, "training")
			load_data_helper(test, 20000, "test")
		end
		# load_popularity_list # preload @popular_list
		"Data Loaded"
	end

	def load_data_helper(path, k, type)
		counter = 0
		File.open(path, "r").each_line do |line|
			if counter < k
				line = line.split
				if type == "training"
					@master_list.push([line[0].to_i,line[1].to_i,line[2].to_i])
					@user_list[line[0].to_i].push([line[1].to_i,line[2].to_i])
					@movie_list[line[1].to_i].push(line[0].to_i)
				elsif type == "test"
					@test_list.push([line[0].to_i,line[1].to_i,line[2].to_i])
				end
			end
			counter += 1
		end
	end

	##
	# helper method for load_popularity_list. method calculates
	# the popularity of a given movie id
	def popularity_helper(movie_id)
		count = 0
		rating = 0
		@master_list.each do |user, mov_id, rate|
			if mov_id == movie_id
				count += 1
				rating += rate
			end
		end
		((count * 0.7) + (rating * 0.3)).round(3)
	end

	##
	# will load the popularity factors of all the movies. 
	# method is used in load_data to prefetch @popular_list
	def load_popularity_list
		@master_list.each do |user, mov_id, rate|
			if @popular_list[mov_id] == -1
				@popular_list[mov_id] = popularity_helper(mov_id)
				end
		end
	end

	##
	# check the popularity factor of a given movie id
	def popularity(movie_id)
		if @popular_list[movie_id] == 0
			put "Movie Does Not Exist."
		else
			return @popular_list[movie_id]
		end
	end
	
	##
	# populates list of movies from most popular to least
	def popularity_list
		@popular_list.sort_by {|_,val| -val}
	end
	
	##
	# presents a similarity factor between two users
	def similarity(user1, user2)
		user_list1 = Hash.new(0)
		user_list2 = Hash.new(0)
		@master_list.each do |user, mov_id, rate|
			if user == user1
				user_list1[mov_id] = rate
			elsif user == user2
				user_list2[mov_id] = rate
			end			
		end
		similar_movies(user_list1, user_list2)
	end
	
	##
	# taken from PA1
	def similar_movies(ul1, ul2)
		common = ul1.keys & ul2.keys
		similar_ratings = 0
		common.each do |com|
			if (((ul1[com] + ul2[com]) / 2) - ul1[com]).abs <= 0.5
				similar_ratings += 1
			end
		end
		return common.length + similar_ratings
	end

	##
	# taken from PA1
	def most_similar(u)
		similar_list = Hash.new(0)
		@master_list.each do |user, mov_id, rate|
			if similar_list[user] == 0 and user != u
				similar_list[user] = similarity(u, user)
				end
		end
		similar_list.sort_by {|_, val| -val}
	end

	##
	# returns an array of movies user u watched (taken from training set)
	def movies(u)
		u_movies = []
		temp = @user_list[u]
		temp.each do |mov_id, rate|
			u_movies.push(mov_id)
		end
		return u_movies
	end

	##
	# returns an array of users who watched movie m (taken from training set)
	def viewers(m)
		@movie_list[m]
	end

	##
	# rating user u gave for movie m in training set
	def rating(u, m)
		temp = @user_list[u]
		temp.each do |mov_id, rate|
			if mov_id == m
				return rate
			end
		end
		# returning 0 if user did not rate movie m
		return 0
	end

	##
	# predict method for prediction rating of movie m from user u
	def predict(u, m)
		# testing several algorithms at the moment
	end

	##
	# run prediction on k lines from the test list and returns a MovieTest object
	# that is a list of arrays that contain (user, mov_id, rating, and prediction).
	def run_test(k = @test_list.length)
		counter = 0
		results = []
		@test_list.each do |user, mov_id, rate|
			if counter < k
				results.push([user, mov_id, rate, predict(user, mov_id)])
			end
			counter += 1
		end
		return MovieTest(results)
	end

end

puts "Running Test for PA2"
test = MovieData.new("u1.base", "u1.test")
#puts test.viewers(1)
#puts test.movies(1)
puts test.user_list[1]
puts test.rating(1, 58)
