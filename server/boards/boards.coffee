Meteor.methods
    addPlayerToMatch: (userId, matchId, board) ->
        # Access rights
        throw new Meteor.Error "not-authorized" if not isAdminOrHead()

        # Check teamId. Team id of player must be the same as team id of a
        # team in the match
        userData = Meteor.users.findOne userId
        throw new Meteor.Error "user-not-found" if not userData?

        teamId = userData.profile.teamId
        matchData = Matches.findOne matchId
        if teamId != matchData.teamAId and
        teamId != matchData.teamBId
            throw new Meteor.Error "wrong-board-match"

        # Check if this player is already playing in this match
        testBoardData = Boards.findOne
            playerId: userId
            matchId: matchId

        throw new Meteor.Error "player-already-plays" if testBoardData?

        # Data to update
        boardData =
            playerId: userId
            matchId: matchId
            teamId: teamId
            board: board

        # Check if this board is already occupied
        # If so remove the record
        thisBoard = Boards.findOne
            matchId: matchId
            teamId: teamId
            board: board

        if thisBoard?
            Boards.remove thisBoard._id

        # Don't allow any more boards to be added
        allMatchBoards = Boards.find(
            {matchId: matchId, teamId: teamId}
        ).fetch()
        if allMatchBoards.length >= BOARDS_COUNT
            throw new Meteor.Error "too-many-boards"

        Boards.insert boardData

    removePlayerFromMatch: (boardId) ->
        # Access rights
        throw new Meteor.Error "not-authorized" if not isAdminOrHead()

        # Validation of parameters
        throw new Meteor.Error "boardId-empty" if not boardId?.length

        Boards.remove boardId
