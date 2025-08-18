# frozen_string_literal: true

require "test_helper"

class TestTrenchcoat < ActiveSupport::TestCase
  test "has a version number" do
    refute_nil ::Trenchcoat::VERSION
  end
end

class TestTrenchcoat
  class Model < ActiveSupport::TestCase
    class CustomForm
      include ActiveModel::Model
      include ActiveModel::Validations::Callbacks
      include ActiveModel::Attributes
      include Trenchcoat::Model

      attr_accessor :post

      copy_attribute_definitions(model_class: Post, attributes: %i[title body published_at])
      quack_like(model_instance_attr: :post)

      attribute :is_published, :boolean, default: false
      alias is_published? is_published

      before_validation :normalize_published_at

      def initialize(attributes = {})
        super

        published_at

        self.post = Post.new if post.blank?
        fallback_to_model_values(
          model: post,
          attributes_to_check: %i[title body published_at],
          original_attributes_hash: attributes
        )

        return if attributes.key?(:is_published)

        self.is_published = published_at.present?
      end

      def save!
        validate!

        post.update!(
          title: title,
          body: body,
          published_at: published_at
        )
      end

      protected

      def normalize_published_at
        unless is_published?
          self.published_at = nil
          return
        end

        return if published_at.present?

        self.published_at = Time.now
      end
    end

    test "fallback_to_model_values: no model instance provided" do
      form = CustomForm.new

      assert_equal true, form.post.new_record?
      assert_nil form.title
      assert_equal "It was a dark and stormy night", form.body
      assert_nil form.published_at
      assert_equal false, form.is_published
    end

    test "fallback_to_model_values: params given, no model instance" do
      time = Time.utc(2021, 2, 2)
      form = CustomForm.new(title: "Hello", body: "World", published_at: time, is_published: "1")

      assert_equal true, form.post.new_record?
      assert_equal "Hello", form.title
      assert_equal "World", form.body
      assert_equal time, form.published_at
      assert_equal true, form.is_published
    end

    test "fallback_to_model_values: params given, falls back to model instance if original_attributes_hash did not include parameter" do
      time = Time.utc(2021, 2, 2)
      post = Post.create!(title: "A Post", body: "Post Content")
      form = CustomForm.new(post: post, title: "Hello", published_at: time, is_published: "1")

      assert_equal post, form.post
      assert_equal "Hello", form.title
      assert_equal "Post Content", form.body
      assert_equal time, form.published_at
      assert_equal true, form.is_published
    end

    test "fallback_to_model_values: no params given, falls back to model instance" do
      post = Post.create!(title: "A Post", body: "Post Content", published_at: Time.now)
      form = CustomForm.new(post: post)

      assert_equal post, form.post
      assert_equal "A Post", form.title
      assert_equal "Post Content", form.body
      assert_equal post.published_at, form.published_at
      assert_equal true, form.is_published
    end

    test "fallback_to_model_values: given ActionController::Parameters" do
      time = Time.utc(2021, 2, 2)
      post = Post.create!(title: "A Post", body: "Post Content")

      parameters = ActionController::Parameters.new(title: "Hello", published_at: time, is_published: "1").permit(
        :title, :body, :published_at
      ).merge(post: post)

      form = CustomForm.new(parameters)

      assert_equal post, form.post
      assert_equal "Hello", form.title
      assert_equal "Post Content", form.body
      assert_equal time, form.published_at
      assert_equal true, form.is_published
    end

    test "creating a new record, updating" do
      form = CustomForm.new
      form.title = SecureRandom.hex
      form.body = SecureRandom.hex
      form.is_published = true

      form.save!

      post = Post.last

      assert_equal post, form.post
      assert_equal form.title, post.title
      assert_equal form.body, post.body
      assert_not_nil post.published_at

      form.is_published = false
      form.save!

      post.reload
      assert_nil post.published_at

      form.is_published = true
      form.save!

      post.reload
      assert_not_nil post.published_at
    end

    test "updating an existing record" do
      post = Post.create!(title: "A Post", body: "Post Content", published_at: Time.now)
      CustomForm.new(post: post)

      params = { title: "From a request", body: "Hey there!", is_published: "0" }

      update_form = CustomForm.new(params.merge(post: post))
      update_form.save!

      post.reload

      assert_equal "From a request", post.title
      assert_equal "Hey there!", post.body
      assert_nil post.published_at
    end

    test "quack_like: no record given" do
      form = CustomForm.new

      assert_equal Post.model_name, form.model_name
      assert_equal false, form.persisted?
      assert_equal true, form.new_record?
      assert_nil form.id
    end

    test "quack_like: new record given" do
      form = CustomForm.new(post: Post.new)

      assert_equal Post.model_name, form.model_name
      assert_equal false, form.persisted?
      assert_equal true, form.new_record?
      assert_nil form.id
    end

    test "quack_like: persisted record given" do
      post = Post.create!(title: "Testing", body: "Record")
      form = CustomForm.new(post: post)

      assert_equal Post.model_name, form.model_name
      assert_equal true, form.persisted?
      assert_equal false, form.new_record?
      assert_equal post.id, form.id
    end
  end
end
