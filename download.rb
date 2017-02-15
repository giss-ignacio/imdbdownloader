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
		filesizemb = filesize/1048576		
		puts "File size: #{filesizemb} MB"
		progressbar = ProgressBar.create
		progressbar.total = filesize
		
		ftp.getbinaryfile(filename, "#{DLD_DIR}/#{filename}", 1024) { |data|
		progressbar.progress += data.size		
		}		
	end
	ftp.close
end

def extract_files
	Dir.glob("#{DLD_DIR}/*.gz") do |gz_file|
		Zlib::GzipReader.open(gz_file) do | input_stream |
			puts "Extracting #{gz_file} "
			File.open(gz_file.chomp('.gz'), "w") do |output_stream|
				IO.copy_stream(input_stream, output_stream)
			end
		end	
	end	
end

def download_and_extract
	download_files
	extract_files
end