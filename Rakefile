require 'tempfile'


file 'bm.min.js' => 'bookmarklet.js' do |t|
  begin
    # make a tmpfile
    file = Tempfile.new('bm.min', Dir.pwd)

    # write the JS to it
    sh 'uglifyjs', '--output', file.path, t.prerequisites.first

    # read in the minfied js
    contents = file.read

    # write out the wrapped file
    File.open(t.name, "w") do |f|
      f.puts "javascript:#{contents}"
    end

  ensure
    file.close
    file.unlink
  end
end

desc "Build the minified bookmarklet"
task :bookmarklet => 'bm.min.js'

task :default => :bookmarklet
