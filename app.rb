require 'sinatra'
require 'slim'
require 'sqlite3'

enable :sessions

post('') do
    redirect('/index')
end

post('/login') do
    redirect('/login')
end

post('/register') do
    redirect('/register')
end

post('/profile') do
    redirect('/profile')
end

get('/') do
    slim(:index)
end

get('/login') do
    slim(:login)
end

get('/register') do
    slim(:register)
end

get('/profile') do
    slim(:profile)
end




