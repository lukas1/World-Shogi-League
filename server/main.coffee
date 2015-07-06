# Server code
Meteor.startup () ->
    if not Meteor.users.find().count() and DefAdminAccount?
        options =
            username: DefAdminAccount.username
            email: DefAdminAccount.email
            password: DefAdminAccount.password

        Accounts.createUser(options);

Meteor.publish "teams",  () ->
    return Teams.find();

Meteor.publish "matches", () ->
    return Matches.find();
