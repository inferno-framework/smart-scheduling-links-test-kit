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
end
