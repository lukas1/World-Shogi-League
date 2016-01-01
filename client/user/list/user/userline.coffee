showError = (title, message) ->
    Template.errorTemplate.showError title, message,
    $('#errorMessageContainer').get(0)

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
    isAssignedToBoard: ->
        try
            boards = Boards.find(
                playerId: Template.instance().data._id
                win: { $exists: false }
            ).fetch()

            return false if not boards?.length
        catch error
            return false
        return true
    isOpenMatch: ->
        userData = Meteor.users.findOne Template.instance().data._id
        return false if not userData?

        matchData = Matches.findOne
            $or: [
                { teamAId: userData.profile.teamId }
                { teamBId: userData.profile.teamId }
            ]
        return false if not matchData?

        return true
    openRounds: ->
        playerId = Template.instance().data._id
        playerData = Meteor.users.findOne playerId
        return [] if not playerData?

        # Along with rounds pass name of opposing team and matchId
        return Rounds.find(
            {}, { sort: { roundNumber: 1 } }
        ).map (document, index, cursor) ->
            try
                matchId = getMatchIdForPlayerAndRound playerId, document._id
            catch
                return null

            matchData = Matches.findOne matchId
            opponentTeamId = otherTeam(playerData.profile.teamId,
                [ matchData.teamAId, matchData.teamBId ]
            )

            document.matchId = matchId
            document.opponentTeam = Teams.findOne(opponentTeamId).name
            return document

    participatingRounds: ->
        playerId = Template.instance().data._id
        participatingRoundsForPlayerId playerId

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
        buildRoundSelectDropdown(
            $(e.target)
                .closest('.addToMatchCell')
                .find('.openRoundsFeed')
                .text(),
            $('#roundSelect')
        )

        $('#boardSelectPlayerId').val tpl.data._id
        $('#addToMatchModal').modal()

    "click .removeFromMatch": (e, tpl) ->
        e.preventDefault()
        $('#removeRoundSelect').empty()
        buildRoundSelectDropdown(
            $(e.target)
                .closest('.addToMatchCell')
                .find('.participatingRoundsFeed')
                .text(),
            $('#removeRoundSelect')
        )

        $('#removeSelectPlayerId').val tpl.data._id
        $('#removeFromMatchModal').modal()
