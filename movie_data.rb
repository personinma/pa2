# Author: Steven Hu

class MovieData

	def initialize
		@master_list = Array.new
		@popular_list = Hash.new("Movie Doesn't Exist")
	end

	# load u.data into a master list (master_list) and
	# prefetch a list it's movies and their popularity
	def load_data
		File.open("u.data", "r").each_line do |line|
			line = line.split
			@master_list.push([line[0].to_i,line[1].to_i,line[2].to_i])
		end
		load_popularity_list # preload @popular_list
		"Data Loaded" # just so that @popular_list isn't returned automatically
	end

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
		# formula puts more weight on the number of people who have
		# seen the movie vs the ratings of the movie
		((count * 0.7) + (rating * 0.3)).round(3)
	end

	# will load the popularity factors of all the movies. 
	# method is used in load_data to prefetch @popular_list
	def load_popularity_list
		@master_list.each do |user, mov_id, rate|
			if @popular_list[mov_id] == "Movie Doesn't Exist"
				@popular_list[mov_id] = popularity_helper(mov_id)
				end
		end
	end

	# check the popularity factor of a given movie id
	def popularity(movie_id)
		@popular_list[movie_id]
	end
	
	# populates list of movies from most popular to least
	def popularity_list
		@popular_list.sort_by {|_,val| -val}
	end
	
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
	
	# helper method that takes in two hashes of movies
	# and ratings from two users. output is a similarity factor
	# that is calculated by the number of movies they have
	# watched similarly and additional score to those movies
	# that are rated within +/- 1.
	def similar_movies(ul1, ul2)
		# intersect the keys of ul1, ul2 to find common movies
		common = ul1.keys & ul2.keys
		similar_ratings = 0
		common.each do |com|
			if (((ul1[com] + ul2[com]) / 2) - ul1[com]).abs <= 0.5
				similar_ratings += 1
			end
		end
		# formula takes into account of number of similar movies watched
		# and +1 on ratings which are close to each other (+/- 1)
		return common.length + similar_ratings
	end

	# returns a list of users sorted by popularity factor against user u
	def most_similar(u)
		similar_list = Hash.new(0)
		@master_list.each do |user, mov_id, rate|
			# if 'user' hasn't had smilarity factor calculated yet
			# and is not user u  
			if similar_list[user] == 0 and user != u
				similar_list[user] = similarity(u, user)
				end
		end
		similar_list.sort_by {|_, val| -val}
	end
end

puts "Running Test for PA1"
test = MovieData.new
test.load_data
puts "Top 10 Most Popular Movies (first ten elements from popularity_list): "
movies = test.popularity_list
movies.first(10).each do |a,b|
	puts "Movie: #{a}, Popularity Factor: #{b}" end
puts "10 Worse Movies (last ten elements from popularity_list): "
movies.last(10).each do |a,b|
	puts "Movie: #{a}, Popularity Factor: #{b}" end
puts "10 Most Similar Users to User 1 (first ten elements from most_similar(1)): "
similar = test.most_similar(1)
similar.first(10).each do |a,b|
	puts "User: #{a}, Similarity Factor: #{b}" end
puts "10 Least Similar Users to User 1 (last ten elements from most_similar(1)): "
similar.last(10).each do |a,b|
	puts "User: #{a}, Similarity Factor: #{b}" end