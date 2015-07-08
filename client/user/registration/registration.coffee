showError = () ->
    $('.registration-failed').remove()
    $('#register-form').prepend(
        '<div class="alert alert-danger registration-failed">' +
            '<a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>' +
            '<strong>Registration failed!</strong> Empty input data' +
        '</div>'
    )
    $('.registration-failed').fadeIn(100)

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

        email = $.trim($('#account-email').val())
        nick81Dojo = $.trim($('#account-81dojo').val())
        password = $.trim($('#account-password').val())
        passwordRepeat = $.trim($('#account-password-repeat').val())

        if email.length == 0 or !isValidPassword(password)
            showError()
            return false

        if passwor != passwordRepeat
            showError()
            return false

        regOptions =
            email: email,
            password: password,
            profile:
                profilePic: $('#account-picture-uploaded').attr('src')
                nick81Dojo: nick81Dojo
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
