# encoding: utf-8

#  Copyright (c) 2012-2013, Jungwacht Blauring Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

module Subscriber
  class EventController < BaseController

    skip_authorize_resource # must be in leaf class

    before_render_form :replace_validation_errors

    SEARCH_COLUMNS = %w(events.name
                        events.number
                        groups.name
                        event_kind_translations.label
                        event_kind_translations.short_name)

    # GET query queries available events via ajax
    def query
      events = []
      if params.key?(:q) && params[:q].size >= 3
        events = matching_events.limit(10)
        events = decorate(events)
      end

      render json: events.collect(&:as_typeahead)
    end

    private

    def subscriber
      Event.find(subscriber_id)
    end

    def matching_events
      possible = Subscription.new(mailing_list: @mailing_list).possible_events
      possible.joins('LEFT JOIN event_kinds ' \
                     'ON events.kind_id = event_kinds.id ' \
                     "AND events.type = '#{Event::Course.sti_name}' " \
                     'LEFT JOIN event_kind_translations ' \
                     'ON event_kinds.id  = event_kind_translations.event_kind_id').
               where(search_condition(*SEARCH_COLUMNS)).
               order_by_date.
               distinct
    end

    def model_label
      Event.model_name.human
    end
  end
end
