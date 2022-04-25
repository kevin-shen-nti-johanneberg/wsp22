require 'sinatra'
require 'slim'
require 'sqlite3'

enable :sessions

score = 0
db = SQLite3::Database.new("db/quiz.db")
db.results_as_hash = true

chosen_question_id = db.execute("SELECT question_id FROM question ORDER BY RANDOM() LIMIT 1").first["question_id"]
tmp_question = db.execute("SELECT player_question FROM question WHERE question_id = ?",chosen_question_id).first["player_question"]
tmp_right = db.execute("SELECT right FROM question WHERE question_id = ?",chosen_question_id).first["right"]
tmp_wrong = db.execute("SELECT wrong FROM question WHERE question_id = ?",chosen_question_id).first["wrong"]

array_of_options = [tmp_right,tmp_wrong]
option1, option2 = array_of_options.sample(2)

post('/') do
    locked_in_answer = params[:quiz_options]
    if db.execute("SELECT right FROM question WHERE question_id = ?",chosen_question_id).first["right"] == locked_in_answer
        score += 1
        chosen_question_id = db.execute("SELECT question_id FROM question ORDER BY RANDOM() LIMIT 1").first["question_id"]
        tmp_question = db.execute("SELECT player_question FROM question WHERE question_id = ?",chosen_question_id).first["player_question"]
        tmp_right = db.execute("SELECT right FROM question WHERE question_id = ?",chosen_question_id).first["right"]
        tmp_wrong = db.execute("SELECT wrong FROM question WHERE question_id = ?",chosen_question_id).first["wrong"]

        array_of_options = [tmp_right,tmp_wrong]
        option1, option2 = array_of_options.sample(2)
    else
        score = 0
        chosen_question_id = db.execute("SELECT question_id FROM question ORDER BY RANDOM() LIMIT 1").first["question_id"]
        tmp_question = db.execute("SELECT player_question FROM question WHERE question_id = ?",chosen_question_id).first["player_question"]
        tmp_right = db.execute("SELECT right FROM question WHERE question_id = ?",chosen_question_id).first["right"]
        tmp_wrong = db.execute("SELECT wrong FROM question WHERE question_id = ?",chosen_question_id).first["wrong"]

        array_of_options = [tmp_right,tmp_wrong]
        option1, option2 = array_of_options.sample(2)
    end

    redirect('/')
end

post('/login') do
    name = params[:player_name]    
    pass = params[:password]

    db = SQLite3::Database.new("db/quiz.db")
    db.results_as_hash = true
    id =  db.execute("SELECT player_id FROM player WHERE player_name = ?",name).first
    user_list = db.execute("SELECT password FROM player WHERE player_name = ?",name).first

    if user_list == nil
        redirect('/login')
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
    genre = params[:genre]

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
    slim(:index,locals:{index_id:chosen_question_id,index_q:tmp_question,index_1:option1,index_2:option2,highscore:score})
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




