module SMARTSchedulingLinks
  module ResourceChecker
    def max_lines
      @max_lines ||=
          max_lines_per_file.to_i == 0 ? 100 : max_lines_per_file.to_i
    end

    def validate_response(url, profile_url)
      previous_chunk = String.new

      @valid_resource_count ||= 0

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
          @valid_resource_count += 1 if resource_is_valid?(resource:, profile_url:)

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

    input :max_lines_per_file,
          title: 'Maximum number of resources to validate per file',
          default: '100'

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

        vtrcks_pin_found = false

        location_urls.each do |location_url|
          validate_response(location_url, profile_url)

          request.response_body&.each_line do |line|
            break if vtrcks_pin_found

            location = FHIR.from_contents(line)
            vtrcks_pin_found =
              location
                &.identifier
                &.any? { |identifier| identifier.system == 'https://cdc.gov/vaccines/programs/vtrcks' }

          end

          assert(
            messages.none? { |message| message[:type] == 'error' },
            "Succesfully validated #{@valid_resource_count} resources. Test stops after first invalid resource"
          )
        end

        assert vtrcks_pin_found, "No Locations included a VTrckS PIN."

        pass "Successfully validated #{@valid_resource_count} resources."
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
          validate_response(slot_url, profile_url)

          assert(
            messages.none? { |message| message[:type] == 'error' },
            "Succesfully validated #{@valid_resource_count} resources. Test stops after first invalid resource"
          )
        end

        pass "Successfully validated #{@valid_resource_count} resources."
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
          validate_response(schedule_url, profile_url)

          assert(
            messages.none? { |message| message[:type] == 'error' },
            "Succesfully validated #{@valid_resource_count} resources. Test stops after first invalid resource"
          )
        end

        pass "Successfully validated #{@valid_resource_count} resources."
      end
    end
  end
end
