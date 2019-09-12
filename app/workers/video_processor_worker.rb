# frozen_string_literal: true

require 'sidekiq'
require_relative '../services/annotate_video'

class VideoProcessorWorker
  include Sidekiq::Worker

  def perform
    service = Services::AnnotateVideo.new
    service.call
  end
end
