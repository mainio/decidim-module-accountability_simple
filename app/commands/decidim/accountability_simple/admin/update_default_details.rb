# frozen_string_literal: true

module Decidim
  module AccountabilitySimple
    module Admin
      # This command is executed when the user changes a default detail from the
      # admin panel.
      class UpdateDefaultDetails < Decidim::Command
        # Initializes an UpdateResult Command.
        #
        # form - The form from which to get the data.
        def initialize(form)
          @form = form
        end

        # Updates the result if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?

          transaction do
            update_details
          end

          broadcast(:ok)
        end

        private

        attr_reader :result, :form

        def update_details
          @form.details.each do |form_detail|
            update_detail(form_detail)
          end
        end

        def update_detail(form_detail)
          detail_attributes = {
            title: form_detail.title,
            icon: form_detail.icon,
            position: form_detail.position,
            accountability_result_detailable: @form.current_component
          }

          record = Decidim::AccountabilitySimple::ResultDetail.find_by(
            accountability_result_detailable: @form.current_component,
            id: form_detail.id
          ) || Decidim::AccountabilitySimple::ResultDetail.new(detail_attributes)

          if record.persisted?
            if form_detail.deleted?
              record.destroy!
            else
              record.update!(detail_attributes)
            end
          else
            record.save!
          end
        end
      end
    end
  end
end
