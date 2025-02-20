module SMARTSchedulingLinks
  class Metadata < Inferno::TestKit
    id :smart_scheduling_links_test_kit
    title 'SMART Scheduling Links Test Kit'
    suite_ids ['smart_scheduling_links'] 
    tags []
    last_updated ::SMARTSchedulingLinks::LAST_UPDATED
    version ::SMARTSchedulingLinks::VERSION
    maturity 'Medium'
    authors ['Inferno Team']
    repo 'https://github.com/inferno-framework/smart-scheduling-links-test-kit'
    description <<~DESCRIPTION
      The SMART Scheduling Links Test Kit provides an executable set of tests
      for the
      [SMART Scheduling Links Draft IG](https://github.com/smart-on-fhir/smart-scheduling-links).
      These tests retrieve a bulk publication manifest, retrieve the files
      listed in the manifest, and then validate the resources they contain.
      
      <!-- break -->
      
      This test kit is open source and freely available for use or adoption
      by the health IT community including EHR vendors, health app developers,
      and testing labs. It is built using the
      [Inferno Framework](https://inferno-framework.github.io/).
      The Inferno Framework is designed for reuse and aims to make it easier
      to build test kits for any FHIR-based data exchange.
      
      ## Status
      
      These tests are a DRAFT intended to allow SMART Scheduling Links server
      implementers to perform checks of their server against the current draft
      SMART Scheduling Links requirements.
      
      The test kit currently tests the following requirements:
      
      - Bulk Publication Manifest Validation
      - Resource Retrieval
      
      See the test descriptions within the test kit for detail on the specific
      validations performed as part of testing these requirements.
      
      ## Repository
      
      The SMART Scheduling Links Test Kit GitHub repository can be
      [found here](https://github.com/inferno-framework/smart-scheduling-links).
      
      ## Providing Feedback and Reporting Issues
      
      We welcome feedback on the tests, including but not limited to the
      following areas:
      
      - Validation logic, such as potential bugs, lax checks, and unexpected failures.
      - Requirements coverage, such as requirements that have been missed, tests that
        necessitate features that the IG does not require, or other issues with the
        interpretation of the IG’s requirements.
      - User experience, such as confusing or missing information in the test UI.
      
      Please report any issues with this set of tests in the
      [issues section](https://github.com/inferno-framework/smart-scheduling-links/issues)
      of the repository.
    DESCRIPTION
  end
end
