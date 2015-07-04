MatchesCollection = Mongo.Collection;
MatchesCollection.prototype.insertMatch = (matchData) ->
    # Validate input
    return false if not matchData.teamAId?
    return false if not matchData.teamBId?
    return false if not matchData.winTeam?
    return false if not matchData.defaultWin?

    # Update points of participating teams
    teamsToUpdate = [
        Teams.findOne matchData.teamAId
        Teams.findOne matchData.teamBId
    ]

    # Select appropriate amount of points to be updated
    for teamData in teamsToUpdate
        do (teamData) ->
            points = teamData.points
            if teamData._id == matchData.winTeam
                points += Points.win
            else if matchData.defaultWin
                points += Points.loseDefault
            else
                points += Points.lose

            # Update points for this team
            Teams.update(teamData._id, {$set: {points: points}});

    this.insert matchData

@Matches = new MatchesCollection("matches")
