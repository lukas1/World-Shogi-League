Template.classPoints.helpers
    teams: () ->
        teams = Teams.find(
            { class: Template.instance().data.class }
        ).map (document, index, cursor) ->
            document['matchPoints'] = matchPointsForTeam document._id
            return document

        teams.sort (a,b) ->
            compare = a.matchPoints - b.matchPoints
            if compare == 0
                compare = a.points - b.points

            return -compare
