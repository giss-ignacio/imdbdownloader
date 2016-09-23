require 'rubygems'
require "highline/import"
require_relative 'download'
require_relative 'db_handle'
require_relative 'db_to_csv'

MOVIES = "movies"
RUNNING_TIMES = "running_times"
BUDGETING = "budgeting"
TITLE = "title"
HYPHENS = "-" * 79
MPAA_RAT = "mpaa_ratings_reasons"
RATINGS = "ratings"
GENRES = "genres"




def regex_form(category)
	reg_form = /(.*?)/i
	case category
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

def add_movies(data)	
	movies_reg = regex_form(MOVIES)
		
	match_prev = ['', '', '', '', '']
	series = ""

	datacom = data.prepare("INSERT INTO Movies (title, year, is_series) VALUES (?, ?, ?);")
	i = 0
	data.transaction do
		data.execute "DELETE FROM Movies;"
	
		File.read("#{DLD_DIR}/#{MOVIES}.list").each_line do |l|
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
	running_times_reg = regex_form(RUNNING_TIMES)	

	datacom = data.prepare("UPDATE Movies set running_times=? WHERE title=? AND year=?;")
	i = 0
  data.transaction do 
		File.read("#{DLD_DIR}/#{RUNNING_TIMES}.list").each_line do |l|
			if match = running_times_reg.match(l)
				datacom.execute!(match[3].to_i, match[1].tr(',".',''), match[2].to_i)
			end
		end
  end
		
end


def add_budgeting(data)
	budgeting_reg = regex_form(BUDGETING)
	title_reg = regex_form(TITLE)	
	
	datacom = data.prepare("UPDATE Movies set budgeting=? WHERE title=? AND year=?;")
	data.transaction do 
		File.read("#{DLD_DIR}/business.list").each(HYPHENS) do |l|
			if match = title_reg.match(l.to_s) and bt = budgeting_reg.match(l.to_s)
				datacom.execute!(bt[1].gsub!(",","").to_i, match[1].tr(',".',''), match[2].to_i) 
			end
		end
	end
end

def add_mpaa_ratings_reasons(data)	
	mpaa_reg = regex_form(MPAA_RAT)
	title_reg = regex_form(TITLE)

	datacom = data.prepare("UPDATE Movies set mpaa_ratings=? WHERE title=? AND year=?;")
	i = 0
	data.transaction do 
		File.read("#{DLD_DIR}/#{MPAA_RAT}.list").each(HYPHENS) do |l|
			if match = title_reg.match(l.to_s) and rt = mpaa_reg.match(l.to_s)
				datacom.execute!(rt[1], match[1].tr(',".',''), match[2].to_i)
			end
		end
	end
end

def add_genres(data)	
	genres_reg = regex_form(GENRES)	
	
	datacom = data.prepare("INSERT INTO Genres (genre, movie_id) VALUES (?, (SELECT id FROM Movies WHERE title=? AND year=?));")
	data.transaction do 
		data.execute "DELETE FROM Genres;"
		
		File.read("#{DLD_DIR}/#{GENRES}.list").each_line do |l|			
			if match = genres_reg.match(l)				
				datacom.execute!(match[3], match[1].tr(',".',''), match[2].to_i)
			end
		end
		puts
	end
end

def add_ratings(data)	
	ratings_reg = regex_form(RATINGS)

	datacom = data.prepare("UPDATE Movies set votes=?, ratings=?, rating_votes=? WHERE title=? AND year=?;")
	data.transaction
	
	File.read("#{DLD_DIR}/#{RATINGS}.list").each_line do |l|
		if match = ratings_reg.match(l)
			rating, votes, outof10, title, year = match[1], match[2], match[3], match[4], match[5]
			datacom.execute!(votes, outof10, rating, title.tr(',".',''), year)
		end
	end
	data.commit
	
end

def add_all
	data = create_db
	
	puts "Processing movies database"
	add_movies(data)
	
	add_running_times(data)
	
	add_budgeting(data)
	
	add_mpaa_ratings_reasons(data)
	
	add_ratings(data)
	
	add_genres(data)
end

def database_to_csv
	database = SQLite3::Database.new( DBNAME )
	db_to_csv(database)	
end

def do_everything
	download_and_extract
	add_all
	database_to_csv
end


def show_menu
	Gem.win_platform? ? (system "cls") : (system "clear")
	puts
	loop do
		choose do |menu|
			puts "ImdbDownloader \n\n"
			menu.prompt = "Select an option: "
			menu.choice(:'Do everything') { do_everything }
			menu.choice(:'Download files') { download_and_extract }
			menu.choice(:'Add all movies to database') { add_all }
			menu.choice(:'Export database to csv') { database_to_csv }
			menu.choice(:Quit, "Exit program.") { exit }
		end
	end
end


if __FILE__ == $0
	
	# Main Menu #
	show_menu	
		
end

