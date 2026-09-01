class Visit < ApplicationRecord
  belongs_to :brief

  # POPIA: never store a raw IP — a salted hash is enough to tell visitors apart.
  def self.record(brief, request)
    create!(
      brief: brief,
      viewed_at: Time.current,
      user_agent: request.user_agent.to_s.first(255),
      ip_hash: hash_ip(request.remote_ip)
    )
  end

  def self.hash_ip(ip)
    Digest::SHA256.hexdigest("#{Rails.application.secret_key_base}:#{ip}").first(16)
  end
end
