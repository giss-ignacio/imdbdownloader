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

def add_movies	
	movies_reg = regex_form("movies")
		
	match_prev = ['', '', '', '', '']
	series = ""

	datacom = data.prepare("INSERT INTO Movies (title, year, is_series) VALUES (?, ?, ?);")
	i = 0
	data.transaction do
		$data.execute "DELETE FROM Movies;"
	
		File.new("data/movies.list").each_line do |l|
			if match = movies_reg.match(l)			
				unless match[match.length - 1].nil?
				series = match[1]
				datacom.execute!(match[1].tr(',".',''), match[match.length - 2][0..3].to_i, 1)			
				else 
				if ((match[1] != match_prev[1]) || (match[match.length - 2] != match_prev[match_prev.length - 2])) && (match[1] != series)
					datacom.execute!(match[1].tr(',".',''), match[match.length - 2][0..3].to_i, 0)
				end
				end
			end
		end
	end
	
	puts
end

def add_all
	data = SQLite3::Database.new( "movies.sqlite3" )
	
	puts "Processing movies database"
	add_movies(data)
	
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

