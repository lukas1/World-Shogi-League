TeamsCollection = Mongo.Collection;
TeamsCollection.prototype.removeTeam = (teamId) ->
    # Fetch matches to remove
    matchesToRemove = Matches.find(
        { $or: [ {teamAId: teamId}, {teamBId: teamId} ]}
    ).fetch();

    # Remove matches
    Matches.remove match._id for match in matchesToRemove

    # Finally remove this team
    this.remove(teamId);

@Teams = new TeamsCollection("teams");
