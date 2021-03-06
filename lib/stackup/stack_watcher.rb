require "aws-sdk-cloudformation"

module Stackup

  # A stack event observer.
  #
  # Keeps track of previously processed events, and yields the new ones.
  #
  class StackWatcher

    def initialize(stack)
      @stack = stack
    end

    attr_accessor :stack

    # rubocop:disable Lint/HandleExceptions

    # Yield all events since the last call
    #
    def each_new_event
      new_events = []
      stack.events.each do |event|
        break if event.id == @last_processed_event_id

        new_events.unshift(event)
      end
      new_events.each do |event|
        yield event
        @last_processed_event_id = event.id
      end
    rescue Aws::CloudFormation::Errors::ValidationError => _e
    end

    # Consume all new events
    #
    def zero
      last_event = stack.events.first
      @last_processed_event_id = last_event.id unless last_event.nil?
      nil
    rescue Aws::CloudFormation::Errors::ValidationError
    end

    # rubocop:enable Lint/HandleExceptions

    private

    attr_accessor :processed_event_ids

  end

end
