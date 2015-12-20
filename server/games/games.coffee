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
        winnerBoard = Boards.findOne
            board: board.toString()
            matchId: matchId
            teamId: match[winTeam]

        throw new Meteor.Error "no-such-board" if not winnerBoard?

        # Find board of the loser
        loserBoard = Boards.findOne
            board: board.toString()
            matchId: matchId
            teamId: match[loseTeam]

        throw new Meteor.Error "no-such-board" if not loserBoard?

        gameLink = '' if winByDefault

        if winnerBoard.win? and winnerBoard.win
            updatePoints winnerBoard._id, loserBoard._id, false
        else
            updatePoints loserBoard._id, winnerBoard._id, false

        # Update data for winner
        Boards.update winnerBoard._id, {
            $set:
                win: true
                winByDefault: winByDefault
                linkToGame: gameLink
        }

        # Update data for loser
        Boards.update loserBoard._id, {
            $set:
                win: false
                winByDefault: winByDefault
                linkToGame: gameLink
        }

        updatePoints winnerBoard._id, loserBoard._id

    postKifu: (matchId, board, kifu) ->
        # Check access rights
        throw new Meteor.Error "not-authorized" if not isAdmin

        # Find board ids of this match and board number
        boardIds = Boards.find({ matchId: matchId, board: board.toString() },
            fields:
                _id: 1
        ).map (document, index, cursor) ->
            return document._id

        kifuRecord =
            boards: boardIds
            kifu: kifu
        kifuId = Kifu.insert kifuRecord

        for boardId in boardIds
            Boards.update boardId,
                $set:
                    kifu: kifuId

        return false

    removeKifu: (matchId, board) ->
        # Check access rights
        throw new Meteor.Error "not-authorized" if not isAdmin

        boardFilter =
            board: board.toString()
            matchId: matchId
        boards = Boards.find().fetch()

        kifuId = null

        for boardData in boards
            kifuId = boardData.kifu
            Boards.update boardData._id,
                $set:
                    kifu: null

        Kifu.remove kifuId
