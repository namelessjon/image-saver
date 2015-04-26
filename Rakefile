
file 'bm.min.js' => 'bookmarklet.js' do |t|
  sh 'uglifyjs', '--output', t.name, t.prerequisites.first
end

desc "Build the minified bookmarklet"
task :bookmarklet => 'bm.min.js'

task :default => :bookmarklet
