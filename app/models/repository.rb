class Repository
  include ActiveModel::Model
  attr_accessor :title,
                :link,
                :description,
                :created_at,
                :pull_requests

  def sorted_pull_requests
    @sorted ||= pull_requests.sort { |a, b| b.created_at <=> a.created_at }
  end

  def language
    'en-us'
  end

  def created_at=(created_at)
    @created_at = DateTime.parse(created_at)
  end
end