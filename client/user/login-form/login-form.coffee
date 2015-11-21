showError = () ->
    $('.login-failed').remove();
    $('#login-form').prepend(
        '<div class="alert alert-danger login-failed">' +
            '<a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>' +
            '<strong>Login failed!</strong> Incorrect email or password' +
        '</div>'
    );
    $('.login-failed').fadeIn(100);

showRecoveryError = () ->
    $('.recovery-failed').remove();
    $('#recovery-form').prepend(
        '<div class="alert alert-danger recovery-failed">' +
            '<a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>' +
            '<strong>Password recovery failed!</strong> Incorrect email' +
        '</div>'
    );
    $('.recovery-failed').fadeIn(100);

Template.loginform.helpers
    registration_path: () ->
        return Routes.registration.path

Template.loginform.events
    "click #recoverPassword": (event, template) ->
        $('#recoverPassword').hide()
        $('#recovery-form').show()
        $('#recovery-email').focus()
    "submit #login-form" : (event, template) ->
        # Retrieve the input field values
        email = $('#login-email').val();
        password = $('#login-password').val();
        if email.length == 0 or password.length == 0
            showError();
            return false;

        Meteor.loginWithPassword(email, password, (err) ->
            if err
                showError();
                return;
            Router.go 'home'
        );

        return false;
    "submit #recovery-form": (event, template) ->
        event.preventDefault()
        email = $('#recovery-email').val()
        if not email.length
            showRecoveryError()
            return false;

        Accounts.forgotPassword { email: email }, (err) ->
            if err
                showRecoveryError()
            else
                Template.successTemplate.showSuccess 'Email Sent!', 'Please check
                your email.',
                $('#recoverySuccessContainer').get(0)

            $('#recovery-form').find('[type=submit]').attr('disabled', true)
        return false

Template.loginform.onRendered () ->
    $('#login-email').focus()
    $('#recoverPassword').show()
    $('#recovery-form').hide()
