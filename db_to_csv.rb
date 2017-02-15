require "rubygems"
require "arrayfields"
require "sqlite3"
require "set"
require "ruby-progressbar"

DB_CSV_NAME = "im_db.csv"

$genres_nm = ["Action", "Adventure", "Animation", "Comedy", "Drama", "Documentary", "Horror", "Mystery", "Romance", "Short", "Thriller", "Sci-Fi"]
$maprat = {"." => 0, "0" => 4.5, "1" => 14.5, "2" => 24.5, "3" => 34.5, "4" => 44.5, "5" => 45.5, "6" => 64.5, "7" => 74.5, "8" => 84.5, "9" => 94.5, "*" => 100}


def ratings_numeric(ratings)
	ratings[0..ratings.length].to_s.split(//).map{|s| $maprat[s]}
end

def set_genres(id, data)	
	genres = data.execute("SELECT genre FROM Genres where movie_id = #{id};").flatten.to_set
	$genres_nm.map { |genre| (genres.include? genre) ? 1 : 0}
end



def db_to_csv(data)
	db_com = "SELECT Movies.* 
	FROM Movies
	ORDER BY title"
	
	db_com_count = "SELECT COUNT(*) FROM Movies;"
	tot_count  = data.execute(db_com_count)
	total_fl = tot_count.first.first	
	progressbar = ProgressBar.create
	progressbar.total = total_fl
	
	File.open("im_db.csv", "w") do |out|
		out << [
			'title', 'year', 'length', 'budget', 
			'rating', 'votes', (1..10).map{|i| "r" + i.to_s}, 
			'mpaa', $genres_nm , 'is_series'
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
			
			progressbar.increment
			
		end
	end
	
	tot_count = IO.readlines( DB_CSV_NAME ).size  - 1
	puts "Total csv entries: #{tot_count} "
	
end