# Server code
Meteor.startup () ->
    if DefAdminAccount?
        for defUser in DefAdminAccount
            if Meteor.users.findOne({ emails: { $elemMatch: { address: defUser.email } } })?
                continue
            options =
                username: defUser.username
                email: defUser.email
                password: defUser.password

            Accounts.createUser(options)

Meteor.publish "teams",  () ->
    return Teams.find();

Meteor.publish "matches", () ->
    return Matches.find();
