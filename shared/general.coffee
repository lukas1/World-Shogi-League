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

@getMatchIdForPlayer = (playerId) ->
    roundData = lastRound()
    return getMatchIdForPlayerAndRound playerId, roundData._id

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
@boardDataForPlayerId = (playerId) ->
    matchId = getMatchIdForPlayer playerId
    board = Boards.findOne
        playerId: Meteor.userId()
        matchId: matchId

    return board
