Template.userlist.helpers
    users: ->
        filter = {}
        if not isAdmin()
            filter = { 'profile.teamId': Meteor.user()?.profile?.teamId }

        Meteor.users.find(filter)
