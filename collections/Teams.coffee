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

@Teams = new TeamsCollection("teams");
Teams.allow
    insert: -> Meteor.userId()?
    update: -> Meteor.userId()?
    remove: -> Meteor.userId()?
