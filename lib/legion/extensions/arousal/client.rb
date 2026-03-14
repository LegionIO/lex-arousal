# frozen_string_literal: true

require 'legion/extensions/arousal/helpers/constants'
require 'legion/extensions/arousal/helpers/arousal_model'
require 'legion/extensions/arousal/runners/arousal'

module Legion
  module Extensions
    module Arousal
      class Client
        include Runners::Arousal

        def initialize(**)
          @arousal_model = Helpers::ArousalModel.new
        end

        private

        attr_reader :arousal_model
      end
    end
  end
end
