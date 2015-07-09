showError = (message) ->
    $('.registration-failed').remove()
    Blaze.renderWithData Template.errorTemplate,
        {title: "Registration failed", message: message},
        $('#errorMessageContainer').get(0)

isValidPassword = (val) ->
   return val.length >= 6 ? true : false

Template.registration.onRendered () ->
    $('#account-picture-uploaded').hide()

    $('#account-picture-uploaded').click () ->
        if confirm("Do you really want to delete this picture?")
            $(this).attr('src', '')
            $(this).hide()

    $('#account-profilePic').change (event, numFiles, label) ->
        $('#uploadpic-form').submit()

    $('#create-account').click ()->
        $('#register-form').submit()

Template.registration.events
    'submit #uploadpic-form' : (e, t) ->
        e.preventDefault()

        file = $("#account-profilePic").get(0).files[0]
        reader = new FileReader()
        reader.onload = (e) ->
            $('#account-picture-uploaded')
                .attr('src', e.target.result)
                .show()
            ;

        reader.readAsDataURL(file)
        return false

    'submit #register-form' : (e, t) ->
        e.preventDefault()
        Template.errorTemplate.resetError()

        email = $.trim($('#account-email').val())
        nick81Dojo = $.trim($('#account-81dojo').val())
        password = $.trim($('#account-password').val())
        passwordRepeat = $.trim($('#account-password-repeat').val())
        teamId = $('#blockTeam').val()

        if not email?.length
            showError "Please type your email address"
            return false

        if not nick81Dojo?.length
            showError "Please specify your 81dojo.com nickname"
            return false

        if not teamId?.length
            showError "Please select country you represent"
            return false

        if !isValidPassword(password)
            showError "Password is too short"
            return false

        if password != passwordRepeat
            showError "Passwords don't match"
            return false

        regOptions =
            email: email,
            password: password,
            profile:
                profilePic: $('#account-picture-uploaded').attr('src')
                nick81Dojo: nick81Dojo
                teamId: teamId
        ###
        Accounts.createUser regOptions, (err) ->
            if err
                showError()
                return
            else
                # Success. Account has been created and the user
                # has logged in successfully.
                Router.go('/')
        ###
        return false
