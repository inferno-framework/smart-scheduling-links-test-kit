RSpec.describe SMARTSchedulingLinks::ManifestGroup do
  let(:suite) { Inferno::Repositories::TestSuites.new.find('smart_scheduling_links') }
  let(:group) { described_class }
  let(:session_data_repo) { Inferno::Repositories::SessionData.new }
  let(:test_session) { repo_create(:test_session, test_suite_id: suite.id) }

  def run(runnable, inputs = {})
    test_run_params = { test_session_id: test_session.id }.merge(runnable.reference_hash)
    test_run = Inferno::Repositories::TestRuns.new.create(test_run_params)
    inputs.each do |name, value|
      session_data_repo.save(test_session_id: test_session.id, name: name, value: value, type: 'text')
    end
    Inferno::TestRunner.new(test_session: test_session, test_run: test_run).run(runnable)
  end

  describe 'manifest url test' do
    let(:test) { group.tests.find { |test| test.id.to_s.end_with? 'manifest_url_form' } }

    it 'passes if a valid bulk publish url is used' do
      url = 'http://example.com/$bulk-publish'

      result = run(test, url: url)

      expect(result.result).to eq('pass')
    end

    it 'fails if the url does not end in $bulk-publish' do
      url = 'http://example.com/$bulk-publishh'

      result = run(test, url: url)

      expect(result.result).to eq('fail')
      expect(result.result_message).to match(/does not end with/)
    end

    it 'fails if the url is not a valid url' do
      url = 'httpexample.com/$bulk-publish'

      result = run(test, url: url)

      expect(result.result).to eq('fail')
      expect(result.result_message).to match(/is not a valid URI/)
    end
  end

  describe 'manifest download test' do
    let(:test) { group.tests.find { |test| test.id.to_s.end_with? 'manifest_download' } }
    let(:url) { 'http://example.com/$bulk-publish' }

    it 'passes if a 200 with valid JSON is received' do
      manifest_request =
        stub_request(:get, url)
          .with(headers: { 'Accept' => 'application/json' })
          .to_return(status: 200, body: {}.to_json)

      result = run(test, url: url)

      expect(result.result).to eq('pass')
      expect(manifest_request).to have_been_made.once
    end

    it 'fails if a 200 is not received' do
      manifest_request =
        stub_request(:get, url)
          .with(headers: { 'Accept' => 'application/json' })
          .to_return(status: 400, body: {}.to_json)

      result = run(test, url: url)

      expect(result.result).to eq('fail')
      expect(result.result_message).to include('400')
      expect(manifest_request).to have_been_made.once
    end

    it 'fails if the response is not valid JSON' do
      manifest_request =
        stub_request(:get, url)
          .with(headers: { 'Accept' => 'application/json' })
          .to_return(status: 200, body: '{')

      result = run(test, url: url)

      expect(result.result).to eq('fail')
      expect(result.result_message).to include('JSON')
      expect(manifest_request).to have_been_made.once
    end
  end

  describe 'manifest structure test' do
    let(:test) { group.tests.find { |test| test.id.to_s.end_with? 'manifest_structure' } }

    it 'fails if the manifest is not a JSON object' do
      result = run(test, manifest_json: [].to_json)

      expect(result.result).to eq('fail')
      expect(result.result_message).to eq('Expected manifest to be a JSON object, but found `Array`')
    end

    it 'fails if a field is the wrong type' do
      result = run(test, manifest_json: {}.to_json)

      expect(result.result).to eq('fail')
      expect(result.result_message).to eq('`transactionTime` field should be `String`, but found `NilClass`')
    end

    it 'fails if a transactionTime is incorrectly formatted' do
      manifest = {
        transactionTime: '2015-02-07T13:28:17.239',
        request: 'abc',
        output: []
      }
      result = run(test, manifest_json: manifest.to_json)

      expect(result.result).to eq('fail')
      expect(result.result_message).to match(/`transactionTime` is not in `YYYY-MM-DDThh:mm:ss.sss\+zz:zz` format:/)
    end

    it 'fails if a request is not a valid url' do
      manifest = {
        transactionTime: '2015-02-07T13:28:17.239+02:00',
        request: 'httpexample.com/$bulk-publish',
        output: []
      }
      result = run(test, manifest_json: manifest.to_json)

      expect(result.result).to eq('fail')
      expect(result.result_message).to match(/is not a valid URI/)
    end

    it 'fails if an output subfield is an invalid type' do
      manifest = {
        transactionTime: '2015-02-07T13:28:17.239+02:00',
        request: 'http://example.com/$bulk-publish',
        output: [
          {
            type: 'Location',
            url: ['http://example.com/Location']
          }
        ]
      }
      result = run(test, manifest_json: manifest.to_json)

      expect(result.result).to eq('fail')
      expect(result.result_message).to match(/`output\.url` field should be/)
    end

    it 'fails if an output contains an invalid url' do
      manifest = {
        transactionTime: '2015-02-07T13:28:17.239+02:00',
        request: 'http://example.com/$bulk-publish',
        output: [
          {
            type: 'Location',
            url: 'httpexample.com/Location'
          }
        ]
      }
      result = run(test, manifest_json: manifest.to_json)

      expect(result.result).to eq('fail')
      expect(result.result_message).to match(/is not a valid URI/)
    end

    it 'fails if output.extension is not a Hash' do
      manifest = {
        transactionTime: '2015-02-07T13:28:17.239+02:00',
        request: 'http://example.com/$bulk-publish',
        output: [
          {
            type: 'Location',
            url: 'http://example.com/Location',
            extension: ['MA']
          }
        ]
      }
      result = run(test, manifest_json: manifest.to_json)

      expect(result.result).to eq('fail')
      expect(result.result_message).to match(/`output.extension` field should be a JSON Object/)
    end

    it 'fails if the state extension is not an array' do
      manifest = {
        transactionTime: '2015-02-07T13:28:17.239+02:00',
        request: 'http://example.com/$bulk-publish',
        output: [
          {
            type: 'Location',
            url: 'http://example.com/Location',
            extension: {
              state: 'MA'
            }
          }
        ]
      }
      result = run(test, manifest_json: manifest.to_json)

      expect(result.result).to eq('fail')
      expect(result.result_message).to match(/`output.extension.state` field should be an Array/)
    end

    it 'fails if the state extension contains a non-string' do
      manifest = {
        transactionTime: '2015-02-07T13:28:17.239+02:00',
        request: 'http://example.com/$bulk-publish',
        output: [
          {
            type: 'Location',
            url: 'http://example.com/Location',
            extension: {
              state: ['MA', 123, 'VA']
            }
          }
        ]
      }
      result = run(test, manifest_json: manifest.to_json)

      expect(result.result).to eq('fail')
      expect(result.result_message).to match(/The following `output.extension.state` entries are not Strings/)
    end

    it 'passes if the manifest is well-formed' do
      manifest = {
        transactionTime: '2015-02-07T13:28:17.239+02:00',
        request: 'http://example.com/$bulk-publish',
        output: [
          {
            type: 'Location',
            url: 'http://example.com/Location',
            extension: {
              state: ['MA', 'VA']
            }
          }
        ]
      }
      result = run(test, manifest_json: manifest.to_json)

      expect(result.result).to eq('pass')
    end
  end
end
