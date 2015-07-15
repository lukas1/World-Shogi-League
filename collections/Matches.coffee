updatePoints = (matchData, add = true) ->
    # Validate input
    return false if not matchData.teamAId?
    return false if not matchData.teamBId?
    return false if not matchData.winTeam?
    return false if not matchData.defaultWin?

    multiplier = 1;
    multiplier = -1 if not add

    # Update points of participating teams
    teamsToUpdate = [
        Teams.findOne matchData.teamAId
        Teams.findOne matchData.teamBId
    ]

    # Select appropriate amount of points to be updated
    for teamData in teamsToUpdate
        do (teamData) ->
            pointsToAdd = 0
            if teamData._id == matchData.winTeam
                pointsToAdd = Points.win
            else if matchData.defaultWin
                pointsToAdd = Points.loseDefault
            else
                pointsToAdd = Points.lose

            points = teamData.points + (multiplier * pointsToAdd)

            # Update points for this team
            Teams.update(teamData._id, {$set: {points: points}});

MatchesCollection = Mongo.Collection;
MatchesCollection.prototype.insertMatch = (matchData) ->
    return false if not isAdmin()

    # Append round id to match data
    round = lastRound()
    roundId = round?._id
    return false if not round?
    matchData.roundId = roundId

    # Insert match
    matchId = this.insert matchData

    # Add match to it's round
    round.matches.push(matchId)
    matches = round.matches
    updated = Rounds.update roundId, {$set: {matches: matches}}
    if not updated
        Matches.removeMatch matchId
        return false
    else
        return matchId

MatchesCollection.prototype.removeMatches = (filter) ->
    return false if not isAdmin()

    matches = Matches.find filter, { fields: {'_id': 1} }
    matches.forEach (document) ->
        Matches.removeMatch document._id

MatchesCollection.prototype.removeMatch = (matchId) ->
    return false if not isAdmin()

    # Validate input
    return false if not matchId?.length

    # Remove all boards with this match id
    Boards.remove { matchId: matchId }

    matchData = this.findOne matchId
    return false if not matchData?

    this.remove matchId

@Matches = new MatchesCollection("matches")
Matches.allow
    insert: -> isAdmin()
    update: -> isAdminOrHead()
    remove: -> isAdmin()
