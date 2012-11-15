class WebCraft
  include Mongoid::Document
  include Mongoid::Timestamps
  include Geocoder::Model::Mongoid
  include GeoAliases

  field :web_craft_id
  field :href # url to this provider's account
  field :username

  field :name
  field :description
  field :website # url to craft's actual website

  field :location_hash
  field :address, default: nil
  field :coordinates, type: Array, default: [] # does geocoder gem auto index this?

  # field :id_tags, index: true # e.g. facebook_id, yelp_id, twitter_id etc. should be aliased to this field for a normalized id 
  # field :username_tags, index: true  # e.g. username, twitter_handle
  # field :href_tags, type: Array, default: []
  # field :search_tags, type: Array, default: []
  # index :web_craft_id
  # index :username
  # index :href_tags
  # index :search_tags
  # scope :yelp_crafts,     where(provider: :yelp)
  # scope :flickr_crafts,   where(provider: :flickr)
  # scope :webpage_crafts,  where(provider: :webpage)
  # scope :twitter_crafts,  where(provider: :twitter)
  # scope :facebook_crafts, where(provider: :facebook)
  # scope :you_tube_crafts, where(provider: :you_tube)
  # scope :google_plus_crafts, where(provider: :google_plus)

  geocoded_by :address
  reverse_geocoded_by :coordinates

  alias_method :user_name, :username
  alias_method :user_name=, :username=

  before_save :format_attributes
  before_save :geocode_this_location! # auto-fetch coordinates

  # convert classname to provider name: e.g. TwitterCraft -> :twitter
  def self.provider() name[0..-6].symbolize end
  def self.provider_key() name[0..-6].downcase end

  # get the service class for this craft: e.g. TwitterCraft -> TwitterService
  def self.web_craft_service_class() @@web_craft_service_class ||= Kernel.const_get("#{name[0..-6]}Service") end
  def web_craft_service_class() self.class.web_craft_service_class end

  def self.materialize(web_craft_hash)
    wc_id = web_craft_hash[:web_craft_id] || web_craft_hash['web_craft_id']
    return nil if wc_id.nil?

    # web_craft = find_or_initialize_by(web_craft_id: "#{wc_id}")
    # web_craft.update_attributes(web_craft_hash) if web_craft
    new (web_craft_hash)
    # web_craft
  end

  # fetch and pull
  def self.fetch(web_craft_id) web_craft_service_class.fetch(web_craft_id) end
  def self.pull(web_craft_id) web_craft_service_class.pull(web_craft_id) end
  # /fetch and pull

  def provider() self.class.provider end
  def provider_key() self.class.provider_key end

  def id_for_fetching() web_craft_id end
  def fetch() web_craft_service_class.fetch(web_craft_id) end
  def pull
    web_craft_hash = web_craft_service_class.fetch(id_for_fetching)
    # calculate_tags!(web_craft_hash)
    update_attributes(web_craft_hash)
  end

  # geocoding  aliases
  alias_method :ip_address, :address
  alias_method :ip_address=, :address=

  def latitude() coordinates.last end
  alias_method :lat, :latitude

  def latitude=(lat) coordinates ||= [0,0]; coordinates[1] = lat end
  alias_method :lat=, :latitude=

  def longitude() coordinates.first end
  alias_method :lng, :longitude
  alias_method :long, :longitude

  def longitude=(lng) coordinates[0] = lng end
  alias_method :lng=, :longitude=
  alias_method :long=, :longitude=
  # /geocoding  aliases

  # geo point hash representation
  def geo_point() { lat:lat, lng:lng } end
  def geo_point=(latlng_hash)
    lt   = latlng_hash[:latitude]   if latlng_hash[:latitude].present?
    lt ||= latlng_hash[:lat]        if latlng_hash[:lat].present?

    ln   = latlng_hash[:longitude]  if latlng_hash[:longitude].present?
    ln ||= latlng_hash[:long]       if latlng_hash[:long].present?
    ln ||= latlng_hash[:lng]        if latlng_hash[:lng].present?

    self.lat = lt
    self.lng = ln
    { lat:lat, lng:lng }
  end
  alias_method :geo_coordinate, :geo_point
  alias_method :geo_coordinate=, :geo_point=
  # /geo point hash representation

  private
  def format_attributes
    self.web_craft_id = "#{web_craft_id}" unless web_craft_id.kind_of? String
    # urlify
    self.website = website.downcase.urlify! if website.looks_like_url?
    self.href = href.downcase.urlify! if href.looks_like_url?
  end

  def geocode_this_location!
    if self.lat.present? and (new? or changes[:coordinates].present?)
      reverse_geocode # udate the address
    elsif location_hash.present? and not self.lat.present? and (new? or changes[:location_hash].present?)
      l = []
      (l << location_hash[:address]) if location_hash[:address].present?
      (l << location_hash[:city]) if location_hash[:city].present?
      (l << location_hash[:state]) if location_hash[:state].present?
      (l << location_hash[:zip]) if location_hash[:zip].present?
      (l << location_hash[:country]) if location_hash[:country].present?
      self.address = l.join(', ') if l.present?
      geocode # update lat, lng
    end
    return true
  end

end