Template.points.helpers
    pointsA: () ->
        teams = Teams.find({block: "A"}).fetch()
        points = 0
        for team in teams
            do () ->
                points += team.points
        return points
    pointsB: () ->
        teams = Teams.find({block: "B"}).fetch()
        points = 0
        for team in teams
            do () ->
                points += team.points
        return points
    teamsA: () ->
        Teams.find({block: "A"})
    teamsB: () ->
        Teams.find({block: "B"})
