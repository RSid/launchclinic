require 'sinatra'
require 'pg'


configure :production do

  set :db_connection_info, {
    host: ENV['DB_HOST'],
    dbname: ENV['DB_NAME'],
    user: ENV['USER'],
    password: ENV['PASSWORD']
  }

end

configure :development do
  set :db_connection_info, {dbname: 'clinictopics'}

end

def db_connection
  begin
    connection = PG.connect(settings.db_connection_info)

    yield(connection)

  ensure
    connection.close
  end
end

def display_topics
  db_connection do |conn|
    results=conn.exec('SELECT * FROM clinictopics ORDER BY votes DESC')
    results.values
  end

end

def submit_topics(input)
  db_connection do |conn|
    results=conn.exec("INSERT INTO clinictopics (topic,time_proposed,votes,status) VALUES('#{input}',now(),0,'Submitted')")
  end
end

def increment_topic_votes(input)
  db_connection do |conn|
    results=conn.exec("UPDATE clinictopics SET votes=votes+1 WHERE topic='#{input}'")
  end
end

def delete_topics(input)
  db_connection do |conn|
    results=conn.exec("DELETE FROM clinictopics WHERE topic='#{input}'")
  end
end

def update_status(input)
  db_connection do |conn|
    results=conn.exec("UPDATE clinictopics SET status='Scheduled' WHERE topic='#{input}'")
  end
end


get '/' do
  @topics=display_topics

  erb :index
end

get '/staff' do
  @topics=display_topics
  erb :staff
end

post '/' do
  @input=params["subject"]
  submit_topics(@input)

  redirect '/'

end

post '/vote' do
  @vote=params["vote"]
  increment_topic_votes(@vote)

  redirect '/'
end


post '/delete' do
  @delete=params["delete"]
  delete_topics(@delete)

  redirect '/'
end

post '/update' do
  @update=params["update"]
  update_status(@update)

  redirect '/'
end
