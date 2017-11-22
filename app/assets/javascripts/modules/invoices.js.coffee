
app = window.App ||= {}

app.Invoices = {
  toggle: (e) ->
    checked = e.target.checked
    table = $(e.target).closest('table[data-checkable]')
    table.find('tbody :checkbox').prop('checked', checked)

  submit: (e) ->
    e.preventDefault()
    form = $(e.target).closest('form')
    form.append('<input name="_method" value="' + $(e.target).data('method') + '" type="hidden" />')
    form.submit()

  recalculate: (e) ->
    form = $(e.target).closest('form')
    $.ajax(url: "#{form.attr('action')}/new?#{form.serialize()}", dataType: 'script')

  buildPdfExportLink: (e) ->
    invoiceIds = []
    checkedBoxes = $('tbody :checked')
    for cb in checkedBoxes
      invoiceIds.push($(cb).attr('value'))

    href = $(e.target).attr('href')
    separator = if href.indexOf('?') != -1 then '&' else '?'
    param = separator + 'invoice_ids=' + invoiceIds
    $(e.target).attr('href',  href + param)


}

$(document).on('click', '.dropdown-menu li a', app.Invoices.buildPdfExportLink)
$(document).on('click', 'table[data-checkable] thead :checkbox', app.Invoices.toggle)
$(document).on('click', 'form[data-checkable] button[type=submit]', app.Invoices.submit)
$(document).on('change', '#invoice_items_fields :input', app.Invoices.recalculate)
$(document).on('nested:fieldRemoved:invoice_items', 'form', app.Invoices.recalculate)
