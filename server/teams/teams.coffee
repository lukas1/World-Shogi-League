Meteor.methods
    countOfTeamsInBiggestClass: () ->
        mostTeamsPerClassCount = Teams.aggregate([
            { $group: { _id: "$class", count: { $sum:1 } } }
            { $project: { _id: 0, count: 1 } }
            { $sort: { count: -1 } }
            { $limit: 1 }
        ]).map (document, index, cursor) ->
            document.count
        return mostTeamsPerClassCount[0]

    updateTeam: (teamId, data) ->
        throw new Meteor.Error "not-authorized" if not isAdmin()

        Teams.update teamId, data
