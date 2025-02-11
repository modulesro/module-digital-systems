require 'find'
require 'digest'
require 'fileutils'
require 'set'

# returns initial hashmap where key is MD5 hash and value is array of file paths with same MD5
# all files for given root directory (including subdirectories) and for given file mask (including symbolic links and hidden files) are processed
def create_file_hash_map(root_path, file_mask)
  initial_file_hash_map = {}
  Find.find(root_path) do |file|
    if File.file?(file) && File.fnmatch(file_mask, File.basename(file))
      process_file(file, initial_file_hash_map)
    end
  end
  initial_file_hash_map
end

# calculates MD5 hash and adds concrete file path to hash map
def process_file(file, initial_file_hash_map)
  real_file = file
  if File.symlink?(file)
    real_file = File.readlink(file);
  end
  file_hash = Digest::MD5.file(real_file).hexdigest
  if initial_file_hash_map.include?(file_hash)
    initial_file_hash_map[file_hash] << real_file
  else
    initial_file_hash_map[file_hash] = [real_file]
  end
end

# looks for duplicated files, every value in filtered_file_hash_map contains more than one file
def find_duplicate_files(filtered_file_hash_map)
  duplicates_hash_map = {}
  for entry in filtered_file_hash_map
    process_entry(entry, duplicates_hash_map)
  end
  duplicates_hash_map
end

# compare all files with same MD5 hash and if there are duplicate files adds them to new map with MD5 hash as key
# files are duplications if they have same MD5, they have same size and they have same content
# for optimization comparison for content happens only if files have same size
def process_entry(entry, duplicates_hash_map)
  key = entry[0]
  value = entry[1]
  file_set = Set.new
  for i in 0..value.length - 1
    for j in (i + 1)..value.length - 1
      first_file = value[i]
      second_file = value[j]
      if File.size(first_file) == File.size(second_file) && FileUtils.identical?(first_file, second_file)
        file_set.add(first_file)
        file_set.add(second_file)
      end
    end
  end
  if file_set.length > 0
    duplicates_hash_map[key] = file_set.to_a
  end
end

# prints grouped duplicates with hash and file names. if no duplicates found prints message about that
def print_duplicates(duplicates_hash_map)
  if duplicates_hash_map.empty?
    puts "No duplicates found."
  else
    puts "Grouped Duplicates:"
    puts
    duplicates_hash_map.each do |hash, files|
      puts "hash: #{hash}"
      puts "files:"
      files.each { |file| puts "  #{file}" }
      puts
    end
  end
end

# first program input argument is mandatory and must be existing root directory path (e.g. C:/)
input_root_path = ARGV[0]
# second input program argument is not mandatory and must be valid file mask (e.g. "*.txt"). if not passed, default "*" for any file used
input_file_mask = ARGV[1] || "*"
initial_file_hash_map = create_file_hash_map(input_root_path, input_file_mask)
# process only entries where duplicate files could occur => if only one file belongs to concrete hash it can be ignored
filtered_file_hash_map = initial_file_hash_map.select { |key, value| value.length > 1 }
duplicates_hash_map = find_duplicate_files(filtered_file_hash_map)
print_duplicates(duplicates_hash_map)

