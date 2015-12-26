Meteor.methods
    removeMatch: (matchId) ->
        throw new Meteor.Error "not-authorized" if not isAdmin()

        # Validate input
        throw new Meteor.Error "bad-input" if not matchId?.length

        Boards.removeMatchBoards matchId
        Matches.remove matchId
