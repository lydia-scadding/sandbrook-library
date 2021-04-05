# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
require 'csv'
require 'json'
require 'open-uri'

puts 'Cleaning database...'

Book.destroy_all
Author.destroy_all

puts 'Database is clean.'

puts 'Building library...'

csv_options = { col_sep: ',', quote_char: '"', headers: :first_row }

def build_author(row)
  author = Author.new(name: row['Author l-f'])
  author = Author.find_by(name: row['Author l-f']) unless author.save
  author
end

def find_isbn(row)
  row['ISBN13'] ? row['ISBN13'].gsub(/\D/, '') : nil
end

def find_img_url(isbn)
  url = "https://www.googleapis.com/books/v1/volumes?q=isbn:#{isbn}&key=#{ENV["GOOGLE_API_KEY"]}"
  data = JSON.parse(URI.open(url).read)['items']
  if data && data.first["volumeInfo"]["imageLinks"]
    data.first["volumeInfo"]["imageLinks"]["thumbnail"]
  else
    nil
  end
end

CSV.foreach('db/books.csv', csv_options) do |row|
  author = build_author(row)
  isbn = find_isbn(row)
  img_url = find_img_url(isbn)
  book = Book.new(title: row['Title'],
                  year: row['Original Publication Year'].to_i,
                  isbn: isbn,
                  pages: row['Number of Pages'].to_i,
                  img_url: img_url,
                  author: author)
  if book.save!
    puts "Saved #{book.title} by #{author.name}"
  end
end

puts 'Done!'
