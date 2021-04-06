module Spree
  module Api
    class TransferItemsController < Spree::Api::BaseController
      helper 'solidus_stock_transfers/api'

      def create
        authorize! :create, TransferItem
        stock_transfer = Spree::StockTransfer.accessible_by(current_ability, :update).find_by(number: params[:stock_transfer_id])
        @transfer_item = stock_transfer.transfer_items.build(transfer_item_params)
        if @transfer_item.save
          respond_with(@transfer_item, status: 201, default_template: :show)
        else
          invalid_resource!(@transfer_item)
        end
      end

      def update
        authorize! :update, TransferItem
        @transfer_item = Spree::TransferItem.accessible_by(current_ability, :update).find(params[:id])
        if @transfer_item.update_attributes(transfer_item_params)
          respond_with(@transfer_item, status: 200, default_template: :show)
        else
          invalid_resource!(@transfer_item)
        end
      end

      def destroy
        authorize! :destroy, TransferItem
        @transfer_item = Spree::TransferItem.accessible_by(current_ability, :destroy).find(params[:id])
        if @transfer_item.destroy
          respond_with(@transfer_item, status: 200, default_template: :show)
        else
          invalid_resource!(@transfer_item)
        end
      end

      private

      def transfer_item_params
        params.require(:transfer_item).permit(permitted_transfer_item_attributes)
      end

      def permitted_transfer_item_attributes
        [:variant_id, :expected_quantity, :received_quantity, :rejection_reason]
      end
    end
  end
end
