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
                profile:
                    userType: USER_TYPE_ADMIN

            Accounts.createUser(options)

Meteor.publish "teams", () ->
    return Teams.find();

Meteor.publish "rounds", () ->
    return Rounds.find();

Meteor.publish "matches", () ->
    return Matches.find();

Meteor.publish "userlist", () ->
    user = Meteor.users.findOne this.userId
    userType = user?.profile?.userType
    isAdminOrHead = userType == USER_TYPE_ADMIN or userType == USER_TYPE_HEAD
    return Meteor.users.find {}, {fields: { _id:1, profile: 1 }} if isAdminOrHead
