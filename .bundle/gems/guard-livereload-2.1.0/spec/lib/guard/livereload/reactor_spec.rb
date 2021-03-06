require 'spec_helper'

describe Guard::LiveReload::Reactor do
  let(:paths) { %w[stylesheets/layout.css stylesheets/style.css] }
  before { Guard::UI.stub(:info) }

  describe "#reload_browser(paths = [])" do
    it "displays a message" do
      expect(Guard::UI).to receive(:info).with("Reloading browser: stylesheets/layout.css stylesheets/style.css")
      new_live_reactor.reload_browser(paths)
    end

    it "each web socket receives send with data containing default options for each path modified" do
      reactor = new_live_reactor
      paths.each do |path|
        reactor.web_sockets.each do |ws|
          expect(ws).to receive(:send).with(MultiJson.encode(['refresh', path: "#{Dir.pwd}/#{path}", apply_js_live: true, apply_css_live: true]))
        end
      end
      reactor.reload_browser(paths)
    end

    it "each web socket receives send with data containing custom options for each path modified" do
      reactor = new_live_reactor(apply_css_live: false, apply_js_live: false)
      paths.each do |path|
        reactor.web_sockets.each do |ws|
          expect(ws).to receive(:send).with(MultiJson.encode(['refresh', path: "#{Dir.pwd}/#{path}", apply_js_live: false, apply_css_live: false]))
        end
      end
      reactor.reload_browser(paths)
    end
  end

end

def new_live_reactor(options = {})
  Guard::LiveReload::Reactor.new({ api_version: '1.6', host: '0.0.0.0', port: '35729', apply_js_live: true, apply_css_live: true, grace_period: 0 }.merge(options))
end
