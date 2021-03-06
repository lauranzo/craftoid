class TwitterCraft < WebCraft
  field :tweet_stream_id

  field :is_protected
  field :twitter_account_created_at

  field :followers_count
  field :friends_count
  field :listed_count
  field :favourites_count
  field :utc_offset
  field :time_zone
  field :geo_enabled
  field :verified
  field :statuses_count
  field :lang
  field :profile_background_color
  field :profile_background_image_url
  field :profile_background_image_url_https
  field :profile_background_tile
  field :profile_image_url
  field :profile_image_url_bigger
  field :profile_image_url_https
  field :profile_link_color
  field :profile_sidebar_border_color
  field :profile_sidebar_fill_color
  field :profile_text_color
  field :profile_use_background_image
  field :default_profile
  field :default_profile_image

  embedded_in :craft, inverse_of: :twitter

  alias_attribute :twitter_id, :web_craft_id
  alias_attribute :screen_name, :username
  alias_attribute :url, :website                # twitter specifies website as url
  alias_attribute :tweet_count, :statuses_count # for convenienc
  alias_method :protected?, :is_protected

  def self.provider_key
    '@'
  end

end


# tweets in timeline:
# id
# text
# source
# truncated
# in_reply_to_status_id
# in_reply_to_status_id_str
# in_reply_to_user_id
# in_reply_to_user_id_str
# in_reply_to_screen_name
# geo
# coordinates
# place
# contributors
# retweet_count
# favorited
# retweeted
# possibly_sensitive
