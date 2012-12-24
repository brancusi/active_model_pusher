module ActiveModel
  class Pusher

    class_attribute :_events
    self._events = []

    class << self
      def events(*events)
        self._events = Events.new events
      end
    end


    def initialize(record)
      @record = record
    end


    def push!(event_or_socket_id = nil, socket_id = nil)
      event, socket_id = parse_push_params(event_or_socket_id, socket_id)

      event ||= RecordEventRecognizer.new(record).event

      events.validate! event

      ::Pusher.trigger channel, event_name(event), json, socket_id
    end

    private
      def parse_push_params(event_or_socket_id = nil, socket_id = nil)
        if event_or_socket_id && socket_id
          event = event_or_socket_id
        end

        if event_or_socket_id && socket_id.nil?
          if events.validate(event_or_socket_id)
            event = event_or_socket_id
          else
            socket_id = event_or_socket_id
          end
        end

        [event, socket_id]
      end

      def events
        self._events
      end

      def record
        @record
      end

      def channel
        @channel ||= RecordChannel.new(record).channel!
      end

      def event_name(event)
        @formatted_event ||= EventFormatter.new(record, event).event
      end

      def json
        @json ||= RecordSerializer.new(record).json!
      end

  end
end