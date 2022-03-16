require 'sinatra'
require 'slim'
require 'sqlite3'

enable :sessions

post('') do
    #Skapa koppling till databasen
    db = SQLite3::Database.new("db/quiz.db")
    #Få svar i strukturen
    db.results_as_hash = true
    #Hämta data, skicka data
    result = db.execute("SELECT * FROM users")
    slim(:users,locals:{key:result})
    redirect('/index')
end

post('/login') do
    name = params[:player_name]    
    pass = params[:password]

    db = SQLite3::Database.new("db/quiz.db")
    db.results_as_hash = true

    if db.execute("SELECT password FROM player WHERE player_name = ?",name).first["password"] == pass        
        redirect('/profile')
    else
        redirect('/login')
    end
    redirect('/login')
end

post('/register') do
    #Hämta data ifrån formulär
    name = params[:player_name]    
    pass = params[:password]

    #Lägg till data i databasen
    db = SQLite3::Database.new("db/quiz.db")
    db.execute("INSERT INTO player (player_name,password) VALUES (?,?)",name,pass)

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




