resetToken = () ->
    Template.instance().data.params._id

showError = (title, message) ->
    Template.errorTemplate.showError title, message,
    $('#resetErrorContainer').get(0)
    return false

showSuccess = (title, message) ->
    Template.successTemplate.showSuccess title, message,
    $('#resetSuccessContainer').get(0)
    return false

Template.resetpassword.events
    'submit #new-password' : (e, t) ->
        e.preventDefault()

        Template.errorTemplate.resetError()
        Template.successTemplate.resetSuccess()

        password = $("#new-password-password").val()
        if not password.length
            showError "Reseting password failed!", "You have to type in new
            password."
            return false

        Accounts.resetPassword resetToken(), password, (err) ->
            if err
                showError "Reseting password failed!", "Sorry, an error occurred
                while trying to reset your password"
            else
                showSuccess "Password successfuly changed!", ""

        return false
