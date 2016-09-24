require "rubygems"
require "arrayfields"
require "sqlite3"
require "set"

DB_CSV_NAME = "im_db.csv"


def db_to_csv(data)
	db_com = "SELECT Movies.* 
	FROM Movies
	ORDER BY title"
	
	db_com_count = "SELECT COUNT(*) FROM Movies;"
	tot_count  = data.execute(db_com_count)	
	
	
	File.open("im_db.csv", "w") do |out|
		out << [
			'title', 'year', 'length', 'budget', 
			'rating', 'votes', (1..10).map{|i| "r" + i.to_s}, 
			'mpaa', genres_nm , 'is_series'
		].flatten.join(",") + "\n"
		data.execute(db_com) do |row| 
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
	
	tot_count = IO.readlines( DB_CSV_NAME ).size  - 1
	puts "Total csv entries: #{tot_count} "
	
end