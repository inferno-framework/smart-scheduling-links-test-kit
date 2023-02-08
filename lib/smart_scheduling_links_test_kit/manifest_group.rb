module SMARTSchedulingLinks
  class ManifestGroup < Inferno::TestGroup
    id :smart_scheduling_links_manifest
    title 'Bulk Publication Manifest'

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
        Verify that the manifest can be downloaded and is valid JSON
      )

      makes_request :manifest
      output :manifest

      run do
        assert_valid_http_uri(url)

        get url, name: :manifest, headers: { 'Accept' => 'application/json' }
        assert_response_status(200)
        assert_valid_json(request.response_body)

        output manifest: request.response_body
      end
    end
  end
end
