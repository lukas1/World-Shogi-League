showError = (title, message) ->
    Blaze.renderWithData Template.errorTemplate,
        {title: title, message: message},
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
        return false if not file?

        if file.size > 5000000 # 5 MB
            showError "Uploading profile picture failed!",
            "Uploaded file is too big too big. Please upload a file with size
            under 5MB"
            return false

        reader = new FileReader()
        reader.onload = (e) ->
            if not reader.result?.length || reader.result.indexOf('image') == -1
                showError "Uploading profile picture failed!",
                "Uploaded file is not image"
                return false
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
            showError "Registration failed!", "Please type your email address"
            return false

        if not nick81Dojo?.length
            showError "Registration failed!",
            "Please specify your 81dojo.com nickname"
            return false

        if not teamId?.length
            showError "Registration failed!",
            "Please select which country you represent"
            return false

        if !isValidPassword(password)
            showError "Registration failed!",
            "Password is too short"
            return false

        if password != passwordRepeat
            showError "Registration failed!",
            "Passwords don't match"
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
