Meteor.methods
    updateTeam: (teamId, data) ->
        throw new Meteor.Error "not-authorized" if not isAdmin()

        Teams.update teamId, data
