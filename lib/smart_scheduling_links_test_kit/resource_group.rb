module SMARTSchedulingLinks
  module ResourceChecker
    def validate_response(url, profile_url, max_lines)
      previous_chunk = String.new

      line_count = 0

      process_body = lambda do |new_chunk, _|
        current_chunk = previous_chunk + new_chunk
        lines = current_chunk.lines
        previous_chunk = lines.pop || String.new

        lines.each do |line|
          break if (max_lines.present? && line_count >= max_lines) ||
                   messages.any? { |message| message[:type] == 'error' }

          assert_valid_json(line)

          resource = FHIR.from_contents(line)
          resource_is_valid?(resource:, profile_url:)

          line_count += 1
        end
      end

      stream(process_body, url, headers: { 'Accept' => 'application/fhir+ndjson' })
    end
  end

  class ResourceGroup < Inferno::TestGroup
    id :smart_scheduling_links_resources
    title 'Resource Retrieval'
    description %(
      Retrieve and validate the Location, Slot, and Schedule resources listed in
      a bulk publication manifest.
    )

    test do
      include ResourceChecker
      id :location_resources
      title 'Location Resources'

      input :locations_json,
            type: 'textarea',
            title: 'Location URLs',
            description: 'A list of URLs for Location files as a JSON-encoded array of strings'

      run do
        assert locations_json.present?, 'No Location urls received'
        assert_valid_json(locations_json)
        profile_url = 'http://fhir-registry.smarthealthit.org/StructureDefinition/vaccine-location'

        location_urls = JSON.parse(locations_json)

        location_urls.each do |location_url|
          validate_response(location_url, profile_url, 100)

          assert(messages.none? { |message| message[:type] == 'error' })
        end
      end
    end

    test do
      include ResourceChecker
      id :slot_resources
      title 'Slot Resources'

      input :slots_json,
            type: 'textarea',
            title: 'Slot URLs',
            description: 'A list of URLs for Slot files as a JSON-encoded array of strings'

      run do
        assert slots_json.present?, 'No Slot urls received'
        assert_valid_json(slots_json)
        profile_url = 'http://fhir-registry.smarthealthit.org/StructureDefinition/vaccine-slot'

        slot_urls = JSON.parse(slots_json)

        slot_urls.each do |slot_url|
          validate_response(slot_url, profile_url, 100)

          assert(messages.none? { |message| message[:type] == 'error' })
        end
      end
    end

    test do
      include ResourceChecker
      id :schedule_resources
      title 'Schedule Resources'

      input :schedules_json,
            type: 'textarea',
            title: 'Schedule URLs',
            description: 'A list of URLs for Schedule files as a JSON-encoded array of strings'

      run do
        assert schedules_json.present?, 'No Schedule urls received'
        assert_valid_json(schedules_json)
        profile_url = 'http://fhir-registry.smarthealthit.org/StructureDefinition/vaccine-schedule'

        schedule_urls = JSON.parse(schedules_json)

        schedule_urls.each do |schedule_url|
          validate_response(schedule_url, profile_url, 100)

          assert(messages.none? { |message| message[:type] == 'error' })
        end
      end
    end
  end
end
