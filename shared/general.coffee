@isAdmin = () ->
    userType = Meteor.user()?.profile?.userType
    return userType == USER_TYPE_ADMIN

@isHead = () ->
    userType = Meteor.user()?.profile?.userType
    return userType == USER_TYPE_HEAD

@isAdminOrHead = () ->
    userType = Meteor.user()?.profile?.userType
    return userType == USER_TYPE_ADMIN or userType == USER_TYPE_HEAD

@lastRound = () ->
    rounds = Rounds.find({}, {sort: {roundNumber: -1}, limit: 1}).fetch()
    return null if not rounds?.length
    return rounds[0];

@getMatchesForPlayer = (playerId) ->
    userData = Meteor.users.findOne playerId
    throw new Meteor.Error "empty-user-data" if not userData?

    matchesIds = Matches.find(
        $or: [
            { teamAId: userData.profile.teamId }
            { teamBId: userData.profile.teamId }
        ]
    ).map (document, index, cursor) ->
        return document._id

@getMatchIdForPlayerAndRound = (playerId, roundId) ->
    roundData = Rounds.findOne roundId
    throw new Meteor.Error "no-such-round" if not roundData?

    userData = Meteor.users.findOne playerId
    throw new Meteor.Error "empty-user-data" if not userData?

    matchData = Matches.findOne
        roundId: roundData._id
        $or: [
            { teamAId: userData.profile.teamId }
            { teamBId: userData.profile.teamId }
        ]

    throw new Meteor.Error "no-active-match", "There's no active match
    for the team of this player" if not matchData?

    return matchData._id

# throws
@boardDataForPlayerAndMatch = (playerId, matchId) ->
    board = Boards.findOne
        playerId: Meteor.userId()
        matchId: matchId

    return board

@unfinishedBoardsForPlayerId = (playerId) ->
    Boards.find({ playerId: playerId, win: { $exists: false } }).fetch()

@otherTeam = (knownTeamId, teams) ->
    for team in teams
        return team if team != knownTeamId

@participatingRoundsForPlayerId = (playerId) ->
    playerData = Meteor.users.findOne playerId
    return [] if not playerData?

    result = []
    boards = unfinishedBoardsForPlayerId playerId
    for board in boards
        matchData = Matches.findOne board.matchId
        continue if not matchData?

        opponentTeamId = otherTeam(playerData.profile.teamId,
            [ matchData.teamAId, matchData.teamBId ]
        )

        roundData = Rounds.findOne matchData.roundId
        continue if not roundData?

        matchRow =
            matchId: board.matchId
            opponentTeam: Teams.findOne(opponentTeamId).name
            roundNumber: roundData.roundNumber
        result.push matchRow

    result.sort (a,b) ->
        a.roundNumber - b.roundNumber

    return result

@buildRoundSelectDropdown = (roundsFeed, target) ->
    for roundData in roundsFeed.split(';')
        roundData = $.trim roundData
        continue if not !!roundData

        roundFields = roundData.split '-'
        $(target).append '<option value="' + roundFields[0] + '">' +
                'Round ' + roundFields[1] + ' - ' + roundFields[2] +
            '</option>'

@matchPointsForTeam = (teamId) ->
    points = 0
    matches = Matches.find(
        { $or: [ { teamAId: teamId }, { teamBId: teamId } ] }
    ).fetch()

    return points if not matches?.length

    for match in matches
        matchBoards = Boards.find(
            { matchId: match._id, teamId: teamId, win: { $exists: true } }
        ).fetch()

        continue if matchBoards.length < 3

        wins = Boards.find(
            { matchId: match._id, teamId: teamId, win: true }
        ).count()

        points += 1 if wins > 1

    return points
