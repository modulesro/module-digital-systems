# **Task description:**

Implement a script in Ruby language that will search the given directory and its subdirectories for duplicate files.

-	The script will be controlled from the command line
-	Input will be a root directory where to start search and a file mask
-	The script will collect all files in the given path, matching the file mask
-	For each file collected it will calculate an MD5 sum
-	The files with the same MD5 will be extracted to groups and compared byte-to-byte
-	Script will print out duplicates, starting with MD5 and list of files in each duplicate group.

There are no restrictions on the resources or tools used, except for the conditions specified above.

Try to provide clean and commented code that can be easily understood by other developers.
Associated documentation (for both user and developer perspective) is a viable plus.

# **Task solution:**


• ruby script finds all duplicate files (with same content) in given directory and all subdirectories

• symbolic links and hidden files are included

• duplicate file have same MD5 hash && have same file size && same content

• for optimal performance if two comparing files have same MD5 hash, first they are checked for same file size
and if this is true then subsequent comparing with API FileUtils.identical is used

• program expects two correct input arguments:

  1, first argument IS mandatory root path where search for files should start and must be directory e.g. "/c/work/modulesro"
  
2, second argument IS NOT mandatory and represents valid file mask e.g. "*.txt" . if not passed default all files is used  

• examples of call:

  ruby ./duplicates.rb /c/work/modulesro *.bin    => compare all txt files
  
  ruby ./duplicates.rb /c/work/modulesro          => compare all files

it has been tested on unix and win platforms including hidden files and symbolic links and also tested on files with same MD5 hash and 
same file size but with different content (MD5 collision => see examples first-md5-collision.bin and second-md5-collision.bin)