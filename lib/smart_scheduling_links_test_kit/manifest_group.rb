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
      )

      run do
        assert url.ends_with?('$bulk-publish'), "`#{url}` does not end with `$bulk-publish`"

        assert_valid_http_uri(url)
      end
    end
  end
end
