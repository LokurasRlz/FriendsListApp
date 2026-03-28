module ApplicationHelper # rubocop:todo Layout/EndOfLine
  require 'base64'

  def qr_code_png_data(url, size: 220)
    qr = RQRCode::QRCode.new(url)
    png = qr.as_png(
      size: size,
      border_modules: 1,
      color: 'black',
      fill: 'white'
    )

    "data:image/png;base64,#{Base64.strict_encode64(png.to_s)}"
  end
end
