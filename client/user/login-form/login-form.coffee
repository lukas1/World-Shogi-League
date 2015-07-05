showError = () ->
    $('.login-failed').remove();
    $('.dropdown-menu').prepend(
        '<div class="alert alert-danger login-failed">' +
            '<a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>' +
            '<strong>Login failed!</strong> Incorrect email or password' +
        '</div>'
    );
    $('.login-failed').fadeIn(100);

Template.loginform.helpers
    registration_path: () ->
        return Routes.registration.path;

Template.loginform.events
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
        );

        return false;
