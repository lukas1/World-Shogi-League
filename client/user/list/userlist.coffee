showError = (message) ->
    alert message
    return false

Template.userlist.helpers
    users: ->
        filter = {}
        if not isAdmin()
            filter = { 'profile.teamId': Meteor.user()?.profile?.teamId }

        Meteor.users.find(filter, {sort: {'profile.nick81Dojo': 1}})
    boards: ->
        boards = []
        for board in [1..BOARDS_COUNT]
            boards.push {board: board}
        return boards

Template.userlist.events
    "submit #addToMatchForm": (event, tpl) ->
        event.preventDefault()
        return false if not isAdminOrHead()

        playerId = $('#boardSelectPlayerId').val()
        board = $('#boardSelect').val()
        return showError "Could not add player to match. Please assign the
        player to a board" if not board?.length

        matchId = $('#roundSelect').val()
        return showError "Could not add player to match. Please select a match
        for the player" if not matchId?.length

        # Get teamId
        userData = Meteor.users.findOne playerId
        if not userData?
            return showError "Could not add player to match. Unknown player"
        teamId = userData.profile.teamId

        # Check if this board is already occupied
        # If so, ask user if he wants to change player
        thisBoard = Boards.findOne
            matchId: matchId
            teamId: teamId
            board: board

        if thisBoard?
            if thisBoard.win?
                alert "Game on this board is finished already. You can't assign
                other player to this board anymore."
                return false

            return false if not confirm "This board is already occupied by other
            player. Do you wish to replace him on this post?"

        Meteor.call "addPlayerToMatch", playerId, matchId, board,
        (error, result) ->
            if error
                return showError "Could not add player to match."
            $('#addToMatchModal').modal('hide')
            $('#roundSelect').empty()
            $('#boardSelectPlayerId').val('')
            $("#boardSelect").prop('selectedIndex', 0);

        return false

    "submit #removeFromMatchForm": (event, tpl) ->
        event.preventDefault()
        return false if not isAdminOrHead()

        playerId = $('#removeSelectPlayerId').val()

        matchId = $('#removeRoundSelect').val()
        return showError "Could not remove player from match. Please select a
        match for the player" if not matchId?.length

        if not confirm "Do you really want to remove this player from the
        match?"
            return false

        Meteor.call "removePlayerFromMatch", playerId, matchId, (error) ->
            if error
                errorMessage = "Unable to remove player from match. "
                errorMessage += error.reason
                return showError errorMessage

            $('#removeFromMatchModal').modal('hide')
            $('#removeRoundSelect').empty()
            $('#removeSelectPlayerId').val('')

        return false

    "click #removeFromAllMatches": (event, tpl) ->
        playerId = $('#removeSelectPlayerId').val()

        $('#removeRoundSelect').find('option').each((i, e) ->
            matchId = $(e).attr('value')
            Meteor.call "removePlayerFromMatch", playerId, matchId
        )

        $('#removeFromMatchModal').modal('hide')
        $('#removeRoundSelect').empty()
        $('#removeSelectPlayerId').val('')
