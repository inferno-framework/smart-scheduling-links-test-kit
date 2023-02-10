require_relative 'smart_scheduling_links_test_kit/manifest_group'
require_relative 'smart_scheduling_links_test_kit/resource_group'

module SMARTSchedulingLinks
  class Suite < Inferno::TestSuite
    id :smart_scheduling_links
    title 'SMART Scheduling Links'
    description %(
      Tests for [SMART Scheduling
      Links](https://github.com/smart-on-fhir/smart-scheduling-links)'.

      These tests work by retrieving a bulk publication manifest, then
      retrieving the files listed in the manifest and validating the resources
      they contain.
    )

    validator do
      url ENV.fetch('VALIDATOR_URL')
      exclude_message { |message| message.type == 'info' }
    end

    group from: :smart_scheduling_links_manifest
    group from: :smart_scheduling_links_resources
  end
end
