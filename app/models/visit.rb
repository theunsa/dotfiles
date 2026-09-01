class Visit < ApplicationRecord
  belongs_to :brief

  # Enough of the user agent to answer the only question the admin list asks:
  # which kind of device, which browser. Deliberately crude string matching —
  # a real UA parser is a gem and a moving dataset, and this is a two-word
  # summary with the raw string one click away underneath it.
  #
  # Order matters in both lists: Chrome's UA also says Safari, Edge's says both.
  DEVICES = [
    [ /iPhone/, "iPhone" ], [ /iPad/, "iPad" ], [ /Android/, "Android phone" ],
    [ /Macintosh|Mac OS X/, "Mac" ], [ /Windows/, "Windows PC" ], [ /Linux/, "Linux" ]
  ].freeze
  BROWSERS = [
    [ /Edge?[A-Z]*\//, "Edge" ], [ /OPR\/|Opera/, "Opera" ], [ /CriOS|Chrome/, "Chrome" ],
    [ /FxiOS|Firefox/, "Firefox" ], [ /Safari/, "Safari" ]
  ].freeze

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

  def device = match(DEVICES) || "Unknown device"

  def browser = match(BROWSERS)

  def description = [ device, browser ].compact.join(" · ")

  # Short enough to read at a glance, and only ever compared to other visits on
  # the same brief: the same code twice means the same network came back.
  def visitor_id = ip_hash.presence&.first(6)

  private

  def match(patterns)
    patterns.find { |pattern, _| user_agent.to_s.match?(pattern) }&.last
  end
end
