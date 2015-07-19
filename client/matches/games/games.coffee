showError = (title, message) ->
    Template.errorTemplate.showError title, message,
    $('#errorMessageContainer').get(0)
    return false

clearPostResultForm = (tpl, winByDefault) ->
    tpl.$('#teamAWin, #teamBWin').prop 'checked', false
    tpl.$('#teamAPlayer').text ''
    tpl.$('#teamBPlayer').text ''
    tpl.$('#boardNumber').val ''
    tpl.$('#gameLink').val ''
    if winByDefault
        tpl.$('#winByDefault').prop 'checked', false
        tpl.$('#winByDefault').trigger 'change'

    tpl.$('#postResultModal').modal('hide')

getThisMatchId = () ->
    Template.instance().data.params._id

getPlayerData = (board, block) ->
    selectedTeam = 'teamAId'
    selectedTeam = 'teamBId' if block == 'b'

    matchId = getThisMatchId()
    match = Matches.findOne matchId
    return null if not match?

    board = Boards.findOne
        board: board.toString()
        matchId: matchId
        teamId: match[selectedTeam]
    return null if not board?

    Meteor.users.findOne board.playerId

getPlayerName = (board, block) ->
    playerData = getPlayerData board, block
    return null if not playerData?

    return playerData.profile.nick81Dojo

getThisMatchData = () ->
    matchId = getThisMatchId()
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
    playerName: getPlayerName

    matchDate: (board) ->
        emptyDateMessage = "tbd"
        match = getThisMatchData()
        return emptyDateMessage if not match?
        board = Boards.findOne
            board: board.toString()
            matchId: match._id
        return emptyDateMessage if not board? or not board?.matchDate?

        return moment(board.matchDate).format('MMMM Do, HH:mm')
    gameNotFinished: (board) ->
        match = getThisMatchData()
        return false if not match?
        board = Boards.findOne
            board: board.toString()
            matchId: match._id
        return false if not board?
        return not board.isFinished

Template.games.events
    "click .postResult": (e, tpl) ->
        e.preventDefault()
        Template.errorTemplate.resetError()

        clearPostResultForm tpl, tpl.$('#winByDefault').is(':checked')

        elementId = $(e.target).attr 'id'
        board = elementId.replace 'postResult', ''
        tpl.$('#boardNumber').val(board)

        # Fill player names
        teamAPlayer = getPlayerName board, 'a'
        teamBPlayer = getPlayerName board, 'b'
        tpl.$('#teamAPlayer').text(teamAPlayer)
        tpl.$('#teamBPlayer').text(teamBPlayer)
        tpl.$('#postResultModal').modal()

    "click #teamAPlayer": (e, tpl) ->
        tpl.$('#teamAWin').prop 'checked', true

    "click #teamBPlayer": (e, tpl) ->
        tpl.$('#teamBWin').prop 'checked', true

    "change #winByDefault": (e, tpl) ->
        tpl.$('#gameLinkContainer').toggleClass('hidden')

    "submit #postResultForm": (e, tpl) ->
        e.preventDefault()
        Template.errorTemplate.resetError()
        errorTitle = "Posting result failed!"

        board = tpl.$('#boardNumber').val()
        gameLink = tpl.$('#gameLink').val()
        winByDefault = tpl.$('#winByDefault').is(':checked')
        teamAWin = tpl.$('#teamAWin').is(':checked')
        teamBWin = tpl.$('#teamBWin').is(':checked')

        if not board?.length
            return showError errorTitle, "Internal error. Please close this
            modal window and try posting result again. If the problem persist,
            please contact the administrator"

        if teamAWin == teamBWin
            return showError errorTitle, "Pick a winner of this match"

        if not winByDefault and not gameLink?.length
            return showError errorTitle, "Please post link to the game record"

        winnerBlock = 'a'
        winnerBlock = 'b' if teamBWin

        Meteor.call "postGameResult", getThisMatchId(), board, winnerBlock,
        winByDefault, (error, result) ->
            if error
                return showError errorTitle, error.reason

            # Clear form
            clearPostResultForm tpl, winByDefault

        return false
