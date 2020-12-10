class DownloadList
  SHARED_PATH = Pathname.new(ENV.fetch("CAPYBARA_DOWNLOADED_FILE_DIR", Rails.root.join('tmp/test/downloads')))

  def initialize
    @history = []
    @latest = nil
  end

  def refresh_from(page)
    @latest = nil
    page.visit("about:downloads")
    download_name = page.evaluate_script("document.querySelector('downloads-manager').shadowRoot.querySelector('#downloadsList downloads-item').shadowRoot.querySelector('div#content #file-link')").text()
    if download_name && !@history.include?(download_name)
      Timeout.timeout(Capybara.default_max_wait_time) do
        sleep 0.1 until SHARED_PATH.join(download_name).exist?
      end
      @latest = download_name
      @history << @latest
    end
    self
  end

  def latest_downloaded_content
    return nil if @latest.nil?
    SHARED_PATH.join(@latest).read
  end

  def self.clear
    Dir[SHARED_PATH.join("*")].each do |file|
      FileUtils.rm_f(file)
    end
  end
end