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
