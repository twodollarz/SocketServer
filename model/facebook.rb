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
    album = @api.put_connections('me', 'albums', {name: ALBUM_TITLE, privacy: privacy})
    album_obj = @api.get_object(album["id"])
    @pipe_dbh.set_album(@pipe[:pipe_id].to_s, album_obj["id"], album_obj["link"])
    return album_obj
  end

  def put_picture(path)
    ap @pipe
    pipe = @pipe_dbh.find_with_uids(@pipe[:uids])
    picture = @api.put_picture(path, {}, pipe[:album_id])
    picture_obj = @api.get_object(picture["id"])
    return picture_obj
  end

end
