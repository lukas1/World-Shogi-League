Template.userlist.helpers
    users: ->
        Meteor.users.find()
    canSeeTemplate: ->
        userType = Meteor.user()?.profile?.userType
        return userType == 'admin' or userType == 'head'
