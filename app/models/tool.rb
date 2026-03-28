# app/models/tool.rb

class Tool < ApplicationRecord
	belongs_to :user
	
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
	
	before_save :set_date_due_to, if: :should_set_date_due_to?

	def can_update_date_of_use?
		true
	  end
	
	  def update_date_of_use(new_date)
		self.date_of_use = new_date
		set_date_due_to
		save
	  end
  
	private

	def should_set_date_due_to?
	  date_of_use.present? && will_save_change_to_date_of_use? && !will_save_change_to_date_due_to?
	end
  
	def set_date_due_to
	  self.date_due_to = (date_of_use + 6.months) if date_of_use.present?
	end
  end
