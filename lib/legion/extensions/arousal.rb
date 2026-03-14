# frozen_string_literal: true

require 'legion/extensions/arousal/version'
require 'legion/extensions/arousal/helpers/constants'
require 'legion/extensions/arousal/helpers/arousal_model'
require 'legion/extensions/arousal/runners/arousal'

module Legion
  module Extensions
    module Arousal
      extend Legion::Extensions::Core if Legion::Extensions.const_defined? :Core
    end
  end
end
