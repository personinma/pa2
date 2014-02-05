# Author: Steven Hu

require_relative 'movie_test'

class MovieData

	def initialize(file, test = nil)
		@master_list = Array.new # will be used as the training list
		@test_list = Array.new # test set
		@movie_list = Hash.new()
		@user_list = Hash.new()
		load_data(file, test)
	end

	def load_data(file, test)
		if test.nil? == true
			load_data_helper(file, 100000, "training")
		else
			load_data_helper(file, 80000, "training")
			load_data_helper(test, 20000, "test")
		end		
	end

	def load_data_helper(path, k, type)
		counter = 0
		File.open(path, "r").each_line do |line|
			if counter < k
				line = line.split
				if type == "training"
					@master_list.push([line[0].to_i,line[1].to_i,line[2].to_i])
					# kudos to Amin for helping out on the following two lines!
					@user_list[line[0].to_i] = @user_list[line[0].to_i].nil? ? [[line[1].to_i,line[2].to_i]] : @user_list[line[0].to_i].push([line[1].to_i,line[2].to_i])
					@movie_list[line[1].to_i] = @movie_list[line[1].to_i].nil? ? [line[0].to_i] : @movie_list[line[1].to_i].push(line[0].to_i)
				elsif type == "test"
					@test_list.push([line[0].to_i,line[1].to_i,line[2].to_i])
				end
			end
			counter += 1
		end
		"Data Loaded"
	end
	
	##
	# presents a similarity factor between two users. 
	# note: made some modifications from PA1 for processing
	# time efficiency.
	def similarity(user1, user2)
		user_list1 = Hash.new(0)
		user_list2 = Hash.new(0)
		movies_u1 = @user_list[user1]
		#@master_list.each do |user, mov_id, rate|
		movies_u1.each do |mov_id, rate|
			if @movie_list[mov_id].include? user2
			#if user == user1
				user_list1[mov_id] = rate
			#elsif user == user2
				user_list2[mov_id] = rating(user2, mov_id)
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
		sum = 0.0
		counter = 0
		sim_list = most_similar(u)
		sim_list.first(10).each do |a, b|
			sim_rate = rating(a, m)
			if sim_rate > 0
				sum += sim_rate
				counter += 1
			end
		end
		# if there is no movie match in similar users
		if counter == 0 
			return predict_helper(m, sum, counter)
		end
		return sum / counter
	end

	##
	# prediction helper method: when predicting with similar users fail
	# prediction will be average rating of movies across all users in 
	# training set
	def predict_helper(m, sum, counter)
		@movie_list[m].each do |x|
			sum += rating(x, m)
			counter += 1
		end
		return sum / counter
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
		return MovieTest.new(results)
	end
end