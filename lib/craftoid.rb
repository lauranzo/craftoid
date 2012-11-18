# load class extentions
require 'extentions/urlify'
require 'extentions/symbolize'

# load utils
require 'uri'
require 'utils/redis_auto_expire'
require 'utils/materialize_util'

# load configs
require 'config/redis_cfg'
require 'config/mongoid_cfg'
require 'config/geocoder_cfg' # depends on redis

# load models
require "mixins/geo_aliases"
require "models/craft"
require "models/web_craft"
require "models/web_craft/yelp_craft"
require "models/web_craft/twitter_craft"
require "models/web_craft/facebook_craft"
require "models/web_craft/website_craft"

# Load gem
require "craftoid/version"

module Craftoid
end
