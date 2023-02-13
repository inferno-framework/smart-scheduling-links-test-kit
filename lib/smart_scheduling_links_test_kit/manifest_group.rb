module SMARTSchedulingLinks
  class ManifestGroup < Inferno::TestGroup
    id :smart_scheduling_links_manifest
    title 'Bulk Publication Manifest'
    description %(
      This group of tests retrieves a bulk publication manifest and verifies
      that it is properly structured.
    )

    input :url,
          title: 'Bulk Publication Manifest Url'

    test do
      id :manifest_url_form
      title 'Bulk Publication Manifest is a valid URL ending in $bulk-publish'
      description %(
        The manifest is always hosted at a URL that ends with `$bulk-publish`

        https://github.com/smart-on-fhir/smart-scheduling-links/blob/master/specification.md#quick-start-guide
      )

      run do
        assert url.ends_with?('$bulk-publish'), "`#{url}` does not end with `$bulk-publish`"

        assert_valid_http_uri(url)
      end
    end

    test do
      id :manifest_download
      title 'Bulk Publication Manifest can be downloaded'
      description %(
        Verify that the manifest can be downloaded and is valid JSON.

        Note that the spec requires that servers respond the same way if a
        client sends no `Accept` header or an `Accept` header of
        `application/json`, but this test only tests with the `Accept` header.
        The HTTP client used by Inferno automatically adds an `Accept` header of
        `*/*` if no `Accept` header is present. For this reason, Inferno is
        unable to test that the server correctly responds to a manifest request
        when no `Accept` header is present.
      )

      makes_request :manifest
      output :manifest_json

      run do
        assert_valid_http_uri(url)

        get url, name: :manifest, headers: { 'Accept' => 'application/json' }
        assert_response_status(200)
        assert_valid_json(request.response_body)

        output manifest_json: request.response_body
      end
    end

    test do
      id :manifest_cache_control_header
      title 'Slot Publisher includes a Cache-Control: max-age Header'
      description %(
        Slot Publishers SHOULD include a `Cache-Control: max-age=<seconds>`
        header as a hint to clients about how long (in seconds) to wait before
        polling next. For example, `Cache-Control: max-age=300` indicates a
        preferred polling interval of five minutes.
      )
      optional

      uses_request :manifest

      run do
        assert_response_status(200)

        cache_control_header = request.response_header('cache-control')&.value
        assert cache_control_header&.match?(/max-age=\d+/),
               "No `Cache-Control: max-age=<seconds>` header received."
      end
    end

    test do
      id :manifest_structure
      title 'Bulk Publication Manifest has correct structure'
      description %(
        Verify that the manifest has the correct JSON structure
      )

      input :manifest_json, type: 'textarea'
      output :locations_json, :schedules_json, :slots_json

      INSTANT_REGEX = /([0-9]([0-9]([0-9][1-9]|[1-9]0)|[1-9]00)|[1-9]000)-(0[1-9]|1[0-2])-(0[1-9]|[1-2][0-9]|3[0-1])T([01][0-9]|2[0-3]):[0-5][0-9]:([0-5][0-9]|60)(\.[0-9]+)?(Z|(\+|-)((0[0-9]|1[0-3]):[0-5][0-9]|14:00))/

      run do
        skip_if manifest_json.blank?, 'No manifest received'
        assert_valid_json(manifest_json)

        manifest = JSON.parse(manifest_json)
        assert manifest.is_a?(Hash), "Expected manifest to be a JSON object, but found `#{manifest.class}`"

        manifest_fields = {
          'transactionTime' => String,
          'request' => String,
          'output' => Array
        }

        manifest_fields.each do |field, type|
          assert manifest[field].is_a?(type),
                 "`#{field}` field should be `#{type}`, but found `#{manifest[field].class}`"
        end

        outputs = manifest['output']
        locations =
          outputs
            .select { |output| output['type'] == 'Location' }
            .map { |output| output['url'] }
        schedules =
          outputs
            .select { |output| output['type'] == 'Schedule' }
            .map { |output| output['url'] }
        slots =
          outputs
            .select { |output| output['type'] == 'Slot' }
            .map { |output| output['url'] }

        output locations_json: locations.to_json,
               schedules_json: schedules.to_json,
               slots_json: slots.to_json

        transaction_time = manifest['transactionTime']
        assert transaction_time.match?(INSTANT_REGEX),
               "`transactionTime` is not in `YYYY-MM-DDThh:mm:ss.sss+zz:zz` format: `#{transaction_time}`"

        request_url = manifest['request']
        assert_valid_http_uri(request_url)

        manifest_outputs =
          manifest['output']
            .reject { |output| ['Location', 'Schedule', 'Slot'].exclude? output['type'] }

        output_fields = {
          'type' => String,
          'url' => String
        }

        manifest_outputs.each do |output|
          output_fields. each do |field, type|
            assert output[field].is_a?(type),
                   "`output.#{field}` field should be `#{type}`, but found `#{output[field].class}`"
          end

          assert_valid_http_uri(output['url'])

          extension = output['extension']
          if extension.present?
            assert extension.is_a?(Hash),
                   "`output.extension` field should be a JSON Object, but found `#{extension.class}`"

            states = extension['state']
            if states.present?
              assert states.is_a?(Array),
                     "`output.extension.state` field should be an Array, but found `#{states.class}`"

              bad_states = states.reject { |state| state.is_a? String }
              bad_states_string = bad_states.map { |bad_state| "`#{bad_state.inspect}`" }.join(', ')
              assert bad_states.empty?,
                     "The following `output.extension.state` entries are not Strings: #{bad_states_string}"
            end
          end
        end
      end
    end
  end
end
