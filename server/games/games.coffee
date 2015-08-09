Meteor.methods
    postGameResult: (matchId, board, winnerBlock, winByDefault, gameLink) ->
        # Check access rights
        if not isAdmin
            playerIds = Boards.find(
                { matchId: matchId, board: board.toString() }
            ).map (document, index, cursor) ->
                return document.playerId

            # only admin or player involved in match can post result
            if playerIds.indexOf Meteor.userId() == -1
                throw new Meteor.Error "not-authorized"

        # Get match data
        match = Matches.findOne matchId
        throw new Meteor.Error "no-such-match" if not match?

        winTeam = 'teamAId'
        loseTeam = 'teamBId'
        if winnerBlock == 'b'
            winTeam = 'teamBId'
            loseTeam = 'teamAId'

        # Find board of the winner
        winnerBoardId = Boards.findOne({
            board: board.toString()
            matchId: matchId
            teamId: match[winTeam]
        }, { fields: { _id: 1 } })._id

        throw new Meteor.Error "no-such-board" if not winnerBoardId?

        # Find board of the loser
        loserBoardId = Boards.findOne({
            board: board.toString()
            matchId: matchId
            teamId: match[loseTeam]
        }, { fields: { _id: 1 } })._id

        throw new Meteor.Error "no-such-board" if not loserBoardId?

        gameLink = '' if winByDefault

        updatePoints loserBoardId, winnerBoardId, false

        # Update data for winner
        Boards.update winnerBoardId, {
            $set:
                win: true
                winByDefault: winByDefault
                linkToGame: gameLink
        }

        # Update data for loser
        Boards.update loserBoardId, {
            $set:
                win: false
                winByDefault: winByDefault
                linkToGame: gameLink
        }

        updatePoints winnerBoardId, loserBoardId
