showError = (type, title, message) ->
    errorContainer = $('#pictureMessage').get(0) if type == "picture"
    errorContainer = $('#profileMessage').get(0) if type == "profile"
    errorContainer = $('#passwordMessage').get(0) if type == "password"
    Template.errorTemplate.showError title, message,
    errorContainer
    return false

showSuccess = (type, title, message) ->
    successContainer = $('#pictureMessage').get(0) if type == "picture"
    successContainer = $('#profileMessage').get(0) if type == "profile"
    successContainer = $('#passwordMessage').get(0) if type == "password"
    Template.successTemplate.showSuccess title, message,
    successContainer
    return false

Template.updateuser.events
    'submit #uploadpic-form' : (e, t) ->
        e.preventDefault()
        return false if not Meteor.userId()
        Template.errorTemplate.resetError()
        Template.successTemplate.resetSuccess()

        file = $("#account-profilePic").get(0).files[0]
        return false if not file?

        if file.size > 1300000 # 1.3 MB
            showError "picture", "Uploading profile picture failed!",
            "Uploaded file is too big. Please upload a file with size
            under 1.3MB"
            return false

        reader = new FileReader()
        reader.onload = (e) ->
            if not reader.result?.length || reader.result.indexOf('image') == -1
                showError "picture", "Uploading profile picture failed!",
                "Uploaded file is not an image"
                return false

            profile = Meteor.user()?.profile
            profile = {} if not profile?
            profile.profilePic = e.target.result

            Meteor.call "updateProfile", Meteor.userId(), profile, (error) ->
                return showError 'picture', 'Updating profile picture failed!',
                error.reason if error

                $('#account-picture-uploaded')
                    .attr('src', e.target.result)
                    .show()
                ;

                showSuccess 'picture', 'Profile picture successfully updated!'

        reader.readAsDataURL(file)
        return false

    "submit #update-profile-form": (event, template) ->
        return false if not Meteor.userId()
        event.preventDefault()
        Template.errorTemplate.resetError()
        Template.successTemplate.resetSuccess()

        nick81Dojo = template.$('#current81Dojo').val()
        teamId = $('#classTeam').val()

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
    if Meteor.user().profile?.profilePic?.length
        $('#account-picture-uploaded').attr 'src',
        Meteor.user().profile.profilePic
    else
        $('#account-picture-uploaded').attr 'src',
        '/images/default-profile-pic.png'

    $('#account-picture-uploaded').click () ->
        return false if not Meteor.userId()
        return false if not Meteor.user().profile?.profilePic?.length

        if confirm("Do you really want to delete your profile picture?")
            profile = Meteor.user().profile
            profile.profilePic = null

            Meteor.call "updateProfile", Meteor.userId(), profile, (error) ->
                return showError 'picture', 'Removing profile picture failed!',
                error.reason if error

                showSuccess 'picture', 'Profile picture deleted!'
                $('#account-picture-uploaded').attr 'src',
                '/images/default-profile-pic.png'

    $('#account-profilePic').change (event, numFiles, label) ->
        $('#uploadpic-form').submit()
