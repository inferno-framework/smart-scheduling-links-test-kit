require_relative 'smart_scheduling_links_test_kit/manifest_group'
require_relative 'smart_scheduling_links_test_kit/resource_group'
require_relative 'smart_scheduling_links_test_kit/version'

module SMARTSchedulingLinks
  class Suite < Inferno::TestSuite
    id :smart_scheduling_links
    title 'SMART Scheduling Links'
    description %(
      Tests for [SMART Scheduling
      Links](https://github.com/smart-on-fhir/smart-scheduling-links).

      These tests work by retrieving a bulk publication manifest, then
      retrieving the files listed in the manifest and validating the HL7® FHIR® resources
      they contain.
    )
    version VERSION

    VALIDATION_MESSAGE_FILTERS = [
      /\A\S+: \S+: URL value '.*' does not resolve/
    ].freeze

    fhir_resource_validator do
      igs 'igs/smart_scheduling_links_ig.tgz'

      exclude_message do |message|
        message.type == 'info' ||
          VALIDATION_MESSAGE_FILTERS.any? { |filter| filter.match? message.message }
      end

      perform_additional_validation do |resource, profile_url|
        next unless profile_url == 'http://fhir-registry.smarthealthit.org/StructureDefinition/vaccine-slot'

        begin
          start_time = DateTime.parse(resource.start)
          end_time = DateTime.parse(resource.end)
        rescue StandardError
          next
        end

        messages = []

        slot_hours = (end_time - start_time).days.in_hours

        if slot_hours > 1
          warning_message = <<~MESSAGE
            #{resource.resourceType}/#{resource.id}: Slot duration is
            #{slot_hours.abs.round(1)} hours, but `start` and `end` SHOULD
            identify a narrow window of time.
          MESSAGE

          messages << {
            type: 'warning',
            message: warning_message
          }

          has_capacity_extension = resource.extension&.any? do |extension|
            extension.url == 'http://fhir-registry.smarthealthit.org/StructureDefinition/slot-capacity'
          end

          if !has_capacity_extension
            warning_message = <<~MESSAGE
              #{resource.resourceType}/#{resource.id}: Slot should include a
              #capacity extension if its duration is longer than an hour.
            MESSAGE

            messages << {
              type: 'warning',
              message: warning_message
            }
          end
        end

        messages
      end
    end

    group from: :smart_scheduling_links_manifest
    group from: :smart_scheduling_links_resources
  end
end
