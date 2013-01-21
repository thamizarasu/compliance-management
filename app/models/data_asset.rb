class DataAsset < ActiveRecord::Base
  include AuthoredModel
  include SluggedModel
  include SearchableModel
  include AuthorizedModel
  include RelatedModel
  include SanitizableAttributes
  include BusinessObjectModel

  attr_accessible :title, :slug, :description, :url, :version, :start_date, :stop_date

  has_many :object_people, :as => :personable, :dependent => :destroy
  has_many :people, :through => :object_people

  has_many :object_documents, :as => :documentable, :dependent => :destroy
  has_many :documents, :through => :object_documents

  is_versioned_ext

  sanitize_attributes :description

  validates :title,
    :presence => { :message => "needs a value" }

  @valid_relationships = [
    { :to   => DataAsset,   :via => :data_asset_contains_a_data_asset },
    { :from => DataAsset,   :via => :data_asset_contains_a_data_asset },
    { :to   => Facility, :via => :data_asset_is_dependent_on_facility },
    { :from => OrgGroup, :via => :org_group_has_province_over_data_asset },
    { :from => Product,  :via => :product_is_sold_into_data_asset },
    { :to   => RiskyAttribute, :via => :data_asset_has_risky_attribute },
  ]

  def display_name
    slug
  end
end