showError = (title, message) ->
    Template.errorTemplate.showError title, message,
    $('#errorMessageContainer').get(0)

boardData = () ->
    try
        matchId = getMatchIdForPlayer Template.instance().data._id
        Boards.findOne
            playerId: Template.instance().data._id
            matchId: matchId
    catch error
        return null

Template.userline.helpers
    profilePic: ->
        profilePic = Template.instance().data.profile?.profilePic
        profilePic = "/images/default-profile-pic.png" if not profilePic?.length
        return profilePic
    nick81Dojo: ->
        nick81Dojo = Template.instance().data.profile?.nick81Dojo
        nick81Dojo = "unknown" if not nick81Dojo?.length
        return nick81Dojo
    teamName: ->
        country = Teams.findOne(Template.instance().data.profile?.teamId)?.name
        country = "unknown" if not country?.length
        return country
    teamCountryCode: ->
        Teams.findOne(Template.instance().data.profile?.teamId)?.countryCode
    isAdmin: ->
        isAdmin()
    isAdminOrHead: ->
        isAdminOrHead()
    userIsAdmin: ->
        userId = Template.instance().data._id
        userType = Meteor.users.findOne(userId)?.profile?.userType
        return userType == USER_TYPE_ADMIN
    userIsHead: ->
        userId = Template.instance().data._id
        userType = Meteor.users.findOne(userId)?.profile?.userType
        return userType == USER_TYPE_HEAD
    boardData: boardData
    gameFinished: ->
        board = boardData()
        return null if not board?
        return board.win?
    isOpenMatch: ->
        roundData = lastRound()
        return false if not roundData?

        return false if roundData.finished

        try
            matchId = getMatchIdForPlayer Template.instance().data._id

            return false if not matchId?.length
        catch error
            return false

        return true
    rounds: ->
        # Along with rounds pass name of opposing team and matchId
        playerId = Template.instance().data._id
        playerData = Meteor.users.findOne playerId
        return Rounds.find(
            {}, { sort: { roundNumber: 1 } }
        ).map (document, index, cursor) ->
            matchId = getMatchIdForPlayerAndRound playerId, document._id
            matchData = Matches.findOne matchId
            opponentTeamId = ""

            if matchData.teamAId == playerData.profile.teamId
                opponentTeamId = matchData.teamBId
            if matchData.teamBId == playerData.profile.teamId
                opponentTeamId = matchData.teamAId

            document.matchId = matchId
            document.opponentTeam = Teams.findOne(opponentTeamId).name
            return document

Template.userline.events
    "click .delete": (e, tpl) ->
        e.preventDefault()
        if confirm "Do you really want to remove this user?
        This action cannot be reversed"
            Meteor.call "removeUser", tpl.data._id, (error) ->
                if error
                    return showError "Removing user failed!", error.reason

    "click .makeAdmin": (e, tpl) ->
        e.preventDefault()
        if confirm "Do you really want to make this user an admin?"
            Meteor.call "makeAdmin", tpl.data._id, (error) ->
                if error
                    return showError "Can't make user an admin!", error.reason
    "click .makeHead": (e, tpl) ->
        e.preventDefault()
        if confirm "Do you really want to make this user a team head?"
            Meteor.call "makeHead", tpl.data._id, (error) ->
                if error
                    return showError "Can't make user a team head!",
                    error.reason
    "click .unHead": (e, tpl) ->
        e.preventDefault()
        if confirm "Do you really want to kick this user from team head post?"
            Meteor.call "unHead", tpl.data._id, (error) ->
                if error
                    return showError "Can't kick user from team head position!",
                    error.reason
    "click .addToMatch": (e, tpl) ->
        e.preventDefault()
        $('#roundSelect').empty()
        roundsFeed = $(e.target)
            .closest('.addToMatchCell')
            .find('.roundsFeed').text()

        for roundData in roundsFeed.split(';')
            roundData = $.trim roundData
            continue if not !!roundData

            roundFields = roundData.split '-'
            $('#roundSelect').append '<option value="' + roundFields[0] + '">' +
                    'Round ' + roundFields[1] + ' - ' + roundFields[2] +
                '</option>'

        $('#boardSelectPlayerId').val tpl.data._id
        $('#addToMatchModal').modal()

    "click .removeFromMatch": (e, tpl) ->
        e.preventDefault()
        if not confirm "Do you really want to remove this player from the
        match?"
            return false
        buttonId = $(e.target).attr('id')
        boardId = buttonId.replace('removeFromBoard', '')
        if not boardId?.length
            return showError "Unable to remove player from match."

        Meteor.call "removePlayerFromMatch", boardId, (error) ->
            return showError "Unable to remove player from match." if error
