require './server'

describe ChatServer do
  before do
    puts "before"
    @chat_server = ChatServer.new( 5001 )
  end

  it "generate unique uid " do
    @chat_server.generate_uid.should == 1 
    @chat_server.generate_uid.should == 2
  end

  after do
    puts "after"
    #@chat_server.stop()
    @chat_server = nil
  end
end
