#= require spree/backend/number_field_updater

class CountUpdateForms
  @beginListening: (isReceiving) ->
    # Edit
    $('body').on 'click', '#listing_transfer_items [data-action="edit"]', (ev) =>
      ev.preventDefault()
      transferItemId = $(ev.currentTarget).data('id')
      Spree.NumberFieldUpdater.hideReadOnly(transferItemId)
      Spree.NumberFieldUpdater.showForm(transferItemId)

    # Cancel
    $('body').on 'click', '#listing_transfer_items [data-action="cancel"]', (ev) =>
      ev.preventDefault()
      transferItemId = $(ev.currentTarget).data('id')
      Spree.NumberFieldUpdater.hideForm(transferItemId)
      Spree.NumberFieldUpdater.showReadOnly(transferItemId)

    # Submit
    $('body').on 'click', '#listing_transfer_items [data-action="save"]', (ev) =>
      ev.preventDefault()
      transferItemId = $(ev.currentTarget).data('id')
      stockTransferNumber = $("#stock_transfer_number").val()
      quantity = parseInt($("#number-update-#{transferItemId} input[type='number']").val(), 10)

      itemAttributes =
        id: transferItemId
        stockTransferNumber: stockTransferNumber
      quantityKey = if isReceiving then 'receivedQuantity' else 'expectedQuantity'
      itemAttributes[quantityKey] = quantity
      transferItem = new Spree.TransferItem(itemAttributes)
      transferItem.update(successHandler, errorHandler)

    # Discard
    $('body').on 'click', '#listing_transfer_items [data-action="reject"]', (ev) =>
      ev.preventDefault()
      modal = $("##{ev.target.dataset.target}")
      submitBtn = modal.find(".btn-primary")
      submitBtn.attr("data-transfer-item-id", ev.target.dataset.id)
      modal.modal()

    # Reject
    $('body').on 'click', '[data-action="reject-item"]', (ev) =>
      ev.preventDefault()
      rejectionReason = $("#rejection_reason").val()
      stockTransferNumber = $("#stock_transfer_number").val()
      $("#reject-transfer-items").modal("hide")
      itemAttributes =
        id: ev.target.dataset.transferItemId
        stockTransferNumber: stockTransferNumber
        rejectionReason: rejectionReason
      transferItem = new Spree.TransferItem(itemAttributes)
      transferItem.reject(successDiscardHandler, errorHandler)



  successHandler = (transferItem) =>
    if $('#received-transfer-items').length > 0
      Spree.NumberFieldUpdater.successHandler(transferItem.id, transferItem.received_quantity)
      Spree.StockTransfers.ReceivedCounter.updateTotal()
    else
      Spree.NumberFieldUpdater.successHandler(transferItem.id, transferItem.expected_quantity)
    show_flash("success", Spree.translations.updated_successfully)

  successDiscardHandler = (transferItem) =>
    Spree.NumberFieldUpdater.successDiscardHandler(transferItem.id, transferItem.expected_quantity)
    Spree.StockTransfers.ReceivedCounter.updateTotal()
    show_flash("success", Spree.translations.updated_successfully)

  errorHandler = (errorData) =>
    show_flash("error", errorData.responseText)

Spree.StockTransfers ?= {}
Spree.StockTransfers.CountUpdateForms = CountUpdateForms
