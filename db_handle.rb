require 'sqlite3'

DBNAME = "movies.sqlite"

def create_db
	File.delete(DBNAME) if File.exists?DBNAME

	db = SQLite3::Database.new( DBNAME )
	db.execute("CREATE TABLE Movies (
				id INTEGER PRIMARY KEY,
				title varchar(250),
				year integer,
				budget integer,
				length integer,
				imdb_rating float,
				imdb_votes integer,
				imdb_rating_votes varchar(10),
				mpaa_rating varchar(5),
				is_series numeric
				)")
				
				
	db.execute("CREATE TABLE Ratings (id INTEGER PRIMARY KEY, movie_id integer, score varchar(10), outof10 float, votes integer)")
	db.execute("CREATE TABLE Genres (id INTEGER PRIMARY KEY , movie_id integer, genre varchar(50))")

	db.execute("CREATE INDEX title on Movies (title)")
	db.execute("CREATE INDEX year on Movies (year)")
	db.execute("CREATE INDEX titleyear on Movies (title, year)")
	db.execute("CREATE INDEX id on Movies (id)")
	db.execute("CREATE INDEX rid on Ratings (id)")
	db.execute("CREATE INDEX rmid on Ratings (movie_id)")
	db.execute("CREATE INDEX gid on Genres (id)")
	db.execute("CREATE INDEX gmid on Genres (movie_id)")
	
	return db

end

