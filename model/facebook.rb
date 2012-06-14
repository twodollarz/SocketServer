require 'koala'
require 'json'
require 'user'
require 'pipe'

class Facebook
  ALBUM_TITLE = 'steady album'

  def initialize(uid, to_uid)
    @pipe_dbh = Pipes::Model::Pipe.new
    @pipe = @pipe_dbh.find_with_uids(@pipe_dbh.concat_uid(uid, to_uid))
    @api = Koala::Facebook::API.new(@pipe[:facebook_token])
  end

  def create_album
    privacy = JSON.generate({value: 'CUSTOM', friends: 'SELF'})
    album_id = @api.put_connections('me', 'albums', {name: ALBUM_TITLE, privacy: privacy})
    album = @api.get_object(album_id["id"])
    @pipe_dbh.set_album(@pipe[:pipe_id].to_s, album["id"], album["link"])
    return album
  end

end
