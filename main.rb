require 'rubygems'
require 'sqlite3'

MOVIES = "movies"
RUNNING_TIMES = "running_times"
BUDGETING = "budgeting"
TITLE = "title"
HYPHENS = "-" * 79
MPAA_RAT = "mpaa_ratings"
RATINGS = "ratings"
GENRES = "genres"


def regex_form(category)
	reg_form
	puts case category
	when MOVIES
		reg_form = /^(.+) \s+ \([0-9]+\) \s? (\{.+\})? (\(.+\))? \s+ ([0-9]+(-[0-9\?]+)?)$/ix
	when TITLE
		reg_form = /MV:\s+(.+)? \s \(([0-9]+)\)/ix
	when RUNNING_TIMES
		reg_form = /^(.+) \s+ \(([0-9]+)\) \s+ (?:[a-z]+:)?([0-9]+)/ix
	when BUDGETING
		reg_form = /BT:\s+USD\s+([0-9,.]+)/ix
	when MPAA_RAT
		reg_form = /RE: Rated (.*?) /i
	when RATINGS
		reg_form = /([0-9.\*]+) \s+ ([0-9]+) \s+ ([0-9.]+) \s+ (.+)? \s+ \(([0-9]+)\)/ix
	when GENRES
		reg_form = /^(.+)? \s+ \(([0-9]+)\) (?:\s*[({].*[})])*  \s+(.*?)$/ix	
	end
	
	return reg_form

end

def add_movies	
	movies_reg = regex_form(MOVIES)
		
	match_prev = ['', '', '', '', '']
	series = ""

	datacom = data.prepare("INSERT INTO Movies (title, year, is_series) VALUES (?, ?, ?);")
	i = 0
	data.transaction do
		data.execute "DELETE FROM Movies;"
	
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
		
end

def add_running_times(data)
	running_times_reg = regex_form(TIMES)	

	datacom = data.prepare("UPDATE Movies set length=? WHERE title=? AND year=?;")
	i = 0
  data.transaction do 
		File.new("data/running-times.list").each_line do |l|
			if match = running_times_reg.match(l)
				datacom.execute!(match[3].to_i, match[1].tr(',".',''), match[2].to_i)
			end
		end
  end
		
end


def add_budgeting	
	budgeting_reg = regex_form("budgeting")
	title_reg = regex_form("title")
	hyphens = "-" * 79
	
	datacom = $db.prepare("UPDATE Movies set budget=? WHERE title=? AND year=?;")
	$db.transaction do 
		File.new("data/business.list").each(hyphens) do |l|
			if match = title_reg.match(l.to_s) and bt = budgeting_reg.match(l.to_s)
				datacom.execute!(bt[1].gsub!(",","").to_i, match[1].tr(',".',''), match[2].to_i) 
			end
		end
	end
end

def add_mpaa_ratings_reasons
	hyphens = "-" * 79
	mpaa_reg = regex_form("mpaa_ratings_reasons")
	title_reg = regex_form("title")

	datacom = $db.prepare("UPDATE Movies set mpaa_rating=? WHERE title=? AND year=?;")
	i = 0
	$db.transaction do 
		File.new("data/mpaa-ratings-reasons.list").each(hyphens) do |l|
			if match = title_reg.match(l.to_s) and rt = mpaa_reg.match(l.to_s)
				datacom.execute!(rt[1], match[1].tr(',".',''), match[2].to_i)
			end
		end
	end
end

def add_all
	data = SQLite3::Database.new( "movies.sqlite3" )
	
	puts "Processing movies database"
	add_movies(data)
	
	add_running_times(data)
	
	add_budgeting(data)
	
	add_mpaa_ratings_reasons(data)
	
	add_ratings(data)
	
	add_genres(data)
end

if __FILE__ == $0
	add_all
	
	puts "Movies added:"
	puts Movie.count()
	
end

