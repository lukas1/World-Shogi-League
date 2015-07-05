showError = (message) ->
    $('.change-password-info').remove();
    $('#update-form').prepend(
        '<div class="alert alert-danger change-password-info">' +
            '<a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>' +
            '<strong>Changing password failed!</strong> ' + message +
        '</div>'
    );
    $('.change-password-info').fadeIn(100);

showSuccess = () ->
    $('.change-password-info').remove();
    $('#update-form').prepend(
        '<div class="alert alert-success change-password-info">' +
            '<a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>' +
            '<strong>Password successfully changed!</strong> '
        '</div>'
    );
    $('.change-password-info').fadeIn(100);

Template.updateuser.events
    "submit #update-form": (event, template) ->
        event.preventDefault()
        $('.change-password-info').remove();

        oldPassword = template.$('#currentPassword').val()
        newPassword = template.$('#newPassword').val()
        newPasswordRepeat = template.$('#newPasswordRepeat').val()

        return showError 'Please type in your current password' if not oldPassword?.length
        return showError 'Please type in new password' if not newPassword?.length
        return showError 'Please repeat the new password' if not newPasswordRepeat?.length
        return showError 'New passwords are not matching' if newPassword != newPasswordRepeat

        Accounts.changePassword oldPassword, newPassword, (error) ->
            if error
                showError error.reason
                return;

            template.$('#currentPassword').val('')
            template.$('#newPassword').val('')
            template.$('#newPasswordRepeat').val('')
            showSuccess();

Template.updateuser.onRendered () ->
    $('#currentPassword').focus()
