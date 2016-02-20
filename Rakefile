task default: %w(test)

task :test do
  puts '**************Starting rspec**************'
  sh 'rspec -f d -c'
  puts '**************Starting rubocop**************'
  sh 'rubocop'
  puts '**************Starting foodcritic**************'
  sh 'foodcritic . -P'
  puts '**************Testing complete**************'
end
