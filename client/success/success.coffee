Template.successTemplate.showSuccess = (title, message, containerElement) ->
    Blaze.renderWithData Template.successTemplate,
        {title: title, message: message},
        containerElement

Template.successTemplate.resetSuccess = ->
    $('.success-alert').remove()

Template.successTemplate.onCreated ->
    Template.successTemplate.resetSuccess()
