class Division < ApplicationRecord
  #paginates_per 50
  has_many :votes, -> { order(:deputy_id => :asc) }
  has_many :mps, through: :votes
  has_one :division_info
  has_many :division_infos
  has_many :whips
  has_many :policy_divisions
  has_many :policies, through: :policy_divisions


  def find_mp(id)
    find_by(deputy_id: id )
  end
  def self.find_by_search_query(query)
    where("UPPER(name) like :query_name ", { query_name: "%#{query.upcase}%" })
  end
  def self.to_csv
    CSV.generate do |csv|
      csv << column_names
      all.each do |d|
        csv << d.attributes.values_at(*column_names)
      end
    end
  end
end
