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

  def due_date_text_class(date_due_to)
    return '' if date_due_to.blank?

    days_until_due = (date_due_to.to_date - Date.current).to_i

    if days_until_due <= 30
      'tool-due-soon'
    elsif days_until_due.between?(31, 90)
      'tool-due-warning'
    else
      ''
    end
  end
end
