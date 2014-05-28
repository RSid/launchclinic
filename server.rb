require 'sinatra'
require 'uri'
require 'pry'
require 'shotgun'
require 'pg'
require 'date'

def db_connection
  begin
    connection = PG.connect(dbname: 'clinictopics')

    yield(connection)

  ensure
    connection.close
  end
end

def display_topics
  db_connection do |conn|
    results=conn.exec('SELECT * FROM clinictopics')
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

def sort_by_vote(clinictopics)
  clinictopics.sort_by {|first,second| first[3]<=>second[3]}.reverse
end


get '/' do
  @topics=sort_by_vote(display_topics)

  erb :index
end

get '/staff' do
  @topics=sort_by_vote(display_topics)
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
