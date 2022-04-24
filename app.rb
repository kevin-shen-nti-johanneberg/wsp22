require 'sinatra'
require 'slim'
require 'sqlite3'

enable :sessions

post('') do
    db = SQLite3::Database.new("db/quiz.db")
    db.results_as_hash = true

    correct = params[:player_name]    
    incorrect = params[:password]

    tmp_question = db.execute("SELECT * FROM question")
    
    random.rand(db.size - 1)
    quiz_quest = db.execute("SELECT * FROM question WHERE question_id LIKE #{tmp_question}").first["player_question"]
    quiz_right = db.execute("SELECT * FROM question WHERE question_id LIKE #{tmp_question}").first["right"]
    quiz_wrong = db.execute("SELECT * FROM question WHERE question_id LIKE #{tmp_question}").first["wrong"]

    session[:current_question] = quiz_quest
    session[:current_right] = quiz_right
    session[:current_wrong] = quiz_wrong


    #if quiz ==
    #tmp_question = random.rand(db.size - 1)


    redirect('/index')
end

post('/login') do
    name = params[:player_name]    
    pass = params[:password]

    db = SQLite3::Database.new("db/quiz.db")
    db.results_as_hash = true
    id =  db.execute("SELECT player_id FROM player WHERE player_name =?",name).first
    user_list = db.execute("SELECT password FROM player WHERE player_name = ?",name).first

    if user_list == nil
        redirect('login')
    end

    if db.execute("SELECT password FROM player WHERE player_name = ?",name).first["password"] == pass
        session[:current_user] = id
        redirect('/profile') 
    end

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

    quest = params[:question]
    answr = params[:right]    
    answw = params[:wrong] 

    db = SQLite3::Database.new("db/quiz.db")
    db.results_as_hash = true

    if db.execute("SELECT * FROM question WHERE player_id = ?",session[:current_user]["player_id"]).first == nil

        db.execute("INSERT INTO question (player_id,right,wrong,player_question) VALUES (?,?,?,?)",session[:current_user]["player_id"],answr,answw,quest)

    elsif db.execute("SELECT * FROM question WHERE player_id = ?",session[:current_user]["player_id"]).first != nil 
        
        db.execute("UPDATE question SET right = ?, wrong = ?, player_question = ? WHERE player_id = ?",answr,answw,quest,session[:current_user]["player_id"])

    end

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




