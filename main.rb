require 'rubygems'
require 'sqlite3'

def regex_form(category)
	reg_form
	puts case category
	when "movies"
		reg_form = /^(.+) \s+ \([0-9]+\) \s? (\{.+\})? (\(.+\))? \s+ ([0-9]+(-[0-9\?]+)?)$/ix
	when "mpaa_ratings"
	when "ratings"
	when "genres"
	
	end


end

def add_all
	puts "Processing movies database"
	add_movies	
	
	add_times
	
	add_budgets
	
	add_mpaa_ratings
	
	add_ratings
	
	add_genres
end

if __FILE__ == $0
	import_all
	
	puts "Movies added:"
	puts Movie.count()
	
end

#puts Movie.count( "budget > 0")
#puts Movie.count( "length > 0")
#puts Movie.count( "budget > 0 and length > 0")
#puts Movie.count( "imdb_votes > 0 and length > 0")
#puts Movie.count( "budget > 0 and length > 0 and imdb_votes > 0")