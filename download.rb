require 'net/ftp'
require 'rubygems/package'
require 'zlib'

FTP_SITE = "ftp.fu-berlin.de"
FTP_DIR = "/pub/misc/movies/database"
DLD_DIR = "data"

def download_files
	ftp = Net::FTP::new(FTP_SITE)	
	ftp.passive = true
	ftp.login("ftp", "guest")
		
	
	ftp.chdir(FTP_DIR)
	fileList = ftp.list('*.gz')	
	fileList.each do |file|
		filename = file.split.last
		puts "Downloading " + filename		

		filesize = ftp.size(filename)
		transferred = 0
		perc_orig = 0
		filesizemb = filesize/1048576
		puts "File size: #{filesizemb} MB"
		ftp.getbinaryfile(filename, "#{DLD_DIR}/#{filename}", 1024) { |data|
		transferred += data.size
		perc_upd = ((transferred).to_f/filesize.to_f)*100
		if perc_orig < perc_upd -1
			print "#{perc_upd.round}% complete \r"
			$stdout.flush
			perc_orig = perc_upd
		end		
		}
		$stdout.flush
		if perc_orig >= 99
			puts "100% complete"
		end
		
	end
	ftp.close
end

def extract_files
	Dir.glob('data/*.gz') do |gz_file|
		Zlib::GzipReader.open(gz_file) do | input_stream |
			puts gz_file
			File.open(gz_file.chomp('.gz'), "w") do |output_stream|
				IO.copy_stream(input_stream, output_stream)
			end
		end	
	end	
end