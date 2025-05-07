# Trenchcoat

## Installation

TODO: Replace `UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG` with your gem name right after releasing it to RubyGems.org. Please do not do it earlier due to security reasons. Alternatively, replace this section with instructions to install your gem from git if you don't plan to release to RubyGems.org.

Install the gem and add to the application's Gemfile by executing:

    $ bundle add UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG

## Usage

`Trenchcoat::Model` is a concern that gives you some helper methods to streamline creating custom ActiveModels based
on your existing models, which is great for building complex forms without making your ActiveRecord models a mess with
virtual attributes.

Like 3 kids stacked on top of each other in a trenchcoat, your custom ActiveModel is quacking like your underlying model
to sneak into the theater:

- There is a helper method to use the model attributes you want to fallback to *if there is not already a value in this model*
- It doesn't have any validations, it's just copying the attribute definitions you want from the model (that have corresponding `ActiveModel` types in your app).
- It delegates the `model_name`, `id`, and `persisted?` to make form helpers & persistence checks easier.

### Example

```ruby
class Post < ApplicationRecord
  validates :body, presence: true
  validates :title, presence: true
end

# ...

class CustomForm
  include ActiveModel::Model
  include ActiveModel::Validations::Callbacks
  include ActiveModel::Attributes
  include Trenchcoat::Model

  attr_accessor :post

  copy_attribute_definitions(model_class: Post, attributes: %i[title published_at])
  quack_like(model_instance_attr: :post)

  attribute :body, :string # has to be manually defined because there is not a Text type for ActiveModel by default
  attribute :is_published, :boolean, default: false
  alias is_published? is_published

  before_validation :normalize_published_at

  def initialize(attributes = {})
    super

    published_at

    self.post = Post.new if post.blank?

    fallback_to_model_values(model: post, attributes: %i[title body published_at])

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
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/practical-computer/trenchcoat. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/practical-computer/trenchcoat/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Trenchcoat project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/practical-computer/trenchcoat/blob/main/CODE_OF_CONDUCT.md).
