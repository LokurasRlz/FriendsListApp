# app/models/tool.rb

class Tool < ApplicationRecord
	LOCATION_OPTIONS = [
	  'Galpon',
	  'Pozo',
	  'En inspeccion',
	  'Reparacion Interna',
	  'Reparacion Externa',
	  'Desechada'
	].freeze

	belongs_to :user
	has_many :events
	
	# Add the attributes
	attribute :id_tool, :string
	attribute :precinto, :string
	attribute :date_of_use, :date
	attribute :date_due_to, :date
	attribute :days_left, :integer
	attribute :state, :string
	attribute :clase, :string
	attribute :pin, :string
	attribute :box, :string
	attribute :link_to_pdf, :string
	attribute :location, :string
	
	before_save :set_date_due_to, if: :should_set_date_due_to?

	def can_update_date_of_use?
		true
	  end
	
	  def update_date_of_use(new_date)
		self.date_of_use = new_date
		set_date_due_to
		save
	  end

	def location_option
	  return 'Pozo' if location.to_s.start_with?('Pozo ')
	  return location if LOCATION_OPTIONS.include?(location)

	  nil
	end

	def location_detail
	  return location.to_s.delete_prefix('Pozo ').strip if location.to_s.start_with?('Pozo ')

	  ''
	end
  
	private

	def should_set_date_due_to?
	  date_of_use.present? && will_save_change_to_date_of_use? && !will_save_change_to_date_due_to?
	end
  
	def set_date_due_to
	  self.date_due_to = (date_of_use + 6.months) if date_of_use.present?
	end
  end
