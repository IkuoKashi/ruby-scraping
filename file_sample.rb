file = File.open('scrape.rb', 'r')
puts file.read
file.close

file = File.open('hello.txt', 'w')
file.write('Hello World.')
file.close