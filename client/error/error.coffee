Template.errorTemplate.resetError = ->
    $('.error-alert').remove()

Template.errorTemplate.onCreated ->
    Template.errorTemplate.resetError()
