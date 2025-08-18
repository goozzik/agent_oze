WickedPdf.config = {
  # Path to the wkhtmltopdf executable
  exe_path: Rails.env.development? ? '/usr/local/bin/wkhtmltopdf' : nil,
  
  # Global options
  page_size: 'A4',
  margin_top: '0.75in',
  margin_bottom: '0.75in', 
  margin_left: '0.75in',
  margin_right: '0.75in',
  encoding: 'UTF-8',
  
  # Use binary from gem in production
  use_xvfb: false
}

if Rails.env.development?
  # Try to find wkhtmltopdf binary
  begin
    WickedPdf.config[:exe_path] = `which wkhtmltopdf`.strip
  rescue
    # Fallback to binary from gem
    WickedPdf.config[:exe_path] = nil
  end
end