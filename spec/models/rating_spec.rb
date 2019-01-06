require 'rails_helper'

RSpec.describe Rating, type: :model do
  describe 'validations' do
    it { should validate_presence_of :title }
    it { should validate_presence_of :description }
    it { should validate_presence_of :score }
    it { should validate_presence_of :active }
  end

  describe 'relationships' do
    it { should belong_to :user }
    it { should belong_to :item }
  end
end
