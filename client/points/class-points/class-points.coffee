Template.classPoints.helpers
    teams: () ->
        Teams.find(
            { class: Template.instance().data.class },
            { sort: { points: -1, name: 1 } }
        ).map (document, index, cursor) ->
            document['matchPoints'] = matchPointsForTeam document._id
            return document
