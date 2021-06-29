#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

#require 'pony'
def is_barber_exists? db, name
	return db.execute('select * from Barbers where Barbers = ?', [name]).length > 0 
end

def get_db
	db = SQLite3::Database.new './DataBase/BarberShop.db'
	db.results_as_hash = true
	return db
end
def seed_db db, barbers
	barbers.each do |b|
			if !is_barber_exists? db, b
				db.execute 'insert into barbers (Barbers) values (?)', [b]
			end
	end
end

configure do
	db = get_db
	db.execute 'create table if not exists
		users
		(id integer primary key autoincrement, Name, Phone, Datestamp, Barber, Color)'

	db.execute 'create table if not exists Barbers (Id integer primary key autoincrement, Barbers text)'
	seed_db db, ['Jessie', 'Fred', 'Gus', 'Jack', 'Sara Bell', 'Crazy Nastya']
end
before do
	db = get_db
	@mb = db.execute 'select *from Barbers'
end

get '/' do
	erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"			
end
get '/admin' do
	db = get_db
	# @mh = []
	# db.execute 'select *from users' do |h|
	# 	@mh << h
	# end
	@mh = db.execute 'select *from users'
	erb :admin
end

get '/about' do
	@error = 'Ошибка'
	erb :about
end
get '/visit' do
	db = get_db
	# $mb = []
	# db.execute 'select *from Barbers' do |h|
	# 	$mb << h
	# end

	erb :visit
end

post '/visit' do
	@clientname = params[:clientname]
	@phone = params[:phone]
	@visittime = params[:visittime]
	@choice = params[:choice]

	f = File.open './public/user.txt', 'a'
	f.write "Имя клиента: #{params[:clientname]}, телефон: #{params[:phone]}, время визита: #{params[:visittime]}, мастер: #{params[:choice]}, цвет: #{params[:color]}\n"
	f.close
#	Pony.mail(:to => 'and8511@ya.ru', :from => 'my heary', :subject => 'My first mail', :body => "Имя клиента: #{params[:clientname]}, фамилия: #{params[:clientfamily]}, время визита: #{params[:visittime]}, мастер: #{params[:choice]}, цвет: #{params[:color]}\n")
#		if params[:clientname] == ''
#			@error = 'Не введено имя'
#			erb :visit
#		else
#			erb "<h2>Спасибо! Мы будем Вас ждать!</h2>"
#	end
	hh = {:clientname => 'Введите имя',
		:clientfamily => 'Введите фамилию',
		:visittime => 'Укажите время визита'}
	# hh.each do |key, value|
	# 	if params[key] == ''
	# 		@error = value
	# 		return erb :visit
	# 	end
	# end
	@error = hh.select{|key,_| params[key] == ''}.values.join(", ")
	if @error != ''
		return erb :visit
	end
	db = get_db
	db.execute 'insert into users
		(name, Phone, Datestamp, Barber, Color)
		values (?,?,?,?,?)', [@clientname, @phone, @visittime, @choice, params[:color]]

erb "<h2>Спасибо! Мы будем Вас ждать!</h2>"
end
get '/contacts' do
	erb "Вы можете связаться с нами по следующим телефонам:"
end