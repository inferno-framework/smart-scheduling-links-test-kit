require_relative 'smart_scheduling_links_test_kit/manifest_group'

module SMARTSchedulingLinks
  class Suite < Inferno::TestSuite
    id :smart_scheduling_links
    title 'SMART Scheduling Links'
    description 'Tests for [SMART Scheduling Links](https://github.com/smart-on-fhir/smart-scheduling-links)'

    # input :credentials,
    #       title: 'OAuth Credentials',
    #       type: :oauth_credentials,
    #       optional: true

    # # All FHIR requests in this suite will use this FHIR client
    # fhir_client do
    #   url :url
    #   oauth_credentials :credentials
    # end

    # # All FHIR validation requsets will use this FHIR validator
    # validator do
    #   url ENV.fetch('VALIDATOR_URL')
    # end

    group from: :smart_scheduling_links_manifest
  end
end
