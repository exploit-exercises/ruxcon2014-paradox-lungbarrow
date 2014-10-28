require 'sinatra'
require 'sinatra/synchrony'

require 'haml'
require 'sqlite3'
require 'securerandom'
require 'digest/md5'
require 'thin'
require 'fileutils'


set :session_secret, SecureRandom.urlsafe_base64 + SecureRandom.urlsafe_base64
enable :sessions

set :public_folder, File.dirname(__FILE__) + '/public'

get '/' do
  session.delete(:userid)

  html = haml(:index, :locals => { :flash => session[:flash], :heromsg => 'Please log in' })
  session.delete(:flash)
  html
end

def setup_database(&blk)
  identifier = SecureRandom.urlsafe_base64
  path = "/tmp/#{identifier}.db"

  FileUtils.cp("database.db", path)

  begin
    yield path
  ensure
    FileUtils.rm(path)
  end
end

post '/login' do
  setup_database do |path|

    db = SQLite3::Database.new(path)
    query = "SELECT id FROM accounts WHERE username = '#{params[:username]}' and password = '#{Digest::MD5.hexdigest(params[:password])}' LIMIT 1"

    row = db.execute(query)

    if row.nil? or row.empty?
      session[:flash] = "Failed to log in"
      redirect to('/')
    else
      session[:userid] = row[0][0]
      redirect to('/secret')
    end
  end
end

get '/secret' do
  if session[:userid].nil? 
    session[:flash] = "You are not logged in"
    redirect to('/')
    return
  end
  
  html = haml(:secret, :locals => { :flash => session[:flash], :heromsg => 'Congratulations' })
  session.delete(:flash)
  html
end
