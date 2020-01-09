# encoding: utf-8

#  Copyright (c) 2012-2016, insieme Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

require 'validates_timeliness/validator'

# Patch method to suppress deprecation warning.
# May be removed after a newer version than 3.0.14 is released
module ValidatesTimeliness
  class Validator < ActiveModel::EachValidator

    module Setup
      def initialize(options)
        super(options)
        model = options[:class]
        if model.respond_to?(:timeliness_validated_attributes)
          model.timeliness_validated_attributes ||= []
          model.timeliness_validated_attributes |= @attributes
        end
      end
    end

    prepend ValidatesTimeliness::Validator::Setup
  end
end


ValidatesTimeliness.setup do |config|
  # Extend ORM/ODMs for full support (:active_record, :mongoid).
  # config.extend_orms = [ :active_record ]
  #
  # Default timezone
  # config.default_timezone = :utc
  #
  # Set the dummy date part for a time type values.
  # config.dummy_date_for_time_type = [ 2000, 1, 1 ]
  #
  # Ignore errors when restriction options are evaluated
  # config.ignore_restriction_errors = false
  #
  # Re-display invalid values in date/time selects
  #config.enable_date_time_select_extension!
  #
  # Handle multiparameter date/time values strictly
  # config.enable_multiparameter_extension!
  #
  # Shorthand date and time symbols for restrictions
  # config.restriction_shorthand_symbols.update(
  #   :now   => lambda { Time.current },
  #   :today => lambda { Date.current }
  # )
  #
  # Use the plugin date/time parser which is stricter and extendable
  # config.use_plugin_parser = false
  #
  # Add one or more formats making them valid. e.g. add_formats(:date, 'd(st|rd|th) of mmm, yyyy')
  # config.parser.add_formats()
  #
  # Remove one or more formats making them invalid. e.g. remove_formats(:date, 'dd/mm/yyy')
  # config.parser.remove_formats()
  #
  # Change the ambiguous year threshold when parsing a 2 digit year
  # config.parser.ambiguous_year_threshold =  30
  #
  # Treat ambiguous dates, such as 01/02/1950, as a Non-US date.
  config.parser.remove_us_formats
end


module ValidatesTimeliness
  module CacheAttributeMethods

    # provide access to the cached values
    def timeliness_cache_attribute(name)
      @timeliness_cache && @timeliness_cache[name.to_s]
    end

  end
end

ActiveRecord::Base.send(:include, ValidatesTimeliness::CacheAttributeMethods)
