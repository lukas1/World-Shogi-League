Template.errorTemplate.showError = (title, message, containerElement) ->
    Blaze.renderWithData Template.errorTemplate,
        {title: title, message: message},
        containerElement

Template.errorTemplate.resetError = ->
    $('.error-alert').remove()

Template.errorTemplate.onCreated ->
    Template.errorTemplate.resetError()
