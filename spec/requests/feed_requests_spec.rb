require 'rails_helper'

describe 'Repo requests' do
  describe 'GET /feeds/:owner/:repo' do
    it 'returns an rss response' do
      stub_github_request

      get feed_path(owner: 'github', repo: 'code')

      expect(response.content_type).to eq(Mime::Type.lookup_by_extension(:rss))
    end

    it 'has channel attributes' do
      stub_github_request

      get feed_path(owner: 'github', repo: 'code')

      expect(xml[:title]).to eq('github/code pull requests')
      expect(xml[:description]).to eq('A repo with some really good code.')
      expect(xml[:pubDate]).to eq('Tue, 5 May 2015 07:50:40 +0000')
      expect(xml[:lastBuildDate]).to eq('Tue, 5 May 2015 07:50:40 +0000')
      expect(xml[:link]).to eq('https://github.com/github/code')
      expect(xml['atom:link']).to eq({
        href: 'http://www.example.com/feeds/github/code',
        rel: 'self',
        type: 'application/rss+xml'
      })
    end

    it 'has item attributes' do
      stub_github_request

      get feed_path(owner: 'github', repo: 'code')

      expect(first_item[:title]).to eq('Improve the code very much')
      expect(first_item[:description]).to eq(html_description)
      expect(first_item[:link]).to eq('https://github.com/github/code/pull/564')
      expect(first_item[:pubDate]).to eq('Tue, 5 May 2015 07:50:40 +0000')
      expect(first_item[:guid]).to eq('https://github.com/github/code/pull/564')
    end

    it 'formats the dates according to the rfc822 standard' do
      stub_github_request

      get feed_path(owner: 'github', repo: 'code')

      expect(xml[:pubDate]).to eq('Tue, 5 May 2015 07:50:40 +0000')
      expect(xml[:lastBuildDate]).to eq('Tue, 5 May 2015 07:50:40 +0000')
      expect(first_item[:pubDate]).to eq('Tue, 5 May 2015 07:50:40 +0000')
    end
  end

  def xml
    @_xml ||= Hash.from_xml(response.body)['rss']['channel'].tap do |feed|
      feed.deep_symbolize_keys!
      feed['atom:link'] = feed[:link].last
      feed[:link] = feed[:link].first
    end
  end

  def first_item
    @_first_item = xml[:item].first
  end

  def stub_github_request
    stub_request(:get, /.*api.github.com.*/).
      to_return(body: fixture_load('github', 'pulls.json'),
                headers: { 'Content-Type' => 'application/json' })
  end

  def html_description
    "<p>A very important pull request that makes the <code>code</code> much better.</p>\n"
  end
end
