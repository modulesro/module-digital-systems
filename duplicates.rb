require 'find'
require 'digest'
require 'fileutils'
require 'set'

def create_file_hash_map(root_path, file_mask)
  initial_file_hash_map = {}
  Find.find(root_path) do |file|
    if File.file?(file) && File.fnmatch(file_mask, File.basename(file))
      process_file(file, initial_file_hash_map)
    end
  end
  initial_file_hash_map
end

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
  duplicates_hash_map[key] = file_set.to_a
end

def find_duplicate_files(filtered_file_hash_map)
  duplicates_hash_map = {}
  for entry in filtered_file_hash_map
    process_entry(entry, duplicates_hash_map)
  end
  duplicates_hash_map
end

initial_file_hash_map = create_file_hash_map(ARGV[0], ARGV[1])
filtered_file_hash_map = initial_file_hash_map.select { |key, value| value.length > 1 }
duplicates_hash_map = find_duplicate_files(filtered_file_hash_map)

if duplicates_hash_map.empty?
  puts "No duplicates found."
else
  puts "Grouped Duplicates:"
  duplicates_hash_map.each do |hash, files|
    puts "Hash: #{hash}"
    puts "Files:"
    files.each { |file| puts "  #{file}" }
  end
end