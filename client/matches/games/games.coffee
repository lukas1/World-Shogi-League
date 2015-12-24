showError = (title, message, kifu) ->
    containerPrefix = 'e'
    containerPrefix = 'kifuE' if kifu
    Template.errorTemplate.showError title, message,
    $('#' + containerPrefix + 'rrorMessageContainer').get(0)
    return false

clearPostResultForm = (tpl, winByDefault) ->
    tpl.$('#teamAWin, #teamBWin').prop 'checked', false
    tpl.$('#modalHeader').text ''
    tpl.$('#teamAPlayer').text ''
    tpl.$('#teamBPlayer').text ''
    tpl.$('#boardNumber').val ''
    tpl.$('#gameLink').val ''
    tpl.$('#modalSubmit').val ''
    if winByDefault
        tpl.$('#winByDefault').prop 'checked', false
        tpl.$('#winByDefault').trigger 'change'

    tpl.$('#postResultModal').modal('hide')

clearPostKifuForm = (tpl) ->
    tpl.$('#kifuBoardNumber').val ''
    tpl.$('#kifuFile').val ''
    tpl.$('#postKifuModal').modal('hide')

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

removeKifu = (board) ->
    return false if not isAdmin()
    Meteor.call "removeKifu", getThisMatchId(), board, (error, result) ->
        return showError errorTitle, error.reason, true if error

prepareModal = (e, tpl, modalType) ->
    e.preventDefault()
    return false if modalType != 'post' and modalType != 'edit'
    Template.errorTemplate.resetError()

    clearPostResultForm tpl, tpl.$('#winByDefault').is(':checked')

    if modalType == 'post'
        replaceId = 'postResult'
        tpl.$('#modalHeader').text 'Post result'
        tpl.$('#modalSubmit').val 'Post result'
    else if modalType == 'edit'
        replaceId = 'editResult'
        tpl.$('#modalHeader').text 'Edit result'
        tpl.$('#modalSubmit').val 'Edit result'

    elementId = $(e.target).attr 'id'
    board = elementId.replace replaceId, ''
    tpl.$('#boardNumber').val board

    if modalType == 'edit'
        boardData = getBoardData board, 'a'
        tpl.$('#teamAWin').prop 'checked', boardData?.win
        tpl.$('#teamBWin').prop 'checked', not boardData?.win
        tpl.$('#gameLink').val boardData?.linkToGame

        if boardData?.winByDefault
            tpl.$('#winByDefault').prop 'checked', true
            tpl.$('#winByDefault').trigger 'change'

    # Fill player names
    teamAPlayer = getPlayerName board, 'a'
    teamBPlayer = getPlayerName board, 'b'
    tpl.$('#teamAPlayer').text teamAPlayer
    tpl.$('#teamBPlayer').text teamBPlayer
    tpl.$('#postResultModal').modal()

prepareKifuModal = (e, tpl) ->
    e.preventDefault()
    Template.errorTemplate.resetError()

    clearPostKifuForm tpl

    elementId = $(e.target).attr 'id'
    board = elementId.replace 'postKifu', ''
    tpl.$('#kifuBoardNumber').val board

    tpl.$('#postKifuModal').modal()

Template.games.helpers
    isAdmin: ->
        return isAdmin()
    canUpdateResult: (board) ->
        return true if isAdmin()

        matchId = getThisMatchId()

        playerIds = Boards.find(
            { matchId: matchId, board: board.toString() }
        ).map (document, index, cursor) ->
            return document.playerId

        # only admin or player involved in match can post result
        return playerIds.indexOf(Meteor.userId()) != -1
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
    gameNotFinished: (board) ->
        match = getThisMatchData()
        return false if not match?
        board = Boards.findOne
            board: board.toString()
            matchId: match._id
        return false if not board?
        return not board.win?
    gameLink: (board) ->
        match = getThisMatchData()
        return "" if not match?
        board = Boards.findOne
            board: board.toString()
            matchId: match._id
        return "" if not board?
        return board?.linkToGame
    gameExists: (board) ->
        match = getThisMatchData()
        return false if not match?
        board = Boards.findOne
            board: board.toString()
            matchId: match._id
        return board?
    winByDefault: (board) ->
        match = getThisMatchData()
        return false if not match?
        board = Boards.findOne
            board: board.toString()
            matchId: match._id
        return false if not board?
        return board?.winByDefault
    kifuForBoard: (board) ->
        return getKifuForBoard board

Template.games.events
    "click .postResult": (e, tpl) ->
        prepareModal e, tpl, 'post'

    "click .editResult": (e, tpl) ->
        prepareModal e, tpl, 'edit'

    "click .postKifu": (e, tpl) ->
        prepareKifuModal(e, tpl)

    "click .removeKifu": (e, tpl) ->
        elementId = $(e.target).attr 'id'
        board = elementId.replace 'removeKifu', ''
        removeKifu board

    "click .kifuLink": (e, tpl) ->
        event.stopPropagation()
        elementId = $(e.target).attr 'id'
        board = elementId.replace 'kifuLink', ''
        kifu = getKifuForBoard board
        Router.go Routes.kifu.name, { _id: kifu._id }

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
        winByDefault, gameLink, (error, result) ->
            if error
                return showError errorTitle, error.reason

            # Clear form
            clearPostResultForm tpl, winByDefault

        return false

    "submit #postKifuForm": (e, tpl) ->
        e.preventDefault()
        Template.errorTemplate.resetError()
        errorTitle = "Posting kifu failed!"

        board = tpl.$('#kifuBoardNumber').val()
        if not board?.length
            return showError errorTitle, "Internal error. Please close this
            modal window and try posting kifu again. If the problem persist,
            please contact the administrator.", true

        file = $("#kifuFile").get(0).files[0]
        if not file?
            showError errorTitle, "You didn't select any file!", true
            return false

        if file.size > 1000000 # 1 MB
            showError errorTitle, "Uploaded file is too big. Please upload a
            file with size under 1 MB", true
            return false

        matchId = getThisMatchId()

        reader = new FileReader()
        reader.onload = (e) ->
            if not reader.result?.length
                showError errorTitle, "Uploaded file is empty", true
                return false

            kifu = e.target.result

            Meteor.call "postKifu", matchId, board, kifu,
            (error, result) ->
                return showError errorTitle, error.reason, true if error

                # Clear form
                clearPostKifuForm tpl

        reader.readAsDataURL(file)
        return false
