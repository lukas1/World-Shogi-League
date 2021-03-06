@Future = 0;

# Server code
Meteor.startup () ->
    @Future = Npm.require('fibers/future');

    if DefAdminAccount?
        for defUser in DefAdminAccount
            if Meteor.users.findOne(
                { emails: { $elemMatch: { address: defUser.email } } }
            )? or Meteor.users.findOne({ username: defUser.username })?
                continue
            options =
                username: defUser.username
                email: defUser.email
                password: defUser.password
                profile:
                    userType: USER_TYPE_ADMIN
                    nick81Dojo: defUser.nick81Dojo

            Accounts.createUser(options)

    Accounts.urls.resetPassword = (token) ->
        Meteor.absoluteUrl('user/resetPassword/' + token);

    cron = new Meteor.Cron
        events:
            "0 1 * * *" : resultsCron # once a day

Meteor.publish "teams", () ->
    return Teams.find();

Meteor.publish "rounds", () ->
    return Rounds.find();

Meteor.publish "matches", () ->
    return Matches.find();

Meteor.publish "boards", () ->
    return Boards.find();

Meteor.publish "userlist", () ->
    user = Meteor.users.findOne this.userId
    userType = user?.profile?.userType
    isAdminOrHead = userType == USER_TYPE_ADMIN or userType == USER_TYPE_HEAD
    return Meteor.users.find {}, {fields: { _id:1, profile: 1 }} if isAdminOrHead

Meteor.publish "myActiveMatches", () ->
    matchesIds = Boards.find(
        playerId: this.userId
        win: { $exists: false }
    ).map (document, index, cursor) ->
        return document.matchId

    return Matches.find
        _id: { $in: matchesIds }

Meteor.publish "myMatchesBoards", () ->
    try
        matchesIds = getMatchesForPlayer this.userId
        return Boards.find { matchId: { $in: matchesIds } }
    catch error
        return []

Meteor.publish "myMatchesPlayers", () ->
    try
        matchesIds = getMatchesForPlayer this.userId
        playerIds = Boards.find({ matchId: { $in: matchesIds } },
            fields:
                playerId: 1
        ).map (document, index, cursor) ->
            return document.playerId

        return Meteor.users.find { _id: { $in: playerIds } },
            {fields: { _id:1, profile: 1, emails: 1 }}
    catch error
        return []

Meteor.publish "thisMatch", (matchId) ->
    Matches.find matchId

Meteor.publish "matchTeams", (matchId) ->
    match = Matches.findOne matchId
    return [] if not match?
    return Teams.find { _id: { $in: [match.teamAId, match.teamBId] } }

Meteor.publish "matchBoards", (matchId) ->
    Boards.find { matchId: matchId }

Meteor.publish "matchParticipants", (matchId) ->
    playerIds = Boards.find({ matchId: matchId })
        .map (document, index, cursor) ->
            return document.playerId
    return [] if not playerIds? and not playerIds?.length
    return Meteor.users.find { _id: { $in: playerIds } },
        {fields: { _id:1, profile: 1 }}

Meteor.publish "matchKifus", (matchId) ->
    kifuIds = Boards.find({ matchId: matchId })
        .map (document, index, cursor) ->
            return document.kifu

    return [] if not kifuIds and not kifuIds?.length
    return Kifu.find { _id: { $in: kifuIds } }

Meteor.publish "kifu", (kifuId) ->
    Kifu.find kifuId

Meteor.publish "teamMatches", (teamId) ->
    Matches.find { $or: [ { teamAId: teamId }, { teamBId: teamId } ] }

Meteor.publish "teamBoards", (teamId) ->
    Boards.find { teamId: teamId }

Meteor.publish "teamMembers", (teamId) ->
    Meteor.users.find { 'profile.teamId': teamId },
    {fields: { _id:1, profile: 1 }}

Meteor.publish "userProfileData", (userId) ->
    Meteor.users.find userId

Meteor.publish "userBoards", (userId) ->
    Boards.find { playerId: userId }

Meteor.publish "userTeam", (userId) ->
    userData = Meteor.users.findOne userId
    Teams.find userData.profile.teamId
