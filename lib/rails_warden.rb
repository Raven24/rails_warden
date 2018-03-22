# encoding: utf-8
require 'warden'

require "rails_warden/version"
require "rails_warden/engine"

require "rails_warden/authentication"
require "rails_warden/manager"
require "rails_warden/rails_settings"

module Warden::Mixins::Common
  def request
    @request ||= ActionDispatch::Request.new(env)
  end

  def reset_session!
    request.reset_session
  end

  def cookies
    request.cookie_jar
  end

  def logger
    Rails.logger
  end
end

Warden::Manager.before_failure do |env, opts|
  opts ||= {}
  action = opts[:action] || RailsWarden.unauthenticated_action || "unauthenticated"
  env['action_dispatch.request.path_parameters'][:action] = action
end

class Warden::SessionSerializer
  def serialize(user)
    [user.class.name, user.id]
  end

  def deserialize(key)
    klass, id = key
    klass = case klass
            when Class
              klass
            when String, Symbol
              klass.to_s.classify.constantize
            end
    klass.find_by(id: id)
  end
end
