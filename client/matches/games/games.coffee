getPlayerData = (board, block) ->
    selectedTeam = 'teamAId'
    selectedTeam = 'teamBId' if block == 'b'

    matchId = Template.instance().data.params._id
    match = Matches.findOne matchId
    return null if not match?

    board = Boards.findOne
        board: board.toString()
        matchId: matchId
        teamId: match[selectedTeam]
    return null if not board?

    Meteor.users.findOne board.playerId

getThisMatchData = () ->
    matchId = Template.instance().data.params._id
    Matches.findOne matchId

Template.games.helpers
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
    playerName: (board, block) ->
        playerData = getPlayerData board, block
        return null if not playerData?

        return playerData.profile.nick81Dojo
    matchDate: (board) ->
        emptyDateMessage = "tbd"
        match = getThisMatchData()
        return emptyDateMessage if not match?
        board = Boards.findOne
            board: board.toString()
            matchId: match._id
        return emptyDateMessage if not board? or not board?.matchDate?

        return moment(board.matchDate).format('MMMM Do, HH:mm')
