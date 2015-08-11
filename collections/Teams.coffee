@updatePointsSingleTeam = (teamId, win, winByDefault, add) ->
    teamData = Teams.findOne teamId
    throw new Meteor.Error "no-such-team" if not teamData?

    multiplier = 1;
    multiplier = -1 if not add

    pointsToAdd = 0
    if win
        pointsToAdd = Points.win
    else if winByDefault
        pointsToAdd = Points.loseDefault
    else
        pointsToAdd = Points.lose

    points = teamData.points + (multiplier * pointsToAdd)

    # Update points for this team
    Teams.update(teamData._id, {$set: {points: points}})

TeamsCollection = Mongo.Collection;
TeamsCollection.prototype.removeTeam = (teamId) ->
    #return false if not Meteor.userId()?
    # Fetch matches to remove
    matchesToRemove = Matches.find(
        { $or: [ {teamAId: teamId}, {teamBId: teamId} ]}
    ).fetch();

    # Remove matches
    Matches.remove match._id for match in matchesToRemove

    # Finally remove this team
    this.remove(teamId);

@Teams = new TeamsCollection("teams", {
        transform: (doc) ->
            uppercased = doc.name.toUpperCase()
            for country, code of CountryCodes
                if country.indexOf(uppercased) > -1
                    doc["countryCode"] = code.toLowerCase()
            return doc
    }
);
Teams.allow
    insert: -> isAdmin()
    update: -> Meteor.userId()?
    remove: -> isAdmin()
