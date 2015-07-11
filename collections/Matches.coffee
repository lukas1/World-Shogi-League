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
    return false if not Meteor.userId()?

    # Update points
    return false if not updatePoints matchData

    # Finally insert match
    this.insert matchData

MatchesCollection.prototype.removeMatch = (matchId) ->
    return false if not Meteor.userId()?

    # Validate input
    return false if not matchId?.length

    matchData = this.findOne matchId
    return false if not matchData?

    # Update points
    return false if not updatePoints matchData, false

    this.remove matchId

@Matches = new MatchesCollection("matches")
Matches.allow
    insert: -> isAdmin()
    update: -> isAdminOrHead()
    remove: -> isAdmin()
