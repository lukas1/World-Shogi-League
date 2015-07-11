Template.userlist.helpers
    users: ->
        Meteor.users.find()
    canSeeTemplate: ->
        isAdminOrHead
