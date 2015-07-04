Matches = new Mongo.Collection("matches");

TeamsCollection = Mongo.Collection;
TeamsCollection.prototype.removeTeam = function(teamId) {
    var matchesToRemove = Matches.find(
        { $or: [ {teamAId: teamId}, {teamBId: teamId} ]}
    ).fetch();
    for (var i = 0; i < matchesToRemove.length; i++) {
        var match = matchesToRemove[i];
        Matches.remove(match._id);
    }
    this.remove(teamId);
};

Teams = new TeamsCollection("teams");
