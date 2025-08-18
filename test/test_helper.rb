# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "trenchcoat"
require "active_record"
require "action_controller"
require "debug"

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")

ActiveRecord::Schema.define do
  create_table :posts do |t|
    t.string :title, null: false
    t.text :body, null: false, default: "It was a dark and stormy night"
    t.datetime :published_at
  end
end

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end

class Post < ApplicationRecord
  validates :body, presence: true
  validates :title, presence: true
end

require "minitest/autorun"
