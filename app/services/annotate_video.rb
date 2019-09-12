# frozen_string_literal: true

require 'google/cloud/video_intelligence'

module Services
  class AnnotateVideo
    def initialize
      @video_client = Google::Cloud::VideoIntelligence.new
      @features     = [:LABEL_DETECTION]
      @path         = 'gs://cloud-samples-data/video/cat.mp4'
    end

    attr_reader :video_client, :features, :path

    def call
      # Register a callback during the method call
      operation = video_client.annotate_video input_uri: path, features: features do |operation|
        raise operation.results.message? if operation.error?

        puts 'Finished Processing.'

        labels = operation.results.annotation_results.first.segment_label_annotations

        labels.each do |label|
          puts "Label description: #{label.entity.description}"

          label.category_entities.each do |category_entity|
            puts "Label category description: #{category_entity.description}"
          end

          label.segments.each do |segment|
            start_time = (segment.segment.start_time_offset.seconds +
                          segment.segment.start_time_offset.nanos / 1e9)
            end_time =   (segment.segment.end_time_offset.seconds +
                          segment.segment.end_time_offset.nanos / 1e9)

            puts "Segment: #{start_time} to #{end_time}"
            puts "Confidence: #{segment.confidence}"
          end
        end
      end

      puts 'Processing video for label annotations:'
      operation.wait_until_done!
    end
  end
end
