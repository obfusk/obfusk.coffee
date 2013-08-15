desc 'Run specs'
task :spec do
  sh 'jasmine-node --coffee spec/'
end

desc 'Generate docs'
task :docs do
  sh 'docco -o doc src/*.coffee'
end

desc 'Cleanup'
task :clean do
  sh 'rm -rf doc/ node_modules/ src/*.js'
end
