#! /usr/bin/env ruby -w
# encoding: UTF-8

head, treshold = ARGV
head ||= 'HEAD'
Megabyte = 1000 ** 2
treshold = (treshold || 0.1).to_f * Megabyte

big_files = {}

IO.popen("git rev-list #{head}", 'r') do |rev_list|
    rev_list.each_line do |commit|
          commit.chomp!
          trees =  `git ls-tree -zrl #{commit}`.force_encoding('UTF-8')
            if !trees.valid_encoding?
              trees = trees.encode('utf-8', 'binary', :invalid => :replace, :undef => :replace)
            end
              for object in trees.split("\0")
                bits, type, sha, size, path = object.split(/\s+/, 5)
                size = size.to_i
                big_files[sha] = [path, size, commit] if size >= treshold
              end
          end
end

big_files.each do |sha, (path, size, commit)|
    where = `git show -s #{commit} --format='%h: %cr'`.chomp
      puts "%4.1fM\t%s\t(%s)" % [size.to_f / Megabyte, path, where]
end
