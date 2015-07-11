showError = (type, title, message) ->
    errorContainer = $('#profileMessage').get(0) if type == "profile"
    errorContainer = $('#passwordMessage').get(0) if type == "password"
    Template.errorTemplate.showError title, message,
    errorContainer
    return false

showSuccess = (type, title, message) ->
    successContainer = $('#profileMessage').get(0) if type == "profile"
    successContainer = $('#passwordMessage').get(0) if type == "password"
    Template.successTemplate.showSuccess title, message,
    successContainer
    return false

Template.updateuser.events
    "submit #update-profile-form": (event, template) ->
        return false if not Meteor.userId()
        event.preventDefault()
        Template.errorTemplate.resetError()
        Template.successTemplate.resetSuccess()

        nick81Dojo = template.$('#current81Dojo').val()
        teamId = $('#blockTeam').val()

        return showError 'profile', 'Updating profile failed!',
        'Please specify your 81dojo.com nickname' if not nick81Dojo?.length
        return showError 'profile', 'Updating profile failed!',
        "Please select which country you represent" if not teamId?.length

        profile = Meteor.user()?.profile
        profile = {} if not profile?
        profile.nick81Dojo = nick81Dojo
        profile.teamId = teamId

        Meteor.call "updateProfile", Meteor.userId(), profile, (error, result) ->
            return showError 'profile', 'Updating profile failed!',
            error.reason if error

            showSuccess 'profile', 'Profile successfully updated!'

    "submit #update-password-form": (event, template) ->
        return false if not Meteor.userId()
        event.preventDefault()
        Template.errorTemplate.resetError()
        Template.successTemplate.resetSuccess()

        oldPassword = template.$('#currentPassword').val()
        newPassword = template.$('#newPassword').val()
        newPasswordRepeat = template.$('#newPasswordRepeat').val()

        return showError 'password', 'Changing password failed!',
        'Please type in your current password' if not oldPassword?.length
        return showError 'password', 'Changing password failed!',
        'Please type in new password' if not newPassword?.length
        return showError 'password', 'Changing password failed!',
        'Please repeat the new password' if not newPasswordRepeat?.length
        return showError 'password', 'Changing password failed!',
        'New passwords are not matching' if newPassword != newPasswordRepeat

        Accounts.changePassword oldPassword, newPassword, (error) ->
            if error
                showError 'password', 'Changing password failed!', error.reason
                return;

            template.$('#currentPassword').val('')
            template.$('#newPassword').val('')
            template.$('#newPasswordRepeat').val('')
            showSuccess 'password', 'Password successfully changed!'

Template.updateuser.onRendered () ->
    $('#currentPassword').focus()
