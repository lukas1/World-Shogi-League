function showError() {
    $('.login-failed').remove();
    $('.dropdown-menu').prepend(
        '<div class="alert alert-danger login-failed">' +
            '<a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>' +
            '<strong>Login failed!</strong> Incorrect email or password' +
        '</div>'
    );
    $('.login-failed').fadeIn(100);
}

Template.loginform.helpers({
    registration_path: function() {
        return Routes.registration.path;
    }
});

Template.loginform.events({
    "submit #login-form" : function(event, template) {
        // retrieve the input field values
        var email = $('#login-email').val();
        var password = $('#login-password').val();
        if (email.length == 0 || password.length == 0) {
            showError();
            return false;
        }

        Meteor.loginWithPassword(email, password, function(err){
            if (err) {
                showError();
                return;
            }
        });

        return false;
    }
});
