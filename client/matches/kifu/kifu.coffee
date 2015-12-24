getThisMatchId = () ->
    Template.instance().data.params._id

getBoardData = (board, block) ->
    selectedTeam = 'teamAId'
    selectedTeam = 'teamBId' if block == 'b'

    matchId = getThisMatchId()
    match = Matches.findOne matchId
    return null if not match?

    return Boards.findOne
        board: board.toString()
        matchId: matchId
        teamId: match[selectedTeam]

getPlayerData = (board, block) ->
    board = getBoardData board, block
    return null if not board?

    Meteor.users.findOne board.playerId

getPlayerName = (board, block) ->
    playerData = getPlayerData board, block
    return null if not playerData?

    return playerData.profile.nick81Dojo

getThisMatchData = () ->
    matchId = getThisMatchId()
    Matches.findOne matchId

getKifuForBoard = (board) ->
    matchId = getThisMatchId()
    return null if not matchId?
    board = Boards.findOne
        board: board.toString()
        matchId: matchId

    return null if not board?
    return Kifu.findOne board.kifu

Template.kifu.helpers
    isAdmin: ->
        return isAdmin()
    boards: ->
        boards = []
        for board in [1..BOARDS_COUNT]
            boards.push {board: board}
        return boards
    teamAData: ->
        match = getThisMatchData()
        return null if not match?

        Teams.findOne match.teamAId
    teamBData: ->
        match = getThisMatchData()
        return null if not match?

        Teams.findOne match.teamBId
    playerName: getPlayerName

    winner: (board, block) ->
        board = getBoardData board, block
        return false if not board?

        return board?.win

    matchDate: (board) ->
        emptyDateMessage = "tbd"
        match = getThisMatchData()
        return emptyDateMessage if not match?
        board = Boards.findOne
            board: board.toString()
            matchId: match._id
        return emptyDateMessage if not board? or not board?.matchDate?

        return moment(board.matchDate).format('MMMM Do, HH:mm')
    kifuForBoard: (board) ->
        return getKifuForBoard board
