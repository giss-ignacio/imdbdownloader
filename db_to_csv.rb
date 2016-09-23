require "rubygems"
require "arrayfields"
require "sqlite3"
require "set"





def db_to_csv(data)
	db_com = "SELECT Movies.* 
	FROM Movies
	ORDER BY title"
	
	db_com_count = "SELECT COUNT(*) FROM Movies;"
	tot_count  = db.execute(db_com_count)
	
	perc_step = 0
	perc_orig = 0
	perc_upd = 100.0/tot_count
	
	File.open("movies.csv", "w") do |out|
		out << [
			'title', 'year', 'length', 'budget', 
			'rating', 'votes', (1..10).map{|i| "r" + i.to_s}, 
			'mpaa', GENRES_NM , 'is_series'
		].flatten.join(",") + "\n"
		data.execute(db_com) do |row| 
			perc_step += 1
			perc_upd = perc_step * 100.0 / tot_count
			if perc_orig < perc_upd -1
				print "#{perc_upd.round}% complete \r"
				$stdout.flush
				perc_orig = perc_upd
			end					

			out << [
				row[1], 
				row[2], 
				row[4], 
				row[3], 
				row[5], row[6], ratings_numeric(row[7]), 
				row[8], set_genres(row[0], data), row[9]
			].flatten.join(",") + "\n" rescue nil
		end
	end
	
	
end